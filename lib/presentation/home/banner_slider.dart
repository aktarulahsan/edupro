import 'dart:async';

import 'package:edupro/infrastructure/dal/model/banner_item.dart';
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  final List<BannerItem> banners = const [
    BannerItem(
      title: 'Special Discount!',
      subtitle: 'Get 30% off on all premium courses',
      color: Colors.orange,
      icon: Icons.local_offer,
    ),
    BannerItem(
      title: 'New Features Added',
      subtitle: 'Try our new AI-powered practice mode',
      color: Colors.green,
      icon: Icons.new_releases,
    ),
    BannerItem(
      title: 'Weekly Challenge',
      subtitle: 'Compete with top learners and win prizes',
      color: Colors.purple,
      icon: Icons.emoji_events,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _autoScrollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _autoScroll(),
    );
  }

  void _autoScroll() {
    if (_pageController.hasClients) {
      int nextPage = (_currentPage + 1) % banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: kCardBg,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemCount: banners.length,
        itemBuilder: (context, index) {
          return bannerCard(banners[index]);
        },
      ),
    );
  }

  Widget bannerCard(BannerItem banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [banner.color.withOpacity(0.8), banner.color],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: banner.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(banner.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  banner.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  banner.subtitle,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
