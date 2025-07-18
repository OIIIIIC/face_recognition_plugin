import 'dart:async';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Face Recognition Plugin主类
class FaceRecognitionPlugin extends PlatformInterface {
  FaceRecognitionPlugin() : super(token: _token);

  static final Object _token = Object();
  static FaceRecognitionPlugin _instance = FaceRecognitionPlugin();
  static FaceRecognitionPlugin get instance => _instance;

  static const MethodChannel _channel = MethodChannel('face_recognition_plugin');

  /// 插件注册方法
  static void registerWith() {
    // 这个方法由Flutter自动调用来注册插件
    // 实际的注册逻辑在Android端的FaceRecognitionPlugin.java中处理
  }

  /// 初始化插件
  static Future<bool> initialize(Map<String, dynamic> config) async {
    try {
      final bool result = await _channel.invokeMethod('initialize', config);
      return result;
    } catch (e) {
      print('FaceRecognitionPlugin initialize error: $e');
      return false;
    }
  }

  /// 检查设备是否支持
  static Future<bool> isDeviceSupported() async {
    try {
      final bool result = await _channel.invokeMethod('isDeviceSupported');
      return result;
    } catch (e) {
      print('FaceRecognitionPlugin isDeviceSupported error: $e');
      return false;
    }
  }

  /// 获取SDK版本
  static Future<String> getSdkVersion() async {
    try {
      final String version = await _channel.invokeMethod('getSdkVersion');
      return version;
    } catch (e) {
      print('FaceRecognitionPlugin getSdkVersion error: $e');
      return 'Unknown';
    }
  }

  /// 活体检测
  static Future<bool> checkLiveness({
    required List<int> nv21Data,
    required int width,
    required int height,
    required int rotation,
  }) async {
    try {
      final bool result = await _channel.invokeMethod('checkLiveness', {
        'nv21Data': nv21Data,
        'width': width,
        'height': height,
        'rotation': rotation,
      });
      return result;
    } catch (e) {
      print('FaceRecognitionPlugin checkLiveness error: $e');
      return false;
    }
  }

  /// 人脸检测
  static Future<Map<String, dynamic>> detectFace({
    required List<int> nv21Data,
    required int width,
    required int height,
    required int rotation,
    required bool mirror,
  }) async {
    try {
      final Map<String, dynamic> result = await _channel.invokeMethod('detectFace', {
        'nv21Data': nv21Data,
        'width': width,
        'height': height,
        'rotation': rotation,
        'mirror': mirror,
      });
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('FaceRecognitionPlugin detectFace error: $e');
      return {
        'state': 3, // FaceDetectionState.failed
        'errorMessage': 'Plugin error: $e',
      };
    }
  }

  /// 更新配置
  static Future<bool> updateConfig(Map<String, dynamic> config) async {
    try {
      final bool result = await _channel.invokeMethod('updateConfig', config);
      return result;
    } catch (e) {
      print('FaceRecognitionPlugin updateConfig error: $e');
      return false;
    }
  }

  /// 获取当前配置
  static Future<Map<String, dynamic>> getCurrentConfig() async {
    try {
      final Map<String, dynamic> result = await _channel.invokeMethod('getCurrentConfig');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('FaceRecognitionPlugin getCurrentConfig error: $e');
      return {};
    }
  }

  /// 释放资源
  static Future<void> dispose() async {
    try {
      await _channel.invokeMethod('dispose');
    } catch (e) {
      print('FaceRecognitionPlugin dispose error: $e');
    }
  }
}