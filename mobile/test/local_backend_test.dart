import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_melayur/services/firebase_gateway.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test(
    'Backend URL follows explicit local opt-in and Android host routing',
    () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final url = FirebaseConfig.functionUrl('verifyAccess');
      if (const bool.fromEnvironment('USE_LOCAL_BACKEND')) {
        expect(url.scheme, 'http');
        expect(url.host, '10.0.2.2');
        expect(url.port, 5001);
        expect(
          url.path,
          '/${FirebaseConfig.projectId}/asia-southeast2/verifyAccess',
        );
      } else {
        expect(url.scheme, 'https');
        expect(url.host, endsWith('.cloudfunctions.net'));
        expect(url.path, '/verifyAccess');
      }
    },
  );

  test('Desktop test host uses loopback instead of Android emulator alias', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    expect(FirebaseConfig.emulatorHost, '127.0.0.1');
  });
}
