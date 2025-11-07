import 'dart:async';
import 'package:flutter/material.dart';
import '../models/isar_models.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/bear_event_modal.dart';
import '../services/isar_service.dart';
import '../services/bear_service.dart';
import 'record_screen.dart';
import 'edit_record_review_screen.dart';
import '../main.dart'; // 引入全局的 routeObserver

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailScreen({Key? key, required this.goal}) : super(key: key);

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> with RouteAware {
  int _currentIndex = 1;
  List<Record> records = [];
  int _currentDistance = 5;
  Timer? _distanceUpdateTimer;

  @override
  void initState() {
    super.initState();
    _loadRecords();
    _checkBearStatus();
    _startDistanceUpdateTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _distanceUpdateTimer?.cancel();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _startDistanceUpdateTimer() {
    // 每秒檢查一次距離（測試模式下可能會變化）
    _distanceUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      final newDistance = await BearService.getCurrentDistance(widget.goal.id);
      if (newDistance != _currentDistance) {
        setState(() {
          _currentDistance = newDistance;
        });
        
        // 如果距離降到 0，顯示警告
        if (newDistance == 0 && _currentDistance > 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ Bear caught you! Distance dropped to 0!'),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    });
  }

  @override
  void didPopNext() {
    // 當從子路由返回時重新載入記錄
    _loadRecords();
    _checkBearStatus();
  }

  Future<void> _loadRecords() async {
    try {
      final loadedRecords =
          await IsarService.getRecordsByGoalId(widget.goal.id);
      setState(() {
        records = loadedRecords;
      });
    } catch (e) {
      debugPrint('Error loading records: $e');
    }
  }

  Future<void> _checkBearStatus() async {
    try {
      // Check if bear distance changed for this goal
      final event = await BearService.onActivate(widget.goal.id);
      final distance = await BearService.getCurrentDistance(widget.goal.id);
      
      setState(() {
        _currentDistance = distance;
      });
      
      // Show modal if there's an event
      if (event != null && mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => BearEventModal(event: event),
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error checking bear status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressSection(),
                    _buildTimelineSection(),
                  ],
                ),
              ),
            ),
            _buildRecordButton(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: AppColors.background,
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 48),
              child: Text(
                widget.goal.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final progress = records.length / 21.0; // 假設總共 21 次嘗試

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bear distance indicator
          _buildBearDistanceCard(),
          const SizedBox(height: 16),
          
          // Original progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Almost there!',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              Text(
                '${records.length}/21',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.progressBackground,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBearDistanceCard() {
    final distanceColor = _currentDistance > 2
        ? AppColors.primary
        : _currentDistance > 0
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: distanceColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🐻',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Bear Distance',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                        ),
                        // 測試模式標記
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'TEST: 10s = 1 day',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // 重置按鈕
                        GestureDetector(
                          onTap: () async {
                            await BearService.reset(widget.goal.id);
                            await _checkBearStatus();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bear state reset! Distance is now 5/5'),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.refresh,
                              size: 14,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getBearStatusText(),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$_currentDistance/5',
                style: TextStyle(
                  color: distanceColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Distance bar
          Row(
            children: List.generate(5, (index) {
              final isFilled = index < _currentDistance;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 8,
                  decoration: BoxDecoration(
                    color: isFilled ? distanceColor : AppColors.progressBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getBearStatusText() {
    if (_currentDistance == 5) {
      return 'Safe! Keep checking in daily';
    } else if (_currentDistance > 2) {
      return 'Getting closer... Check in soon!';
    } else if (_currentDistance > 0) {
      return 'Danger! Bear is very close!';
    } else {
      return 'Bear caught you! Check in to reset';
    }
  }

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Timeline',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.28,
            ),
          ),
        ),
        ...records.asMap().entries.map((entry) {
          int index = entry.key + 1;
          Record record = entry.value;
          return _buildRecordItem(record, index);
        }).toList(),
      ],
    );
  }

  Widget _buildRecordItem(Record record, int index) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左邊的線條
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            // 內容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Record $index:${record.title.isNotEmpty ? ' ${record.title}' : ''}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${record.createdAt.month}/${record.createdAt.day}/${record.createdAt.year}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  if (record.description.isNotEmpty) const SizedBox(height: 4),
                  if (record.description.isNotEmpty)
                    Text(
                      record.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 右邊的 Review 按鈕 - 只有筆的 icon，固定大小
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditRecordReviewScreen(record: record),
                  ),
                ).then((_) => _loadRecords());
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.edit,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          // 簡易打卡按鈕
          GestureDetector(
            onTap: _handleQuickCheckIn,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.primary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 錄影按鈕
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecordScreen(goalId: widget.goal.id),
                  ),
                ).then((_) => _loadRecords());
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam_outlined,
                      color: AppColors.background,
                      size: 24,
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Record Try',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleQuickCheckIn() async {
    try {
      // 建立簡易打卡記錄
      final record = Record()
        ..title = 'Quick Check-in'
        ..description = ''
        ..assetId = '' // 沒有影片
        ..createdAt = DateTime.now();

      await IsarService.saveRecordWithGoal(record, widget.goal.id);
      
      // Bear check-in for this goal
      final bearEvent = await BearService.doCheckin(widget.goal.id);
      
      // 重新載入記錄和距離
      await _loadRecords();
      final distance = await BearService.getCurrentDistance(widget.goal.id);
      
      setState(() {
        _currentDistance = distance;
      });
      
      // 顯示熊的事件 modal
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => BearEventModal(event: bearEvent),
        );
      }
    } catch (e) {
      debugPrint('Error creating quick check-in: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to record check-in'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
