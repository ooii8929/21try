import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';

class CameraService {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  Future<void> initializeCameras() async {
    try {
      cameras = await availableCameras();
      debugPrint('Available cameras: ${cameras?.length}');
      for (var cam in cameras ?? []) {
        debugPrint('Camera: ${cam.name}, Lens: ${cam.lensDirection}');
      }
    } catch (e) {
      debugPrint('Error getting available cameras: $e');
    }
  }

  Future<void> initializeCamera(CameraLensDirection direction) async {
    try {
      debugPrint('Initializing camera with direction: $direction');

      if (cameras == null || cameras!.isEmpty) {
        await initializeCameras();
      }

      if (cameras == null || cameras!.isEmpty) {
        debugPrint('ERROR: No cameras available on this device!');
        debugPrint('This might be because:');
        debugPrint('1. Running on an iOS simulator without camera support');
        debugPrint(
            '2. Running on an Android emulator without camera emulation');
        debugPrint('3. The device does not have camera hardware');
        debugPrint('4. Camera permissions are not granted');
        throw Exception('No cameras available on this device');
      }

      final camera = cameras!.firstWhere(
        (cam) => cam.lensDirection == direction,
        orElse: () => cameras!.first,
      );

      debugPrint('Selected camera: ${camera.name}');

      controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await controller!.initialize();
      debugPrint('Camera initialized successfully');
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      rethrow;
    }
  }

  Future<String?> startVideoRecording() async {
    if (controller == null || !controller!.value.isInitialized) {
      debugPrint('Camera not initialized for video recording');
      return null;
    }

    if (_isRecording) {
      debugPrint('Already recording');
      return null;
    }

    try {
      debugPrint('Starting video recording...');
      await controller!.startVideoRecording();
      _isRecording = true;
      debugPrint('Video recording started');
      return 'recording';
    } catch (e) {
      debugPrint('Error starting video recording: $e');
      return null;
    }
  }

  Future<String?> stopVideoRecording() async {
    if (controller == null || !_isRecording) {
      debugPrint('Camera not recording');
      return null;
    }

    try {
      debugPrint('Stopping video recording...');
      final XFile video = await controller!.stopVideoRecording();
      _isRecording = false;
      debugPrint('Video recording stopped: ${video.path}');
      return video.path;
    } catch (e) {
      debugPrint('Error stopping video recording: $e');
      return null;
    }
  }

  Future<String?> takePhoto() async {
    if (controller == null || !controller!.value.isInitialized) {
      debugPrint('Camera not initialized for photo');
      return null;
    }

    try {
      debugPrint('Taking photo...');
      final image = await controller!.takePicture();
      debugPrint('Photo taken successfully: ${image.path}');
      return image.path;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  Future<void> switchCamera(CameraLensDirection direction) async {
    await controller?.dispose();
    await initializeCamera(direction);
  }

  Future<String?> savePhotoToGallery(String photoPath) async {
    try {
      debugPrint('Saving photo to gallery: $photoPath');

      // 請求權限
      final PermissionState permission =
          await PhotoManager.requestPermissionExtend();
      if (permission != PermissionState.authorized) {
        debugPrint('Photo permission not granted');
        return null;
      }

      final file = File(photoPath);
      if (!await file.exists()) {
        debugPrint('Photo file does not exist: $photoPath');
        return null;
      }

      final assetEntity = await PhotoManager.editor.saveImage(
        file.readAsBytesSync(),
        filename: '21Try_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      debugPrint('Photo saved to gallery with assetId: ${assetEntity.id}');
      return assetEntity.id;
    } catch (e) {
      debugPrint('Error saving photo to gallery: $e');
      return null;
    }
  }

  Future<String?> saveVideoToGallery(String videoPath) async {
    try {
      debugPrint('Saving video to gallery: $videoPath');

      // 請求權限
      final PermissionState permission =
          await PhotoManager.requestPermissionExtend();
      if (permission != PermissionState.authorized) {
        debugPrint('Video permission not granted');
        return null;
      }

      final file = File(videoPath);
      if (!await file.exists()) {
        debugPrint('Video file does not exist: $videoPath');
        return null;
      }

      final assetEntity = await PhotoManager.editor.saveVideo(file);

      debugPrint('Video saved to gallery with assetId: ${assetEntity.id}');
      return assetEntity.id;
    } catch (e) {
      debugPrint('Error saving video to gallery: $e');
      return null;
    }
  }

  Future<String?> getVideoPathFromAssetId(String assetId) async {
    try {
      debugPrint('Getting video path from assetId: $assetId');

      // 請求權限
      final PermissionState permission =
          await PhotoManager.requestPermissionExtend();
      if (permission != PermissionState.authorized) {
        debugPrint('Photo permission not granted');
        return null;
      }

      // 從 assetId 找到 AssetEntity
      final assetEntity = await AssetEntity.fromId(assetId);
      if (assetEntity == null) {
        debugPrint('AssetEntity not found for assetId: $assetId');
        return null;
      }

      // 獲取檔案路徑
      final file = await assetEntity.file;
      if (file == null) {
        debugPrint('File not found for assetId: $assetId');
        return null;
      }

      debugPrint('Video path retrieved: ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('Error getting video path from assetId: $e');
      return null;
    }
  }

  Future<void> dispose() async {
    if (_isRecording) {
      await stopVideoRecording();
    }
    await controller?.dispose();
  }
}
