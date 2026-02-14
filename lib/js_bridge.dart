import 'js_bridge_stub.dart' if (dart.library.js) 'js_bridge_web.dart' as impl;

void evalJs(String script) => impl.evalJs(script);

void scheduleNotification(String title, String body, int delaySeconds) =>
    impl.scheduleNotification(title, body, delaySeconds);

void cancelNotification() => impl.cancelNotification();
