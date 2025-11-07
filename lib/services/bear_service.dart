import 'dart:math';
import 'package:flutter/material.dart';
import '../models/bear_state.dart';
import '../models/isar_models.dart';
import 'isar_service.dart';

class BearService {
  static const int _baseDistance = 5;

  // 測試模式：true = 使用秒數模擬天數，false = 使用真實天數
  static const bool _testMode = true;
  static const int _testIntervalSeconds = 10; // 測試模式下，10秒 = 1天

  static String? _lastShownImage;

  // Get current distance for a specific goal
  static Future<int> getCurrentDistance(int goalId) async {
    final goal = await IsarService.getGoalById(goalId);
    if (goal == null) {
      debugPrint('Bear: Goal $goalId not found, returning base distance $_baseDistance');
      return _baseDistance;
    }
    
    final now = DateTime.now();
    
    if (goal.lastBearCheckin == null) {
      debugPrint('Bear: Goal ${goal.id} has no check-in history, returning base distance $_baseDistance');
      return _baseDistance;
    }
    
    final daysGap = _calculateDaysGap(goal.lastBearCheckin!, now);
    final computedDistance = max(0, goal.lastBearDistance - daysGap);
    
    debugPrint('Bear: Goal ${goal.id} - lastDistance: ${goal.lastBearDistance}, daysGap: $daysGap, computed: $computedDistance');
    
    return computedDistance;
  }

  // 計算天數差距（支援測試模式）
  static int _calculateDaysGap(DateTime lastCheckin, DateTime now) {
    if (_testMode) {
      // 測試模式：用秒數模擬天數
      final secondsGap = now.difference(lastCheckin).inSeconds;
      final simulatedDays = secondsGap ~/ _testIntervalSeconds;
      debugPrint('Bear Test Mode: ${secondsGap}s elapsed = $simulatedDays simulated days');
      return simulatedDays;
    } else {
      // 正常模式：使用真實天數
      final today = _localDateOnly(now);
      final lastDate = _localDateOnly(lastCheckin);
      return today.difference(lastDate).inDays;
    }
  }

  // User checks in for a specific goal
  static Future<BearEventResult> doCheckin(int goalId) async {
    final goal = await IsarService.getGoalById(goalId);
    if (goal == null) {
      throw Exception('Goal not found');
    }
    
    final now = DateTime.now();
    final checkinTime = _testMode ? now : _localDateOnly(now);
    
    // 獲取當前距離（打卡前的距離）
    final currentDistance = await getCurrentDistance(goalId);
    
    // Update goal - 維持當前距離，不重置為 5
    goal.lastBearCheckin = checkinTime;
    goal.lastBearDistance = currentDistance;
    
    await IsarService.saveGoal(goal);
    
    // Select random "maintain" image
    final imagePath = _selectRandomImage('maintain');
    
    if (_testMode) {
      debugPrint('Bear: Check-in for Goal ${goal.id}! Distance maintained at $currentDistance (Test Mode: ${_testIntervalSeconds}s = 1 day)');
    } else {
      debugPrint('Bear: Check-in for Goal ${goal.id}! Distance maintained at $currentDistance');
    }
    
    return BearEventResult(
      eventType: 'maintain',
      distanceAfter: currentDistance,
      imageAssetPath: imagePath,
    );
  }

  // Called when app activates/resumes for a specific goal
  static Future<BearEventResult?> onActivate(int goalId) async {
    final goal = await IsarService.getGoalById(goalId);
    if (goal == null) return null;
    
    final now = DateTime.now();
    
    if (goal.lastBearCheckin == null) {
      // First time, no event
      debugPrint('Bear: Goal ${goal.id} onActivate - no check-in history');
      return null;
    }
    
    final daysGap = _calculateDaysGap(goal.lastBearCheckin!, now);
    final computedDistance = max(0, goal.lastBearDistance - daysGap);
    final previousDistance = goal.lastBearDistance; // 保存舊的距離
    
    debugPrint('Bear: Goal ${goal.id} onActivate - previous: $previousDistance, computed: $computedDistance, gap: $daysGap');
    
    // Check if distance decreased
    if (computedDistance < previousDistance) {
      // Distance decreased - show decrement event
      goal.lastBearDistance = computedDistance;
      await IsarService.saveGoal(goal);
      
      final imagePath = _selectRandomImage('distance', distance: computedDistance);
      
      if (_testMode) {
        debugPrint('Bear: Distance decreased for Goal ${goal.id} from $previousDistance to $computedDistance (Test Mode)');
      } else {
        debugPrint('Bear: Distance decreased for Goal ${goal.id} from $previousDistance to $computedDistance');
      }
      
      return BearEventResult(
        eventType: 'decrement',
        distanceAfter: computedDistance,
        imageAssetPath: imagePath,
        previousDistance: previousDistance,
      );
    }
    
    // No change - idle
    debugPrint('Bear: Goal ${goal.id} onActivate - no change (distance: $computedDistance)');
    return null;
  }

  // Select random image from gallery
  static String? _selectRandomImage(String type, {int? distance}) {
    final random = Random();
    List<String> images = [];
    
    if (type == 'maintain') {
      // Maintain images
      images = [
        'assets/bear/maintain/maintain_001.png',
        'assets/bear/maintain/maintain_002.png',
        'assets/bear/maintain/maintain_003.png',
      ];
    } else if (type == 'distance' && distance != null) {
      // Distance-specific images
      switch (distance) {
        case 5:
          images = ['assets/bear/distance/d5/d5_001.png'];
          break;
        case 4:
          images = [
            'assets/bear/distance/d4/d4_001.png',
            'assets/bear/distance/d4/d4_002.png',
          ];
          break;
        case 3:
          images = [
            'assets/bear/distance/d3/d3_001.png',
            'assets/bear/distance/d3/d3_002.png',
          ];
          break;
        case 2:
          images = [
            'assets/bear/distance/d2/d2_001.png',
            'assets/bear/distance/d2/d2_002.png',
          ];
          break;
        case 1:
          images = [
            'assets/bear/distance/d1/d1_001.png',
            'assets/bear/distance/d1/d1_002.png',
          ];
          break;
        case 0:
          images = [
            'assets/bear/distance/d0/d0_001.png',
            'assets/bear/distance/d0/d0_002.png',
          ];
          break;
      }
    }
    
    if (images.isEmpty) return null;
    
    // Avoid repeating same image if possible
    if (images.length > 1 && _lastShownImage != null) {
      images.removeWhere((img) => img == _lastShownImage);
    }
    
    final selectedImage = images[random.nextInt(images.length)];
    _lastShownImage = selectedImage;
    
    return selectedImage;
  }

  // Helper: Get date only (truncate time)
  static DateTime _localDateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  // Reset state for a specific goal (for testing)
  static Future<void> reset(int goalId) async {
    final goal = await IsarService.getGoalById(goalId);
    if (goal == null) return;
    
    goal.lastBearCheckin = null;
    goal.lastBearDistance = _baseDistance;
    await IsarService.saveGoal(goal);
    
    _lastShownImage = null;
    debugPrint('Bear: Reset for Goal ${goal.id}');
  }
}
