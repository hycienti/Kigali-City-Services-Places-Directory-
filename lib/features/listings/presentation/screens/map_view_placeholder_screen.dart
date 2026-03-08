import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class MapViewPlaceholderScreen extends StatelessWidget {
  const MapViewPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Map View – coming in Stage 7.\n\nFirestore listings and OSM POIs will be shown here.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
