/// Face Recognition Service接口
abstract class IFaceRecognitionService {
  /// 初始化服务
  Future<bool> initialize(Map<String, dynamic> config);

  /// 检查设备是否支持
  Future<bool> isDeviceSupported();

  /// 获取SDK版本
  Future<String> getSdkVersion();

  /// 活体检测
  Future<bool> checkLiveness({
    required List<int> nv21Data,
    required int width,
    required int height,
    required int rotation,
  });

  /// 人脸检测
  Future<Map<String, dynamic>> detectFace({
    required List<int> nv21Data,
    required int width,
    required int height,
    required int rotation,
    required bool mirror,
  });

  /// 更新配置
  Future<bool> updateConfig(Map<String, dynamic> config);

  /// 获取当前配置
  Future<Map<String, dynamic>> getCurrentConfig();

  /// 释放资源
  Future<void> dispose();
}