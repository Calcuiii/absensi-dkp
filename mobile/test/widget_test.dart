import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_melayur/app.dart';
import 'package:si_melayur/screens/common/firebase_app.dart';
import 'package:si_melayur/screens/common/login_screen.dart';
import 'package:si_melayur/screens/participant/participant_shell.dart';
import 'package:si_melayur/screens/participant/attendance_screen.dart';
import 'package:si_melayur/screens/admin/admin_profile_screen.dart';
import 'package:si_melayur/models/models.dart';
import 'package:si_melayur/theme/app_theme.dart';

void main() {
  testWidgets(
    'Participant logout returns to login after the login route was removed',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light(), home: const ParticipantShell()),
      );
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      final logout = find.text('Keluar / Ganti Akun');
      await tester.scrollUntilVisible(
        logout,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(logout);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(ParticipantShell), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Admin logout returns to login from the first route', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const AdminProfileScreen()),
    );
    final logout = find.text('Keluar / Ganti Akun');
    await tester.scrollUntilVisible(
      logout,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(logout);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Missing cloud configuration never enters a simulated real session',
    (tester) async {
      await tester.pumpWidget(
        const FirebaseAppShell(
          configurationError: 'Konfigurasi belum tersedia.',
        ),
      );
      expect(find.text('Layanan belum disiapkan'), findsOneWidget);
      expect(find.text('Lihat demo dengan data contoh'), findsOneWidget);
      expect(find.text('Presensi Masuk'), findsNothing);
    },
  );

  testWidgets('Demo keeps an explicit data label and completes login', (
    tester,
  ) async {
    await tester.pumpWidget(const SiMelayurApp());
    expect(find.text('MODE DEMO • DATA CONTOH'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.ensureVisible(find.text('Masuk dengan Google'));
    await tester.tap(find.text('Masuk dengan Google'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(ParticipantShell), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Invalid simulated location disables attendance confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const AttendanceScreen()),
    );
    await tester.pump(const Duration(seconds: 1));
    final dropdown = find.byType(DropdownButton<LocationCheckState>);
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Di luar area').last);
    await tester.pumpAndSettle();
    expect(find.text('Di luar area presensi'), findsOneWidget);
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Presensi belum dapat dilakukan'),
    );
    expect(button.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
