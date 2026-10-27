import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// ============================================================
// PAGE SHELL
// ============================================================

class PageShell extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool showBack;

  const PageShell({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              automaticallyImplyLeading: showBack,
              title: Text(
                title!,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              actions: actions,
            ),
      body: SafeArea(child: child),
    );
  }
}

// ============================================================
// APP LOGO
// ============================================================

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.ocean],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -size * 0.15,
            top: -size * 0.15,
            child: Container(
              width: size * 0.52,
              height: size * 0.52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Icon(Icons.sailing, color: Colors.white, size: size * 0.48),
        ],
      ),
    );
  }
}

// ============================================================
// STATUS PILL
// ============================================================

class StatusPill extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const StatusPill({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INFO CARD
// ============================================================

class InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const InfoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.7),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionTitle({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

// ============================================================
// ATTENDANCE CARD
// ============================================================

class AttendanceCard extends StatelessWidget {
  final String title;
  final String time;
  final String subtitle;
  final IconData icon;
  final Color color;

  const AttendanceCard({
    super.key,
    required this.title,
    required this.time,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  // Tambahan untuk state gagal memuat data.
  final VoidCallback? onRetry;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.ocean, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),

          // Tombol aksi umum.
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],

          // Tombol coba lagi untuk error/loading failure.
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// LOADING STATE
// ============================================================

class LoadingState extends StatelessWidget {
  final String message;

  const LoadingState({super.key, this.message = 'Memeriksa data...'});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BOTTOM NAVIGATION
// ============================================================

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationDestination> destinations;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: destinations,
    );
  }
}

// ============================================================
// DEMO NOTE
// ============================================================

class DemoNote extends StatelessWidget {
  final String text;

  const DemoNote({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paleBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.ocean, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SOFT MAP
// ============================================================

class SoftMap extends StatelessWidget {
  final bool valid;

  const SoftMap({super.key, this.valid = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 190,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.paleBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: CustomPaint(
        painter: MapPainter(valid: valid),
        child: Stack(
          children: [
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppColors.ocean,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'DKP Jawa Timur',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: valid
                      ? AppColors.teal.withValues(alpha: 0.12)
                      : AppColors.danger.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  color: valid ? AppColors.teal : AppColors.danger,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MAP PAINTER
// ============================================================

class MapPainter extends CustomPainter {
  final bool valid;

  MapPainter({required this.valid});

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final secondaryRoadPaint = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.18)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final areaPaint = Paint()
      ..color = (valid ? AppColors.teal : AppColors.danger).withValues(
        alpha: 0.08,
      )
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = (valid ? AppColors.teal : AppColors.danger).withValues(
        alpha: 0.28,
      )
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final mainRoad = Path()
      ..moveTo(-20, size.height * 0.70)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.45,
        size.width * 0.55,
        size.height * 0.80,
        size.width + 20,
        size.height * 0.40,
      );

    final secondaryRoad = Path()
      ..moveTo(size.width * 0.12, -10)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.28,
        size.width * 0.48,
        size.height * 0.30,
        size.width * 0.72,
        size.height + 10,
      );

    canvas.drawPath(mainRoad, roadPaint);
    canvas.drawPath(secondaryRoad, secondaryRoadPaint);

    final center = Offset(size.width / 2, size.height / 2);

    final radius = size.shortestSide * 0.25;

    canvas.drawCircle(center, radius, areaPaint);

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.valid != valid;
  }
}

// ============================================================
// STATUS COLOR
// ============================================================

Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'tepat waktu':
    case 'aktif':
    case 'sudah masuk':
      return AppColors.success;

    case 'terlambat':
      return AppColors.warning;

    case 'izin':
    case 'sakit':
    case 'izin/sakit':
      return AppColors.info;

    case 'belum masuk':
    case 'belum presensi':
      return AppColors.muted;

    case 'ditolak':
    case 'gagal':
      return AppColors.danger;

    default:
      return AppColors.muted;
  }
}
