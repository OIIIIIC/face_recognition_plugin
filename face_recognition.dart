/// Face++人脸识别插件 - 统一导出入口
/// 包含状态管理和依赖注入优化

// 核心接口
export 'interfaces/i_face_recognition_service.dart';

// 数据模型
export 'models/face_recognition_models.dart';

// 具体实现
export 'implementations/faceplus_service_impl.dart';

// 视图组件
export 'widgets/face_recognition_view.dart';

// 插件管理
export 'face_recognition_plugin.dart';

// 状态管理（新增）
export 'state/face_recognition_bloc.dart';
export 'state/face_recognition_stream.dart';

// 依赖注入（新增）
export 'di/face_recognition_di.dart';

// 高级示例（新增）
export 'examples/advanced_face_recognition_example.dart';

/// Face++人脸识别插件版本信息
class FaceRecognitionPluginInfo {
  static const String version = '1.0.0';
  static const String name = 'Face Recognition Plugin';
  static const String description = 'Flutter Face++ SDK integration plugin';
  static const String author = 'Flutter Team';
  
  /// 支持的平台
  static const List<String> supportedPlatforms = ['android'];
  
  /// 最低Flutter版本要求
  static const String minFlutterVersion = '3.0.0';
  
  /// 最低Android API级别
  static const int minAndroidApiLevel = 21;
  
  /// 插件特性列表
  static const List<String> features = [
    '人脸检测',
    '活体识别',
    '双目摄像头支持',
    '实时预览',
    '配置管理',
    '错误处理',
    '状态回调',
  ];
  
  /// 获取插件信息摘要
  static Map<String, dynamic> getInfo() {
    return {
      'name': name,
      'version': version,
      'description': description,
      'author': author,
      'supportedPlatforms': supportedPlatforms,
      'minFlutterVersion': minFlutterVersion,
      'minAndroidApiLevel': minAndroidApiLevel,
      'features': features,
    };
  }
}