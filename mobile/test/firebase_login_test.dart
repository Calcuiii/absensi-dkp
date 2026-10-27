import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_melayur/screens/common/firebase_app.dart';
import 'package:si_melayur/screens/common/access_check_screen.dart';
import 'package:si_melayur/services/firebase_gateway.dart';
import 'package:si_melayur/theme/app_theme.dart';

class LoginGateway extends FirebaseGateway {
  final result = Completer<Map<String, dynamic>>();
  int attempts = 0;
  @override
  Future<Map<String, dynamic>> signIn() {
    attempts++;
    return result.future;
  }

  @override
  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> data = const {},
  ]) async => {'records': []};
}

void main() {
  testWidgets(
    'Karina login calls Firebase and cannot enter demo when access fails',
    (tester) async {
      final gateway = LoginGateway();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: ConnectedHome(gateway: gateway),
        ),
      );
      expect(find.byIcon(Icons.sailing), findsNWidgets(2));
      final button = find.text('Masuk dengan Google');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
      expect(gateway.attempts, 1);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Masuk dengan Google'),
            )
            .onPressed,
        isNull,
      );
      gateway.result.completeError(
        const ServiceFailure('Akses peserta belum tersedia.'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Akses peserta belum tersedia.'), findsOneWidget);
      expect(find.byType(AccessCheckScreen), findsNothing);
      expect(find.text('Presensi Masuk'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Verified Firebase access opens real account rather than demo participant',
    (tester) async {
      final gateway = LoginGateway();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: ConnectedHome(gateway: gateway),
        ),
      );
      final button = find.text('Masuk dengan Google');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
      gateway.result.complete({
        'name': 'Peserta Terverifikasi',
        'role': 'participant',
        'email': 'uji@example.com',
      });
      await tester.pumpAndSettle();
      expect(find.text('Peserta Terverifikasi'), findsOneWidget);
      expect(find.text('Presensi Masuk'), findsOneWidget);
      expect(find.text('Andi Pratama'), findsNothing);
      expect(find.byType(AccessCheckScreen), findsNothing);
    },
  );
}
