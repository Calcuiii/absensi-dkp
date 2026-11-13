import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_melayur/screens/participant/connected_dashboard.dart';
import 'package:si_melayur/theme/app_theme.dart';

void main() {
  Future<void> show(
    WidgetTester tester, {
    List<Map<String, dynamic>> records = const [],
    bool loaded = true,
    VoidCallback? onCheckIn,
  }) async {
    tester.view.resetPhysicalSize();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    ThemeData theme = AppTheme.light();
    if (const bool.fromEnvironment('SAVE_DASHBOARD_PREVIEW')) {
      await tester.runAsync(() async {
        final text = FontLoader('PreviewText');
        text.addFont(
          Future.value(
            ByteData.sublistView(
              await File('C:/Windows/Fonts/arial.ttf').readAsBytes(),
            ),
          ),
        );
        await text.load();
        final icons = FontLoader('MaterialIcons');
        icons.addFont(
          Future.value(
            ByteData.sublistView(
              await File(
                'C:/dev/si-melayur/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
              ).readAsBytes(),
            ),
          ),
        );
        await icons.load();
      });
      theme = theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: 'PreviewText'),
      );
    }
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: RepaintBoundary(
          key: const ValueKey('preview'),
          child: ConnectedDashboard(
            access: const {
              'name': 'Peserta Terverifikasi',
              'email': 'uji@example.com',
              'role': 'participant',
            },
            records: records,
            historyLoaded: loaded,
            busy: false,
            now: DateTime.utc(2026, 11, 8, 2),
            onRefresh: () {},
            onCheckIn: onCheckIn ?? () {},
            onCheckOut: () {},
            onLogout: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Mobile dashboard uses the account and server data with no overflow',
    (tester) async {
      await show(tester);
      expect(find.text('Peserta Terverifikasi'), findsOneWidget);
      expect(find.text('--:--'), findsNWidgets(2));
      expect(find.text('Andi Pratama'), findsNothing);
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('SAVE_DASHBOARD_PREVIEW')) {
        await tester.runAsync(() async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('preview')),
          );
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../.local-backups/integration/dashboard-preview.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    },
  );

  testWidgets(
    'Today uses Jakarta date and offers checkout after a server checkin',
    (tester) async {
      await show(
        tester,
        records: [
          {
            'date': '2026-11-08',
            'checkIn': {'at': '2026-11-08T00:28:00Z'},
          },
        ],
      );
      expect(find.text('07.28'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Presensi Keluar'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Presensi Masuk'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Profile and history show the same verified account without fake records',
    (tester) async {
      await show(tester);
      await tester.tap(find.text('Riwayat'));
      await tester.pumpAndSettle();
      expect(find.text('Belum ada catatan presensi'), findsOneWidget);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('uji@example.com'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Failed history load does not claim an empty successful history',
    (tester) async {
      await show(tester, loaded: false);
      await tester.tap(find.text('Riwayat'));
      await tester.pumpAndSettle();
      expect(find.text('Riwayat belum dimuat'), findsOneWidget);
      expect(find.text('Belum ada catatan presensi'), findsNothing);
    },
  );
}
