import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import '../utils/app_colors.dart';
import '../services/camera_service.dart';
import 'edit_record_screen.dart';

class RecordScreen extends StatefulWidget {
  final int goalId;

  const RecordScreen({Key? key, required this.goalId}) : super(key: key);

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late CameraService _cameraService;
  bool isRecording = false;
  int recordingSeconds = 0;
  bool _isCameraInitialized = false;
  bool _isSaving = false;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    debugPrint('RecordScreen initState called');
    _cameraService = CameraService();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      debugPrint('Starting camera initialization...');
      await _cameraService.initializeCamera(CameraLensDirection.back);
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
      debugPrint('Camera initialization completed successfully');
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 全螢幕相機預覽
            _buildVideoPreview(),
            // 浮動的 UI 元素
            Column(
              children: [
                _buildHeader(),
                const Spacer(),
                _buildProgressIndicator(),
                _buildControls(),
                _buildSaveButton(),
                const SizedBox(height: 20),
              ],
            ),
            // 顯示儲存中的覆蓋層
            if (_isSaving)
              Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Saving video...',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 72,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左側空白佔位
          const SizedBox(width: 48),
          // 右側按鈕
          SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
                // 錄影時禁用關閉按鈕
                onPressed: (_isSaving || isRecording)
                    ? null
                    : () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (!_isCameraInitialized ||
        _cameraService.controller == null ||
        !_cameraService.controller!.value.isInitialized) {
      return SizedBox.expand(
        child: Container(
          color: Colors.black,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'Camera Not Available',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Check:\n• Device has camera\n• Permissions granted\n• Not using simulator',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraService.controller!.value.previewSize!.height,
          height: _cameraService.controller!.value.previewSize!.width,
          child: CameraPreview(_cameraService.controller!),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    // 時間紀錄已移除，時間顯示保留在錄影中按鈕旁邊
    return const SizedBox.shrink();
  }

  Widget _buildControls() {
    if (isRecording) {
      // 錄影中顯示圓形進度條和停止按鈕
      return Padding(
        padding: const EdgeInsets.only(top: 40, bottom: 40),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // 圓形進度條
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: recordingSeconds / 60,
                    strokeWidth: 3,
                    backgroundColor: Colors.grey.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF00D9FF),
                    ),
                  ),
                ),
                // 停止按鈕
                GestureDetector(
                  onTap: _isSaving
                      ? null
                      : () async {
                          setState(() {
                            _isSaving = true;
                          });

                          try {
                            final videoPath =
                                await _cameraService.stopVideoRecording();

                            if (videoPath != null) {
                              debugPrint('Video saved: $videoPath');

                              await Future.delayed(
                                  const Duration(milliseconds: 500));

                              setState(() {
                                isRecording = false;
                              });

                              await Future.delayed(
                                  const Duration(milliseconds: 200));

                              // 直接導航到編輯畫面
                              if (mounted) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditRecordScreen(
                                      mediaPath: videoPath,
                                      goalId: widget.goalId,
                                    ),
                                  ),
                                ).then((result) {
                                  // 如果保存成功，返回到 GoalDetailScreen
                                  if (result == true && mounted) {
                                    Navigator.pop(context);
                                  }
                                });
                              }
                            }
                          } catch (e) {
                            debugPrint('Error stopping video: $e');
                          } finally {
                            _recordingTimer?.cancel();
                            _recordingTimer = null;
                            if (mounted) {
                              setState(() {
                                _isSaving = false;
                              });
                            }
                          }
                        },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: Center(
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D9FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 計時器
            Text(
              '0:${recordingSeconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    // 未錄影時顯示原本的控制按鈕
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(Icons.image_outlined, () {}),
          _buildMainControlButton(),
          _buildControlButton(Icons.flip_camera_ios_outlined, () async {
            if (!_isSaving && !isRecording) {
              await _cameraService.switchCamera(CameraLensDirection.front);
              setState(() {});
            }
          }),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: _isSaving ? null : onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: _isSaving ? 0.2 : 0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: _isSaving ? AppColors.textSecondary : AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildMainControlButton() {
    return GestureDetector(
      onTap: _isSaving
          ? null
          : () async {
              debugPrint('Main button tapped, isRecording: $isRecording');

              if (!isRecording) {
                // Start recording
                final result = await _cameraService.startVideoRecording();
                if (result != null) {
                  setState(() {
                    isRecording = true;
                    recordingSeconds = 0;
                  });
                  _recordingTimer =
                      Timer.periodic(const Duration(seconds: 1), (timer) {
                    if (mounted) {
                      setState(() {
                        recordingSeconds++;
                      });
                    }
                  });
                }
              } else {
                // Stop recording
                setState(() {
                  _isSaving = true;
                });

                try {
                  final videoPath = await _cameraService.stopVideoRecording();

                  if (videoPath != null) {
                    debugPrint('Video saved: $videoPath');

                    // 等待一下確保檔案完全寫入
                    await Future.delayed(const Duration(milliseconds: 500));

                    setState(() {
                      isRecording = false;
                    });

                    // 再等一下才導航
                    await Future.delayed(const Duration(milliseconds: 200));

                    // 直接導航到編輯畫面
                    if (mounted) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditRecordScreen(
                            mediaPath: videoPath,
                            goalId: widget.goalId,
                          ),
                        ),
                      ).then((result) {
                        // 如果保存成功，返回到 GoalDetailScreen
                        if (result == true && mounted) {
                          Navigator.pop(context);
                        }
                      });
                    }
                  }
                } catch (e) {
                  debugPrint('Error stopping video: $e');
                } finally {
                  _recordingTimer?.cancel();
                  _recordingTimer = null;
                  if (mounted) {
                    setState(() {
                      _isSaving = false;
                    });
                  }
                }
              }
            },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: _isSaving ? 0.2 : 0.4),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Icon(
          isRecording ? Icons.stop : Icons.camera_alt,
          color: _isSaving ? AppColors.textSecondary : AppColors.textPrimary,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    // 不再需要保存按鈕，因為錄影完成後會直接進入編輯畫面
    return const SizedBox.shrink();
  }
}
