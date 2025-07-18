import 'i_face_recognition_service.dart';
import 'face_recognition_plugin.dart';

/// Face++ 服务实现
class FacePlusServiceImpl implements IFaceRecognitionService {
  static final FacePlusServiceImpl _instance = FacePlusServiceImpl._internal();
  factory FacePlusServiceImpl() => _instance;
  FacePlusServiceImpl._internal();

  @override
  Future<bool> initialize(Map<String, dynamic> config) async {
    return await FaceRecognitionPlugin.initialize(config);
  }

  @override
  Future<bool> isDeviceSupported() async {
    return await FaceRecognitionPlugin.isDeviceSupported();
  }

  @override
  Future<String> getSdkVersion() async {
    return await FaceRecognitionPlugin.getSdkVersion();
  }

  @override
  Future<bool> checkLiveness({
    required List<int> nv21Data,
    required int width,
    required int height,
    required int rotation,
  }) async {
    return await FaceRecognitionPlugin.checkLiveness(
      nv21Data: nv21Data,
      width: width,
      height: height,
      rotation: rotation,
    );
  }

  @override
  Future<Map<String, dynamic>> detectFace({
    required List<int> nv21Data,
    required int width,
    required int height,
    required int rotation,
    required bool mirror,
  }) async {
    return await FaceRecognitionPlugin.detectFace(
      nv21Data: nv21Data,
      width: width,
      height: height,
      rotation: rotation,
      mirror: mirror,
    );
  }

  @override
  Future<bool> updateConfig(Map<String, dynamic> config) async {
    return await FaceRecognitionPlugin.updateConfig(config);
  }

  @override
  Future<Map<String, dynamic>> getCurrentConfig() async {
    return await FaceRecognitionPlugin.getCurrentConfig();
  }

  @override
  Future<void> dispose() async {
    await FaceRecognitionPlugin.dispose();
  }
}