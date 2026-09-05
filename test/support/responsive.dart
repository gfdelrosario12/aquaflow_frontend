import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sets a phone-like logical viewport (~360–430px Android band).
Future<void> setPhoneWidth(WidgetTester tester, double logicalWidth) async {
  final view = tester.view;
  view.devicePixelRatio = 1.0;
  view.physicalSize = Size(logicalWidth, 800);
  addTearDown(view.resetPhysicalSize);
  addTearDown(view.resetDevicePixelRatio);
}
