import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

/// Background image URLs for onboarding slides. Replace with asset paths
/// (e.g. 'assets/onboarding/slide_1.jpg') for offline use.
const List<String> _slideImageUrls = [
  'https://picsum.photos/seed/kigali1/600/400',
  'https://picsum.photos/seed/kigali2/600/400',
  'https://picsum.photos/seed/kigali3/600/400',
  'https://picsum.photos/seed/kigali4/600/400',
];

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_InfoSlide> _slides = [
    _InfoSlide(
      icon: Icons.explore_rounded,
      title: 'Discover places',
      body: 'Browse hospitals, cafés, parks, and more across Kigali.',
    ),
    _InfoSlide(
      icon: Icons.map_rounded,
      title: 'View on map',
      body: 'See listings and points of interest on an interactive map.',
    ),
    _InfoSlide(
      icon: Icons.directions_rounded,
      title: 'Get directions',
      body: 'Open in your maps app for turn-by-turn navigation.',
    ),
    _InfoSlide(
      icon: Icons.add_location_alt_rounded,
      title: 'Add your own',
      body: 'Create listings to help others find services and places.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Icon(
              Icons.location_city_rounded,
              size: 56,
              color: AppTheme.primaryDark,
            ),
            const SizedBox(height: 16),
            Text(
              'Kigali City Services',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Find and navigate to services and places across Kigali.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              flex: 1,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  final imageUrl = index < _slideImageUrls.length
                      ? _slideImageUrls[index]
                      : null;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _SlideCard(
                      backgroundImageUrl: imageUrl,
                      icon: slide.icon,
                      title: slide.title,
                      body: slide.body,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? AppTheme.primaryDark
                        : AppTheme.primaryDark.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: () => context.push('/login'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Log in'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.push('/sign-up'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryDark,
                      side: const BorderSide(color: AppTheme.primaryDark),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Create account'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoSlide {
  const _InfoSlide({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _SlideCard extends StatelessWidget {
  const _SlideCard({
    this.backgroundImageUrl,
    required this.icon,
    required this.title,
    required this.body,
  });

  final String? backgroundImageUrl;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (backgroundImageUrl != null)
              Positioned.fill(
                child: Image.network(
                  backgroundImageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryDark.withOpacity(0.3),
                            AppTheme.accent.withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => _gradientFallback(),
                ),
              )
            else
              _gradientFallback(),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                child: Container(color: Colors.transparent),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 28, color: AppTheme.primaryDark),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.95),
                          height: 1.4,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientFallback() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryDark.withOpacity(0.85),
            AppTheme.primaryDark.withOpacity(0.7),
            AppTheme.accent.withOpacity(0.4),
          ],
        ),
      ),
    );
  }
}
