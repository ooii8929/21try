import Flutter
import UIKit
import Photos

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let cameraChannel = FlutterMethodChannel(
      name: "com.example.twentyonetry/camera",
      binaryMessenger: controller.binaryMessenger
    )
    
    cameraChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "saveVideoToPhotoLibrary":
        if let args = call.arguments as? [String: Any],
           let videoPath = args["videoPath"] as? String {
          self?.saveVideoToPhotoLibrary(videoPath: videoPath, result: result)
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func saveVideoToPhotoLibrary(videoPath: String, result: @escaping FlutterResult) {
    PHPhotoLibrary.shared().performChanges {
      let videoURL = URL(fileURLWithPath: videoPath)
      PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
    } completionHandler: { success, error in
      if success {
        result(true)
      } else {
        result(FlutterError(code: "SAVE_FAILED", message: error?.localizedDescription, details: nil))
      }
    }
  }
}
