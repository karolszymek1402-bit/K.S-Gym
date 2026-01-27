import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silownia_app/main.dart';

class _FakeVibrationClient implements VibrationClient {
  _FakeVibrationClient(
      {required this.hasVibratorValue, required this.hasCustomSupport});

  final bool hasVibratorValue;
  final bool hasCustomSupport;
  List<int>? pattern;
  int? durationMs;

  @override
  Future<bool> hasVibrator() async => hasVibratorValue;

  @override
  Future<bool> hasCustomVibrationsSupport() async => hasCustomSupport;

  @override
  Future<void> vibratePattern(List<int> pattern) async {
    this.pattern = List<int>.from(pattern);
  }

  @override
  Future<void> vibrateDuration(int durationMs) async {
    this.durationMs = durationMs;
  }
}

class _FakeSoundClient implements SoundClient {
  bool played = false;

  @override
  Future<void> playAlert(AudioPlayer? player) async {
    played = true;
  }
}

class _FakeHapticsClient implements HapticsClient {
  bool heavyImpactCalled = false;

  @override
  Future<void> heavyImpact() async {
    heavyImpactCalled = true;
  }
}

class _FakeNotificationClient implements LocalNotificationClient {
  String? lastExercise;
  String? lastLanguage;

  @override
  Future<void> showRestFinished({
    required String exerciseName,
    required String language,
  }) async {
    lastExercise = exerciseName;
    lastLanguage = language;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    restEndActions = RestEndActions();
  });

  test('uses vibration pattern and plays sound when rest ends', () async {
    final vibration =
        _FakeVibrationClient(hasVibratorValue: true, hasCustomSupport: true);
    final sound = _FakeSoundClient();
    final haptics = _FakeHapticsClient();
    final notifications = _FakeNotificationClient();

    restEndActions = RestEndActions(
      vibrationClient: vibration,
      soundClient: sound,
      hapticsClient: haptics,
      notificationClient: notifications,
    );

    await restEndActions.notifyRestFinished(
      exerciseName: 'Test Exercise',
      language: 'PL',
      audioPlayer: null,
    );

    expect(vibration.pattern, [0, 300, 120, 300]);
    expect(vibration.durationMs, isNull);
    expect(sound.played, isTrue);
    expect(haptics.heavyImpactCalled, isTrue);
    expect(notifications.lastExercise, 'Test Exercise');
    expect(notifications.lastLanguage, 'PL');
  });

  test('falls back to duration vibration when custom support is missing',
      () async {
    final vibration =
        _FakeVibrationClient(hasVibratorValue: true, hasCustomSupport: false);
    final sound = _FakeSoundClient();

    restEndActions = RestEndActions(
      vibrationClient: vibration,
      soundClient: sound,
      hapticsClient: _FakeHapticsClient(),
      notificationClient: _FakeNotificationClient(),
    );

    await restEndActions.notifyRestFinished(
      exerciseName: 'Another Exercise',
      language: 'EN',
      audioPlayer: null,
    );

    expect(vibration.pattern, isNull);
    expect(vibration.durationMs, 500);
    expect(sound.played, isTrue);
  });
}
