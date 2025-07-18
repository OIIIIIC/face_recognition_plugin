/// Face++人脸识别插件 - 服务接口定义
/// 第一阶段：核心接口抽象

import 'dart:typed_data';
import '../models/face_recognition_models.dart';

/// 人脸识别服务接口
/// 定义了所有人脸识别功能的标准接口，支持依赖注入和多实现
abstract class IFaceRecognitionService {
  /// 初始化人脸识别服务
  /// [config] 配置参数
  /// 返回是否初始化成功
  Future<bool> initialize(FaceRecognitionConfig config);

  /// 释放资源
  Future<void> dispose();

  /// 检测活体
  /// [nv21Data] NV21格式图像数据
  /// [width] 图像宽度
  /// [height] 图像高度
  /// [rotation] 旋转角度
  /// 返回活体检测结果
  Future<bool> checkLiveness(
    Uint8List nv21Data,
    int width,
    int height,
    int rotation,
  );

  /// 人脸检测和识别
  /// [nv21Data] NV21格式图像数据
  /// [width] 图像宽度
  /// [height] 图像高度
  /// [rotation] 旋转角度
  /// [mirror] 是否镜像
  /// 返回人脸识别结果
  Future<FaceRecognitionResult> detectFace(
    Uint8List nv21Data,
    int width,
    int height,
    int rotation, {
    bool mirror = false,
  });

  /// 获取当前配置
  FaceRecognitionConfig get currentConfig;

  /// 检查服务是否已初始化
  bool get isInitialized;

  /// 检查是否支持双目摄像头
  bool get supportsDualCamera;
}

/// 人脸识别回调接口
abstract class IFaceRecognitionCallback {
  /// 人脸检测结果回调
  void onFaceDetected(FaceRecognitionResult result);

  /// 活体检测结果回调
  void onLivenessDetected(bool isLive, double confidence);

  /// 错误回调
  void onError(String error, {String? code});

  /// 检测状态变化回调
  void onStateChanged(FaceDetectionState state);
}

/// 人脸识别视图接口
abstract class IFaceRecognitionView {
  /// 开始人脸检测
  Future<void> startDetection();

  /// 停止人脸检测
  Future<void> stopDetection();

  /// 设置回调
  void setCallback(IFaceRecognitionCallback callback);

  /// 更新配置
  Future<void> updateConfig(FaceRecognitionConfig config);

  /// 获取当前状态
  FaceDetectionState get currentState;
}

/// 人脸识别工厂接口
abstract class IFaceRecognitionFactory {
  /// 创建人脸识别服务实例
  IFaceRecognitionService createService();

  /// 创建人脸识别视图实例
  IFaceRecognitionView createView();

  /// 检查是否支持当前平台
  bool get isSupported;

  /// 获取SDK版本信息
  String get sdkVersion;
}