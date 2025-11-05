import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/app_colors.dart';
import '../services/camera_service.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/isar_models.dart';
import '../services/isar_service.dart';

class EditRecordScreen extends StatefulWidget {
  final String? mediaPath;
  final int goalId;

  const EditRecordScreen({Key? key, this.mediaPath, required this.goalId})
      : super(key: key);

  @override
  State<EditRecordScreen> createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends State<EditRecordScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isVideo = false;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 給更多時間讓檔案系統完成寫入
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _initializeMedia();
      }
    });
  }

  Future<void> _initializeMedia() async {
    if (widget.mediaPath == null || widget.mediaPath!.isEmpty) {
      debugPrint('No media path provided');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    debugPrint('Initializing media: ${widget.mediaPath}');

    final file = File(widget.mediaPath!);

    // 等待檔案完全寫入 - 重試機制
    int retries = 0;
    while (retries < 5) {
      if (await file.exists()) {
        final fileSize = await file.length();
        if (fileSize > 0) {
          debugPrint('File ready: $fileSize bytes');
          break;
        }
      }
      debugPrint('Waiting for file... (attempt ${retries + 1})');
      await Future.delayed(const Duration(milliseconds: 300));
      retries++;
    }

    if (!await file.exists()) {
      debugPrint('File does not exist after retries: ${widget.mediaPath}');
      if (mounted) {
        setState(() {
          _errorMessage = 'Video file not found';
          _isLoading = false;
        });
      }
      return;
    }

    final fileSize = await file.length();
    debugPrint('Final file size: $fileSize bytes');

    if (fileSize == 0) {
      debugPrint('File is empty');
      if (mounted) {
        setState(() {
          _errorMessage = 'Video file is empty';
          _isLoading = false;
        });
      }
      return;
    }

    _isVideo = widget.mediaPath!.toLowerCase().endsWith('.mp4') ||
        widget.mediaPath!.toLowerCase().endsWith('.mov');

    if (!_isVideo) {
      // 照片處理
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    // 影片處理 - 使用 try-catch 並重試
    int videoRetries = 0;
    bool success = false;

    while (videoRetries < 3 && !success) {
      try {
        debugPrint(
            'Attempting to initialize video player (attempt ${videoRetries + 1})...');

        // 確保之前的 controller 已清理
        await _disposeControllers();

        // 再等一下確保檔案可讀
        await Future.delayed(const Duration(milliseconds: 200));

        // 建立新的 controller
        _videoPlayerController = VideoPlayerController.file(
          file,
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: false,
            allowBackgroundPlayback: false,
          ),
        );

        // 初始化
        await _videoPlayerController!.initialize();

        debugPrint('Video player initialized successfully');
        debugPrint('Video duration: ${_videoPlayerController!.value.duration}');
        debugPrint('Video size: ${_videoPlayerController!.value.size}');

        if (!mounted) return;

        // 建立 Chewie controller
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: false,
          looping: false,
          showControls: true,
          aspectRatio: _videoPlayerController!.value.aspectRatio > 0
              ? _videoPlayerController!.value.aspectRatio
              : 16 / 9,
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.primary,
            handleColor: AppColors.primary,
            backgroundColor: AppColors.cardBackground,
            bufferedColor: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          placeholder: Container(
            color: AppColors.cardBackground,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          ),
          autoInitialize: true,
        );

        setState(() {
          _isVideoInitialized = true;
          _errorMessage = null;
          _isLoading = false;
        });

        success = true;
        debugPrint('Video setup completed successfully');
      } catch (e, stackTrace) {
        debugPrint(
            'Error initializing video (attempt ${videoRetries + 1}): $e');

        await _disposeControllers();

        videoRetries++;
        if (videoRetries < 3) {
          // 等待後重試
          await Future.delayed(Duration(milliseconds: 500 * videoRetries));
        } else {
          // 最後一次嘗試失敗
          debugPrint('Failed after $videoRetries attempts');
          debugPrint('Stack trace: $stackTrace');

          if (mounted) {
            setState(() {
              _isVideoInitialized = false;
              _errorMessage = 'Unable to load video\nTry recording again';
              _isLoading = false;
            });
          }
        }
      }
    }
  }

  Future<void> _disposeControllers() async {
    try {
      _chewieController?.pause();
      _chewieController?.dispose();
      _chewieController = null;

      await _videoPlayerController?.pause();
      await _videoPlayerController?.dispose();
      _videoPlayerController = null;

      // 給系統時間清理
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('Error disposing controllers: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
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
                  children: [
                    _buildVideoThumbnail(),
                    _buildTitleField(),
                    _buildNotesField(),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(),
            Container(
              height: 20,
              color: AppColors.background,
            ),
          ],
        ),
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
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 48),
              child: Text(
                'Try 1',
                textAlign: TextAlign.center,
                style: TextStyle(
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

  Widget _buildVideoThumbnail() {
    return Container(
      height: 219,
      width: double.infinity,
      color: AppColors.cardBackground,
      child: _buildMediaContent(),
    );
  }

  Widget _buildMediaContent() {
    // 顯示錯誤訊息
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.textSecondary,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                  });
                  _initializeMedia();
                },
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 載入中
    if (_isLoading ||
        (_isVideo && !_isVideoInitialized && widget.mediaPath != null)) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // 影片播放器
    if (_isVideo && _isVideoInitialized && _chewieController != null) {
      return Chewie(controller: _chewieController!);
    }

    // 圖片
    if (!_isVideo && widget.mediaPath != null && widget.mediaPath!.isNotEmpty) {
      return Image.file(
        File(widget.mediaPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.error_outline,
              color: AppColors.textSecondary,
              size: 48,
            ),
          );
        },
      );
    }

    // 預設圖片
    return Image.network(
      'https://api.builder.io/api/v1/image/assets/TEMP/38f7913298fea2d3241001da1dbd3298d054b1d9?width=385',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColors.cardBackground,
        );
      },
    );
  }

  Widget _buildTitleField() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Try Title',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _titleController,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Try Summary / Notes',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
          Container(
            constraints: const BoxConstraints(minHeight: 144),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: null,
              minLines: 6,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                // Save media to gallery and get assetId
                String? assetId;
                if (widget.mediaPath != null && widget.mediaPath!.isNotEmpty) {
                  try {
                    final cameraService = CameraService();
                    if (_isVideo) {
                      assetId = await cameraService
                          .saveVideoToGallery(widget.mediaPath!);
                    } else {
                      assetId = await cameraService
                          .savePhotoToGallery(widget.mediaPath!);
                    }
                  } catch (e) {
                    debugPrint('Error saving to gallery: $e');
                  }
                }

                // Save record to Isar
                if (assetId != null && assetId.isNotEmpty) {
                  try {
                    final record = Record()
                      ..title = _titleController.text
                      ..description = _notesController.text
                      ..assetId = assetId
                      ..createdAt = DateTime.now();

                    await IsarService.saveRecordWithGoal(record, widget.goalId);
                    debugPrint('Record saved successfully');
                  } catch (e) {
                    debugPrint('Error saving record: $e');
                  }
                }

                if (mounted) {
                  // Pop back to GoalDetailScreen and trigger refresh
                  Navigator.pop(context, true);
                }
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      color: AppColors.background,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
