import 'notification_permission_stub.dart'
    if (dart.library.js) 'notification_permission_web.dart' as impl;

Future<String> getNotificationPermission() => impl.getNotificationPermission();
Future<String> requestNotificationPermission() =>
    impl.requestNotificationPermission();
