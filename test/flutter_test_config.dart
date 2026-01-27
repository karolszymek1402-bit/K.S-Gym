import 'dart:async';

import 'package:flutter/foundation.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  FlutterError.onError = (FlutterErrorDetails details) {
    final message = details.exceptionAsString();
    if (message.contains('unhandled element <defs/>')) {
      return;
    }
    FlutterError.dumpErrorToConsole(details);
  };

  debugPrint = (String? message, {int? wrapWidth}) {
    if (message == null) return;
    if (message.contains('unhandled element <defs/>')) {
      return;
    }
    debugPrintThrottled(message, wrapWidth: wrapWidth);
  };

  await runZoned(
    () async {
      await testMain();
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        if (line.contains('unhandled element <defs/>')) {
          return;
        }
        parent.print(zone, line);
      },
    ),
  );
}
