import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';

class VideoPlayerPage extends StatelessWidget {
  final String contentId;

  const VideoPlayerPage({
    super.key,
    required this.contentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_outline,
                size: 120,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(height: AppDimensions.spaceLG),
              Text(
                'Video Player',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              Text(
                'Content ID: $contentId',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              const Text(
                'This will be a full-featured video player with progress tracking, subtitles, and learning analytics.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}