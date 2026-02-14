// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js' as js;

void evalJs(String script) {
  js.context.callMethod('eval', [script]);
}

void scheduleNotification(String title, String body, int delaySeconds) {
  try {
    js.context
        .callMethod('scheduleNotificationSW', [title, body, delaySeconds]);
  } catch (e) {
    print('Web scheduleNotification error: $e');
  }
}

void cancelNotification() {
  try {
    js.context.callMethod('cancelNotificationSW', []);
  } catch (e) {
    print('Web cancelNotification error: $e');
  }
}
