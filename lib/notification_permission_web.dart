// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

Future<String> getNotificationPermission() async {
  try {
    if (!html.Notification.supported) return 'unsupported';
    return html.Notification.permission ?? 'default';
  } catch (_) {
    return 'error';
  }
}

Future<String> requestNotificationPermission() async {
  try {
    if (!html.Notification.supported) return 'unsupported';
    final result = await html.Notification.requestPermission();
    return result ?? 'default';
  } catch (_) {
    return 'error';
  }
}
