import 'package:flutter/material.dart';
import '../models/bear_state.dart';
import '../utils/app_colors.dart';

class BearEventModal extends StatelessWidget {
  final BearEventResult event;

  const BearEventModal({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            if (event.imageAssetPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  event.imageAssetPath!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: AppColors.background,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              _getTitle(),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              _getDescription(),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Distance indicator
            _buildDistanceIndicator(),
            const SizedBox(height: 24),
            
            // Close button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Got it!',
                    style: TextStyle(
                      color: AppColors.background,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (event.eventType) {
      case 'maintain':
        return '🎉 Great Job!';
      case 'decrement':
        if (event.distanceAfter == 0) {
          return '🐻 Oh no! Bear caught you!';
        }
        return '⚠️ Bear is getting closer!';
      default:
        return 'Bear Status';
    }
  }

  String _getDescription() {
    switch (event.eventType) {
      case 'maintain':
        if (event.distanceAfter == 0) {
          return 'You checked in! But the bear already caught you. Keep checking in daily to prevent this!';
        } else if (event.distanceAfter < 3) {
          return 'You checked in! Distance maintained at ${event.distanceAfter}. The bear is still close, keep checking in!';
        }
        return 'You checked in today! Distance maintained at ${event.distanceAfter}. Keep it up!';
      case 'decrement':
        if (event.distanceAfter == 0) {
          return 'You missed too many days. The bear caught you! Check in daily to maintain distance.';
        }
        return 'You missed a day! The bear moved closer from ${event.previousDistance} to ${event.distanceAfter}.';
      default:
        return 'Current distance: ${event.distanceAfter}';
    }
  }

  Widget _buildDistanceIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Distance:',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          final isFilled = index < event.distanceAfter;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 32,
            height: 8,
            decoration: BoxDecoration(
              color: isFilled ? AppColors.primary : AppColors.progressBackground,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          '${event.distanceAfter}/5',
          style: TextStyle(
            color: event.distanceAfter > 0 ? AppColors.primary : Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
