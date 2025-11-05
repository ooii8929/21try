import 'package:flutter/material.dart';
import '../models/isar_models.dart';
import '../utils/app_colors.dart';
import '../services/isar_service.dart';
import 'goal_detail_screen.dart';
import 'dart:io';
import '../services/camera_service.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class EditRecordReviewScreen extends StatefulWidget {
  final Record record;

  const EditRecordReviewScreen({Key? key, required this.record})
      : super(key: key);

  @override
  State<EditRecordReviewScreen> createState() => _EditRecordReviewScreenState();
}

class _EditRecordReviewScreenState extends State<EditRecordReviewScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  bool _isLoading = false;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  String? _errorMessage;
  bool _isVideoLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.record.title;
    _summaryController.text = widget.record.description;
    _loadGoal();
    _initializeVideo();
  }

  Future<void> _loadGoal() async {
    await widget.record.goal.load();
  }

  Future<void> _disposeControllers() async {
    try {
      _chewieController?.pause();
      _chewieController?.dispose();
      _chewieController = null;

      await _videoPlayerController?.pause();
      await _videoPlayerController?.dispose();
      _videoPlayerController = null;

      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('Error disposing controllers: $e');
    }
  }

  Future<void> _initializeVideo() async {
    if (widget.record.assetId.isEmpty) {
      debugPrint('No assetId available for record');
      return;
    }

    setState(() {
      _isVideoLoading = true;
      _errorMessage = null;
    });

    try {
      final cameraService = CameraService();
      final videoPath =
          await cameraService.getVideoPathFromAssetId(widget.record.assetId);

      if (videoPath == null) {
        debugPrint(
            'Failed to get video path from assetId: ${widget.record.assetId}');
        if (mounted) {
          setState(() {
            _errorMessage = 'Video file not found';
            _isVideoLoading = false;
          });
        }
        return;
      }

      final file = File(videoPath);

      // 等待檔案完全可讀
      int retries = 0;
      while (retries < 5) {
        if (await file.exists()) {
          final fileSize = await file.length();
          if (fileSize > 0) {
            debugPrint('Video file ready: $fileSize bytes');
            break;
          }
        }
        debugPrint('Waiting for video file... (attempt ${retries + 1})');
        await Future.delayed(const Duration(milliseconds: 300));
        retries++;
      }

      if (!await file.exists()) {
        debugPrint('Video file does not exist after retries: $videoPath');
        if (mounted) {
          setState(() {
            _errorMessage = 'Video file not found';
            _isVideoLoading = false;
          });
        }
        return;
      }

      // 初始化影片播放器
      int videoRetries = 0;
      bool success = false;

      while (videoRetries < 3 && !success) {
        try {
          debugPrint(
              'Attempting to initialize video player (attempt ${videoRetries + 1})...');

          // 確保之前的 controller 已清理
          await _disposeControllers();

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
          debugPrint(
              'Video duration: ${_videoPlayerController!.value.duration}');
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
              bufferedColor: AppColors.textSecondary.withOpacity(0.3),
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
            _isVideoLoading = false;
          });

          success = true;
          debugPrint('Video setup completed successfully');
        } catch (e, stackTrace) {
          debugPrint(
              'Error initializing video (attempt ${videoRetries + 1}): $e');

          await _disposeControllers();

          videoRetries++;
          if (videoRetries < 3) {
            await Future.delayed(Duration(milliseconds: 500 * videoRetries));
          } else {
            debugPrint('Failed after $videoRetries attempts');
            debugPrint('Stack trace: $stackTrace');

            if (mounted) {
              setState(() {
                _isVideoInitialized = false;
                _errorMessage = 'Unable to load video\nTry recording again';
                _isVideoLoading = false;
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error in _initializeVideo: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load video';
          _isVideoLoading = false;
        });
      }
    }
  }

  Widget _buildVideoThumbnail() {
    return Container(
      height: 219,
      width: double.infinity,
      color: AppColors.cardBackground,
      child: _buildVideoContent(),
    );
  }

  Widget _buildVideoContent() {
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
                  _initializeVideo();
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
    if (_isVideoLoading ||
        (!_isVideoInitialized && widget.record.assetId.isNotEmpty)) {
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
    if (_isVideoInitialized && _chewieController != null) {
      return Chewie(controller: _chewieController!);
    }

    // 預設圖片
    return Container(
      color: AppColors.cardBackground,
      child: const Center(
        child: Icon(
          Icons.videocam,
          color: AppColors.textSecondary,
          size: 48,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _disposeControllers();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      widget.record.title = _titleController.text.trim();
      widget.record.description = _summaryController.text.trim();

      await IsarService.saveRecord(widget.record);

      if (!mounted) return;

      if (widget.record.goal.value != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                GoalDetailScreen(goal: widget.record.goal.value!),
          ),
          (route) => route.isFirst,
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving record: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save changes')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                  children: [
                    _buildVideoThumbnail(),
                    _buildTitleField(),
                    const SizedBox(height: 24),
                    _buildSummaryField(),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
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
                'Edit Review',
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

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Title',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Enter title...',
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildSummaryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Summary',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _summaryController,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Enter summary...',
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 5,
          minLines: 3,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: GestureDetector(
        onTap: _isLoading ? null : _saveChanges,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: _isLoading ? AppColors.textSecondary : AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.background,
                    strokeWidth: 2,
                  ),
                )
              else
                const Icon(
                  Icons.save,
                  color: AppColors.background,
                  size: 24,
                ),
              const SizedBox(width: 16),
              Text(
                _isLoading ? 'Saving...' : 'Save Changes',
                style: const TextStyle(
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
    );
  }
}
