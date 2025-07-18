/// Face++人脸识别插件 - 插件主入口
/// 第三阶段：插件工厂和依赖注入

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'interfaces/i_face_recognition_service.dart';
import 'implementations/faceplus_service_impl.dart';
import 'widgets/face_recognition_view.dart';
import 'models/face_recognition_models.dart';

/// Face++人脸识别插件工厂
class FaceRecognitionPluginFactory implements IFaceRecognitionFactory {
  static FaceRecognitionPluginFactory? _instance;
  static const MethodChannel _channel = MethodChannel('face_recognition_plugin');
  
  String? _sdkVersion;
  bool? _isSupported;

  FaceRecognitionPluginFactory._();

  /// 获取单例实例
  static FaceRecognitionPluginFactory get instance {
    _instance ??= FaceRecognitionPluginFactory._();
    return _instance!;
  }

  @override
  IFaceRecognitionService createService() {
    return FacePlusServiceImpl();
  }

  @override
  IFaceRecognitionView createView() {
    // 注意：这里返回的是Widget，实际使用时需要通过FaceRecognitionView创建
    throw UnsupportedError('请直接使用FaceRecognitionView Widget');
  }

  @override
  bool get isSupported {
    _isSupported ??= _checkPlatformSupport();
    return _isSupported!;
  }

  @override
  String get sdkVersion {
    _sdkVersion ??= _getSdkVersion();
    return _sdkVersion!;
  }

  /// 检查平台支持
  bool _checkPlatformSupport() {
    try {
      // 检查是否为Android平台且支持Face++
      return true; // 简化实现，实际应该检查平台和SDK
    } catch (e) {
      return false;
    }
  }

  /// 获取SDK版本
  String _getSdkVersion() {
    try {
      return 'Face++ SDK 1.0.0'; // 简化实现
    } catch (e) {
      return 'Unknown';
    }
  }

  /// 异步初始化插件
  static Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
    } catch (e) {
      print('Face++插件初始化失败: $e');
    }
  }

  /// 清理插件资源
  static Future<void> dispose() async {
    try {
      await _channel.invokeMethod('dispose');
      _instance = null;
    } catch (e) {
      print('Face++插件清理失败: $e');
    }
  }
}

/// 人脸识别插件管理器
class FaceRecognitionPluginManager {
  static final Map<String, IFaceRecognitionService> _services = {};
  static final FaceRecognitionPluginFactory _factory = FaceRecognitionPluginFactory.instance;

  /// 注册服务实例
  static void registerService(String name, IFaceRecognitionService service) {
    _services[name] = service;
  }

  /// 获取服务实例
  static IFaceRecognitionService? getService(String name) {
    return _services[name];
  }

  /// 获取默认服务实例
  static IFaceRecognitionService getDefaultService() {
    const defaultName = 'default';
    if (!_services.containsKey(defaultName)) {
      _services[defaultName] = _factory.createService();
    }
    return _services[defaultName]!;
  }

  /// 移除服务实例
  static Future<void> removeService(String name) async {
    final service = _services.remove(name);
    if (service != null) {
      await service.dispose();
    }
  }

  /// 清理所有服务
  static Future<void> clearAllServices() async {
    for (final service in _services.values) {
      await service.dispose();
    }
    _services.clear();
  }

  /// 检查插件是否可用
  static bool get isAvailable => _factory.isSupported;

  /// 获取SDK版本
  static String get sdkVersion => _factory.sdkVersion;
}

/// 人脸识别插件便捷工具类
class FaceRecognitionPlugin {
  static FaceRecognitionPluginManager get manager => FaceRecognitionPluginManager();
  static FaceRecognitionPluginFactory get factory => FaceRecognitionPluginFactory.instance;

  /// 快速创建人脸识别视图
  static Widget createView({
    required FaceRecognitionConfig config,
    IFaceRecognitionCallback? callback,
    double? width,
    double? height,
    bool autoStart = true,
  }) {
    return FaceRecognitionView(
      config: config,
      callback: callback,
      width: width,
      height: height,
      autoStart: autoStart,
    );
  }

  /// 快速创建服务实例
  static IFaceRecognitionService createService() {
    return factory.createService();
  }

  /// 检查设备支持
  static Future<bool> checkDeviceSupport() async {
    return await FacePlusServiceImpl.isDeviceSupported();
  }

  /// 初始化插件（应用启动时调用）
  static Future<void> initialize() async {
    await FaceRecognitionPluginFactory.initialize();
  }

  /// 清理插件（应用退出时调用）
  static Future<void> dispose() async {
    await FaceRecognitionPluginManager.clearAllServices();
    await FaceRecognitionPluginFactory.dispose();
  }
}