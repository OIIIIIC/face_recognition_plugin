/// 人脸检测状态枚举
enum FaceDetectionState {
  /// 检测中
  detecting(1),
  
  /// 检测成功
  success(2),
  
  /// 检测失败
  failed(3),
  
  /// 超时
  timeout(4),
  
  /// 未知错误
  unknown(0);

  const FaceDetectionState(this.value);
  final int value;

  /// 从整数值创建状态
  static FaceDetectionState fromValue(int value) {
    switch (value) {
      case 1:
        return FaceDetectionState.detecting;
      case 2:
        return FaceDetectionState.success;
      case 3:
        return FaceDetectionState.failed;
      case 4:
        return FaceDetectionState.timeout;
      default:
        return FaceDetectionState.unknown;
    }
  }
}