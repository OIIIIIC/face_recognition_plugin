/// Face++人脸识别插件 - 数据模型定义
/// 第一阶段：基础数据结构

/// 人脸识别结果数据模型
class FaceRecognitionResult {
  /// NV21格式的图像数据
  final List<int> nv21Data;
  
  /// 图像宽度
  final int width;
  
  /// 图像高度
  final int height;
  
  /// 旋转角度
  final int rotation;
  
  /// 是否镜像
  final bool mirror;
  
  /// 裁剪区域（可选）
  final FaceCropRect? cropRect;
  
  /// 检测状态
  final FaceDetectionState state;
  
  /// 置信度分数
  final double? confidence;
  
  /// 错误信息
  final String? errorMessage;

  const FaceRecognitionResult({
    required this.nv21Data,
    required this.width,
    required this.height,
    required this.rotation,
    this.mirror = false,
    this.cropRect,
    required this.state,
    this.confidence,
    this.errorMessage,
  });

  /// 从Map创建实例
  factory FaceRecognitionResult.fromMap(Map<String, dynamic> map) {
    return FaceRecognitionResult(
      nv21Data: List<int>.from(map['nv21Data'] ?? []),
      width: map['width'] ?? 0,
      height: map['height'] ?? 0,
      rotation: map['rotation'] ?? 0,
      mirror: map['mirror'] ?? false,
      cropRect: map['cropRect'] != null 
          ? FaceCropRect.fromMap(map['cropRect']) 
          : null,
      state: FaceDetectionState.values[map['state'] ?? 0],
      confidence: map['confidence']?.toDouble(),
      errorMessage: map['errorMessage'],
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'nv21Data': nv21Data,
      'width': width,
      'height': height,
      'rotation': rotation,
      'mirror': mirror,
      'cropRect': cropRect?.toMap(),
      'state': state.index,
      'confidence': confidence,
      'errorMessage': errorMessage,
    };
  }
}

/// 人脸裁剪区域
class FaceCropRect {
  final int left;
  final int top;
  final int right;
  final int bottom;

  const FaceCropRect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  factory FaceCropRect.fromMap(Map<String, dynamic> map) {
    return FaceCropRect(
      left: map['left'] ?? 0,
      top: map['top'] ?? 0,
      right: map['right'] ?? 0,
      bottom: map['bottom'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'left': left,
      'top': top,
      'right': right,
      'bottom': bottom,
    };
  }
}

/// 人脸检测状态枚举
enum FaceDetectionState {
  /// 初始状态
  initial,
  /// 检测中
  detecting,
  /// 检测成功
  success,
  /// 检测失败
  failed,
  /// 活体检测中
  livenessDetecting,
  /// 活体检测成功
  livenessSuccess,
  /// 活体检测失败
  livenessFailed,
}

/// 人脸识别配置
class FaceRecognitionConfig {
  /// 活体检测阈值
  final double livenessThreshold;
  
  /// 模糊度阈值
  final double blurThreshold;
  
  /// 亮度阈值
  final double brightnessThreshold;
  
  /// 姿态角度阈值
  final double poseThreshold;
  
  /// 是否启用双目摄像头
  final bool enableDualCamera;
  
  /// 检测超时时间（毫秒）
  final int timeoutMs;

  const FaceRecognitionConfig({
    this.livenessThreshold = 0.5,
    this.blurThreshold = 0.7,
    this.brightnessThreshold = 0.3,
    this.poseThreshold = 30.0,
    this.enableDualCamera = false,
    this.timeoutMs = 10000,
  });

  Map<String, dynamic> toMap() {
    return {
      'livenessThreshold': livenessThreshold,
      'blurThreshold': blurThreshold,
      'brightnessThreshold': brightnessThreshold,
      'poseThreshold': poseThreshold,
      'enableDualCamera': enableDualCamera,
      'timeoutMs': timeoutMs,
    };
  }
}