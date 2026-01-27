// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js' as js;

void evalJs(String script) {
  js.context.callMethod('eval', [script]);
}
