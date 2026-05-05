import 'package:edupro/infrastructure/dal/model/feature_card_data.dart';
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:flutter/material.dart';

class FeatureCard extends StatefulWidget {
  final FeatureCardData card;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.card,
    required this.onTap,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(14), // Reduced from 18
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Added to prevent overflow
            children: [
              // Icon bubble
              Container(
                width: 28, // Reduced from 52
                height: 28, // Reduced from 52
                decoration: BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  widget.card.icon,
                  color: kPrimary,
                  size: 24, // Reduced from 26
                ),
              ),
              const SizedBox(width: 2), // Reduced from Spacer()
              // Title
              Text(
                widget.card.title,
                style: const TextStyle(
                  fontSize: 14, // Reduced from 15
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6), // Reduced from 5
              // Subtitle
              // Expanded(
              //   child: Text(
              //     widget.card.subtitle,
              //     style: const TextStyle(
              //       fontSize: 11, // Reduced from 12
              //       color: kTextGrey,
              //       height: 1.3, // Reduced from 1.4
              //     ),
              //     maxLines: 3, // Increased from 2 to show more text
              //     overflow: TextOverflow.ellipsis,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}


