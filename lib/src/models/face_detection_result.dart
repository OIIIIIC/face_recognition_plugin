import 'face_detection_state.dart';

/// 人脸检测结果
class FaceDetectionResult {
  /// 检测状态
  final FaceDetectionState state;
  
  /// 图像数据
  final List<int>? nv21Data;
  
  /// 图像宽度
  final int? width;
  
  /// 图像高度
  final int? height;
  
  /// 旋转角度
  final int? rotation;
  
  /// 是否镜像
  final bool? mirror;
  
  /// 置信度
  final double? confidence;
  
  /// 裁剪区域
  final Map<String, dynamic>? cropRect;
  
  /// 错误信息
  final String? errorMessage;

  FaceDetectionResult({
    required this.state,
    this.nv21Data,
    this.width,
    this.height,
    this.rotation,
    this.mirror,
    this.confidence,
    this.cropRect,
    this.errorMessage,
  });

  /// 从Map创建结果对象
  factory FaceDetectionResult.fromMap(Map<String, dynamic> map) {
    return FaceDetectionResult(
      state: FaceDetectionState.fromValue(map['state'] ?? 0),
      nv21Data: map['nv21Data'] != null ? List<int>.from(map['nv21Data']) : null,
      width: map['width']?.toInt(),
      height: map['height']?.toInt(),
      rotation: map['rotation']?.toInt(),
      mirror: map['mirror'],
      confidence: map['confidence']?.toDouble(),
      cropRect: map['cropRect'] != null ? Map<String, dynamic>.from(map['cropRect']) : null,
      errorMessage: map['errorMessage'],
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'state': state.value,
      'nv21Data': nv21Data,
      'width': width,
      'height': height,
      'rotation': rotation,
      'mirror': mirror,
      'confidence': confidence,
      'cropRect': cropRect,
      'errorMessage': errorMessage,
    };
  }

  /// 是否检测成功
  bool get isSuccess => state == FaceDetectionState.success;

  /// 是否检测失败
  bool get isFailed => state == FaceDetectionState.failed;

  @override
  String toString() {
    return 'FaceDetectionResult{state: $state, confidence: $confidence, errorMessage: $errorMessage}';
  }
}