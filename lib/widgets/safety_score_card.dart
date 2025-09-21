import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/theme/app_theme.dart';

class SafetyScoreCard extends StatefulWidget {
  final double score;
  final String location;
  final bool isDangerZone;

  const SafetyScoreCard({
    Key? key,
    required this.score,
    required this.location,
    this.isDangerZone = false,
  }) : super(key: key);

  @override
  State<SafetyScoreCard> createState() => _SafetyScoreCardState();
}

class _SafetyScoreCardState extends State<SafetyScoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.score / 100).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppTheme.successGreen;
    if (score >= 60) return AppTheme.warningOrange;
    return AppTheme.dangerRed;
  }

  String _getSafetyLabel(double score) {
    if (score >= 80) return "SAFE";
    if (score >= 60) return "CAUTION";
    return "DANGER";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: widget.isDangerZone
            ? AppTheme.emergencyGradient
            : AppTheme.safetyGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getScoreColor(widget.score).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          /// Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Safety Score',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.location,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              if (widget.isDangerZone)
                const Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 32,
                ),
            ],
          ),
          const SizedBox(height: 20),

          /// Score + Details
          Row(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(120, 120),
                      painter: CircularProgressPainter(
                        progress: _animation.value,
                        strokeWidth: 12,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        progressColor: Colors.white,
                      ),
                      child: Container(
                        width: 120,
                        height: 120,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${widget.score.toInt()}',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getSafetyLabel(widget.score),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusRow(
                      'Location Safety',
                      widget.score >= 80
                          ? 'High'
                          : widget.score >= 60
                              ? 'Medium'
                              : 'Low',
                      _getScoreColor(widget.score),
                    ),
                    const SizedBox(height: 12),
                    _buildStatusRow(
                      'Network Coverage',
                      'Excellent',
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildStatusRow(
                      'Emergency Access',
                      'Available',
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    /// Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, backgroundPaint);

    /// Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
