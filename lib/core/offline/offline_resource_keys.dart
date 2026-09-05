class OfflineResourceKeys {
  static const field = 'field';
  static String measurement(String quarter) => 'measurement:$quarter';
  static String history(String quarter) => 'history:$quarter';
  static String analytics(String name) => 'analytics:$name';
  static String alert(String id) => 'alert:$id';
  static String device(String id) => 'device:$id';
  static const gateway = 'gateway';
  static const irrigation = 'irrigation';

  const OfflineResourceKeys._();
}
