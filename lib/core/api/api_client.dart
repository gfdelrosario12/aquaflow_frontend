import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_errors.dart';
import 'api_token_store.dart';

typedef TokenRefresh = Future<String?> Function(String refreshToken);

class ApiClient {
  final ApiConfig config;
  final http.Client httpClient;
  final ApiTokenStore? tokenStore;
  final TokenRefresh? refreshToken;
  Future<String?>? _refreshInFlight;

  ApiClient({
    ApiConfig? config,
    http.Client? httpClient,
    this.tokenStore,
    this.refreshToken,
  })  : config = config ?? ApiConfig.fromEnvironment(),
        httpClient = httpClient ?? http.Client();

  Future<Object?> get(
    String path, {
    Map<String, String>? query,
    bool authorized = true,
    bool retryable = true,
  }) {
    return request(
      'GET',
      path,
      query: query,
      authorized: authorized,
      retryable: retryable,
    );
  }

  Future<Object?> post(
    String path, {
    Map<String, Object?>? body,
    bool authorized = true,
    bool retryable = false,
  }) {
    return request(
      'POST',
      path,
      body: body,
      authorized: authorized,
      retryable: retryable,
    );
  }

  Future<Object?> request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, Object?>? body,
    bool authorized = true,
    bool retryable = false,
  }) async {
    final uri = _buildUri(path, query);
    final headers = await _headers(authorized);
    final response = await _send(
      method,
      uri,
      headers,
      body,
      retryable: retryable && method == 'GET',
    );

    if (response.statusCode == 401 && authorized && refreshToken != null) {
      final refresh = tokenStore == null
          ? null
          : await tokenStore!.readRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        await tokenStore?.clearTokens();
        throw const ApiException(
          kind: ApiErrorKind.authentication,
          message: 'Authentication expired and no refresh token is available.',
          statusCode: 401,
        );
      }

      final newAccessToken = await _refresh(refresh);
      if (newAccessToken == null || newAccessToken.isEmpty) {
        await tokenStore?.clearTokens();
        throw const ApiException(
          kind: ApiErrorKind.authentication,
          message: 'Unable to refresh the authentication session.',
          statusCode: 401,
        );
      }

      final replayHeaders = await _headers(authorized);
      final replay = await _send(
        method,
        uri,
        replayHeaders,
        body,
        retryable: false,
      );
      return _decodeResponse(replay);
    }

    return _decodeResponse(response);
  }

  Future<http.Response> _send(
    String method,
    Uri uri,
    Map<String, String> headers,
    Map<String, Object?>? body, {
    required bool retryable,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        final request = http.Request(method, uri)..headers.addAll(headers);
        if (body != null) request.body = jsonEncode(body);
        final streamed = await httpClient.send(request).timeout(
          config.connectTimeout + config.receiveTimeout,
        );
        final response = await http.Response.fromStream(streamed);
        if (retryable && _isRetryableStatus(response.statusCode) &&
            attempt < config.maxGetRetries) {
          await Future<void>.delayed(Duration(milliseconds: 100 * (attempt + 1)));
          attempt++;
          continue;
        }
        return response;
      } on TimeoutException catch (error) {
        if (retryable && attempt < config.maxGetRetries) {
          await Future<void>.delayed(Duration(milliseconds: 100 * (attempt + 1)));
          attempt++;
          continue;
        }
        throw ApiException(
          kind: ApiErrorKind.timeout,
          message: 'The API request timed out.',
          cause: error,
        );
      } on ApiException {
        rethrow;
      } catch (error) {
        if (retryable && attempt < config.maxGetRetries) {
          await Future<void>.delayed(Duration(milliseconds: 100 * (attempt + 1)));
          attempt++;
          continue;
        }
        throw ApiException(
          kind: ApiErrorKind.connectivity,
          message: 'Unable to reach the AquaSense API.',
          cause: error,
        );
      }
    }
  }

  Object? _decodeResponse(http.Response response) {
    final statusCode = response.statusCode;
    Object? decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (error) {
        throw ApiException(
          kind: ApiErrorKind.decoding,
          message: 'The API returned invalid JSON.',
          statusCode: statusCode,
          cause: error,
        );
      }
    }

    if (statusCode >= 200 && statusCode < 300) return decoded;
    throw ApiException(
      kind: _errorKind(statusCode),
      message: _errorMessage(decoded, statusCode),
      statusCode: statusCode,
    );
  }

  Future<Map<String, String>> _headers(bool authorized) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-Client': 'aquasense-mobile',
    };
    if (authorized && tokenStore != null) {
      final accessToken = await tokenStore!.readAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    return headers;
  }

  Future<String?> _refresh(String refreshTokenValue) {
    return _refreshInFlight ??= refreshToken!(refreshTokenValue).whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Uri _buildUri(String path, Map<String, String>? query) {
    final base = Uri.parse(config.baseUrl);
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return base.replace(
      path: '${base.path}$normalizedPath',
      queryParameters: query,
    );
  }

  bool _isRetryableStatus(int statusCode) =>
      statusCode == 408 || statusCode == 425 || statusCode == 429 || statusCode >= 500;

  ApiErrorKind _errorKind(int statusCode) {
    if (statusCode == 401 || statusCode == 403) return ApiErrorKind.authentication;
    if (statusCode == 400 || statusCode == 422) return ApiErrorKind.validation;
    if (statusCode >= 500) return ApiErrorKind.server;
    return ApiErrorKind.unexpected;
  }

  String _errorMessage(Object? decoded, int statusCode) {
    if (decoded is Map<String, dynamic> && decoded['message'] is String) {
      return decoded['message'] as String;
    }
    return 'AquaSense API request failed with status $statusCode.';
  }

  void close() => httpClient.close();
}
