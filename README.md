# Face++ 人脸识别 Flutter 插件

一个基于 Face++ SDK 的 Flutter 插件，提供人脸检测、活体识别等功能。

## 📋 目录

- [特性](#特性)
- [为什么选择插件化架构](#为什么选择插件化架构)
- [完整的Face++集成](#完整的face集成)
- [安装和配置](#安装和配置)
- [架构设计](#架构设计)
- [快速开始](#快速开始)
- [API文档](#api文档)
- [迁移指南](#迁移指南)
- [配置说明](#配置说明)
- [常见问题](#常见问题)

## ✨ 特性

- ✅ **人脸检测与识别**: 实时人脸检测和识别
- ✅ **活体检测**: 支持单目/双目活体检测
- ✅ **双目摄像头支持**: 硬件支持时可启用
- ✅ **实时相机预览**: 流畅的相机预览体验
- ✅ **可配置检测参数**: 丰富的配置选项和阈值设置
- ✅ **跨项目复用**: 可直接复制到其他项目使用
- ✅ **插件化架构**: 模块化设计，易于集成和维护
- ✅ **完整Face++集成**: 包含所有必要的SDK文件和配置

## 🤔 为什么选择插件化架构？

相比于官方推荐的 `flutter create --template=plugin` 方式，我们采用了更灵活的插件化架构：

### 优势对比

| 特性         | 官方模板           | 我们的方案           |
| ------------ | ------------------ | -------------------- |
| **复用性**   | 需要发布到 pub.dev | 可直接复制到其他项目 |
| **定制性**   | 结构固定           | 高度可定制           |
| **依赖管理** | 自动处理           | 手动控制，更灵活     |
| **开发效率** | 需要发布流程       | 即时可用             |
| **版本控制** | 依赖外部版本       | 完全自主控制         |

### 跨项目使用方式

#### 方式一：直接复制（推荐）

1. 将整个 `face_recognition` 插件目录复制到新项目的 `lib/plugins/` 下
2. 在新项目的 `pubspec.yaml` 中添加路径依赖：

```yaml
dependencies:
  face_recognition_plugin:
    path: lib/plugins/face_recognition
```

3. 复制必要的 Face++ SDK 文件：
   - 将 `android/app/libs/` 目录下的 `.aar` 和 `.jar` 文件复制到新项目
   - 将 `android/app/src/main/assets/` 目录下的证书文件复制到新项目

#### 方式二：Git Submodule

```bash
# 在新项目根目录执行
git submodule add <repository-url> lib/plugins/face_recognition
```

#### 方式三：发布为独立包

将插件发布到 pub.dev 或私有仓库，然后通过标准依赖方式引入。

## 📦 完整的 Face++ 集成

### Android 端文件结构

```
android/src/main/java/com/fiberhome/face_recognition_plugin/
├── FaceRecognitionPlugin.java          # 主插件类
├── FaceRecognitionService.java         # Face++ 服务封装
├── FaceRecognitionPlatformView.java    # 平台视图实现
├── FaceRecognitionPlatformViewFactory.java # 视图工厂
└── CameraManager.java                  # 相机管理器
```

### 包含的 Face++ 功能

- ✅ Face++ SDK 初始化和配置
- ✅ 相机管理（前置/后置，单目/双目）
- ✅ 人脸检测和活体识别
- ✅ 图像预处理和数据转换
- ✅ 阈值配置和参数调优
- ✅ 错误处理和状态管理

## 🚀 安装和配置

### 1. 添加依赖

在你的 `pubspec.yaml` 文件中添加：

```yaml
dependencies:
  face_recognition_plugin:
    path: lib/plugins/face_recognition  # 本地路径
```

### 2. Android 配置

#### 最低 SDK 版本

确保 `android/app/build.gradle` 中的 `minSdkVersion` 不低于 21：

```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

#### 权限配置

在 `android/app/src/main/AndroidManifest.xml` 中添加：

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
```

#### Face++ SDK 文件

1. **SDK 库文件**：将 Face++ 的 `.aar` 和 `.jar` 文件复制到 `android/app/libs/` 目录
2. **证书文件**：将 Face++ 证书文件 `license.txt` 放到 `android/app/src/main/assets/` 目录
3. **依赖配置**：在 `android/app/build.gradle` 中添加：

```gradle
dependencies {
    implementation fileTree(dir: 'libs', include: ['*.jar', '*.aar'])
}
```

#### ProGuard 配置

如果启用了代码混淆，在 `android/app/proguard-rules.pro` 中添加：

```proguard
# Face++ SDK
-keep class mcv.facepass.** { *; }
-keep class com.megvii.** { *; }
```

## 🏗️ 架构设计

### 核心架构

```
┌─────────────────────────────────────────┐
│              应用层 (App Layer)           │
├──────────────────────────────────────────┤
│          插件API (Plugin API)             │
│  ┌─────────────────────────────────────┐ │
│  │     FaceRecognitionPlugin           │ │
│  │  ┌─────────────┬─────────────────┐  │ │
│  │  │   Factory   │    Manager      │  │ │
│  │  └─────────────┴─────────────────┘  │ │
│  └─────────────────────────────────────┘ │
├──────────────────────────────────────────┤
│         接口层 (Interface Layer)          │
│  ┌─────────────────────────────────────┐ │
│  │  IFaceRecognitionService            │ │
│  │  IFaceRecognitionView               │ │
│  │  IFaceRecognitionCallback           │ │
│  └─────────────────────────────────────┘ │
├──────────────────────────────────────────┤
│        实现层 (Implementation Layer)      │
│  ┌─────────────────────────────────────┐ │
│  │    FacePlusServiceImpl              │ │
│  │    FaceRecognitionView              │ │
│  └─────────────────────────────────────┘ │
├──────────────────────────────────────────┤
│         原生层 (Native Layer)             │
│  ┌─────────────────────────────────────┐ │
│  │      Face++ Android SDK             │ │
│  └─────────────────────────────────────┘ │
└──────────────────────────────────────────┘
```

### 设计原则

1. **接口隔离**: 通过接口抽象核心功能，支持多种SDK实现
2. **依赖注入**: 使用工厂模式和管理器模式管理依赖
3. **单一职责**: 每个类只负责一个特定功能
4. **开闭原则**: 对扩展开放，对修改封闭
5. **配置外部化**: 所有配置参数可外部设置

## 🚀 快速开始

### 基本使用

```dart
import 'package:face_recognition_plugin/face_recognition.dart';

class FaceRecognitionPage extends StatefulWidget {
  @override
  _FaceRecognitionPageState createState() => _FaceRecognitionPageState();
}

class _FaceRecognitionPageState extends State<FaceRecognitionPage> {
  late IFaceRecognitionService _faceService;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initializeFaceRecognition();
  }
  
  Future<void> _initializeFaceRecognition() async {
    // 创建服务实例
    _faceService = FaceRecognitionPluginFactory.createService();
    
    // 配置参数
    final config = FaceRecognitionConfig(
      livenessThreshold: 0.7,
      blurThreshold: 0.8,
      brightnessThreshold: 0.4,
      poseThreshold: 25.0,
      enableDualCamera: false,
      timeoutMs: 12000,
    );
    
    // 初始化服务
    final success = await _faceService.initialize(config);
    
    setState(() {
      _isInitialized = success;
    });
    
    if (!success) {
      print('Face++ 初始化失败');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: Text('人脸识别')),
      body: FaceRecognitionView(
        onFaceDetected: (result) {
          print('检测结果: ${result.state}');
          if (result.state == FaceDetectionState.success) {
            print('检测成功，置信度: ${result.confidence}');
          }
        },
        onError: (error) {
          print('检测错误: $error');
        },
        onInitialized: () {
          print('视图初始化完成');
        },
      ),
    );
  }
  
  @override
  void dispose() {
    _faceService.dispose();
    super.dispose();
  }
}
```

### 高级使用

#### 自定义配置

```dart
final config = FaceRecognitionConfig(
  livenessThreshold: 0.8,        // 活体检测阈值
  blurThreshold: 0.9,            // 模糊度阈值
  brightnessThreshold: 0.3,      // 亮度阈值
  poseThreshold: 20.0,           // 姿态角度阈值
  enableDualCamera: true,        // 启用双目摄像头
  timeoutMs: 15000,              // 检测超时时间
);
```

#### 手动活体检测

```dart
// 获取图像数据（NV21格式）
final Uint8List nv21Data = ...; // 从相机或其他来源获取
final int width = 640;
final int height = 480;
final int rotation = 0;

// 执行活体检测
final bool isLive = await _faceService.checkLiveness(
  FacePlusEntity(
    nv21Data: nv21Data,
    width: width,
    height: height,
    rotation: rotation,
  ),
);

if (isLive) {
  print('检测到活体');
} else {
  print('未检测到活体');
}
```

## 📚 API文档

### 核心接口

#### IFaceRecognitionService

主要的人脸识别服务接口：

```dart
abstract class IFaceRecognitionService {
  // 初始化服务
  Future<bool> initialize(FaceRecognitionConfig config);
  
  // 释放资源
  Future<void> dispose();
  
  // 活体检测
  Future<bool> checkLiveness(FacePlusEntity entity);
  
  // 人脸检测与识别
  Future<FaceRecognitionResult> detectAndRecognize(FacePlusEntity entity);
  
  // 获取当前配置
  Future<FaceRecognitionConfig> getConfig();
  
  // 更新配置
  Future<bool> updateConfig(FaceRecognitionConfig config);
  
  // 检查是否已初始化
  Future<bool> isInitialized();
  
  // 检查设备是否支持双目摄像头
  Future<bool> supportsDualCamera();
  
  // 获取SDK版本
  Future<String> getSdkVersion();
  
  // 检查设备支持
  Future<bool> isDeviceSupported();
}
```

### 数据模型

#### FaceRecognitionConfig

人脸识别配置参数。

```dart
class FaceRecognitionConfig {
  final double livenessThreshold;     // 活体检测阈值 (0.0-1.0)
  final double blurThreshold;         // 模糊度阈值 (0.0-1.0)
  final double brightnessThreshold;   // 亮度阈值 (0.0-1.0)
  final double poseThreshold;         // 姿态角度阈值 (度)
  final bool enableDualCamera;        // 是否启用双目摄像头
  final int timeoutMs;                // 检测超时时间 (毫秒)
}
```

#### FaceRecognitionResult

```dart
class FaceRecognitionResult {
  final Uint8List nv21Data;           // NV21图像数据
  final int width;                    // 图像宽度
  final int height;                   // 图像高度
  final int rotation;                 // 旋转角度
  final FaceDetectionState state;     // 检测状态
  final double? confidence;           // 置信度
  final FaceCropRect? cropRect;       // 裁剪区域
  final String? errorMessage;         // 错误信息
}
```

## 🔄 迁移指南

### 从原有代码迁移

如果你正在从原有的 Face++ 集成代码迁移到这个插件，请按照以下步骤：

#### 1. 替换导入

**原来：**

```dart
import '../components/facePlus/FacePlusView.dart';
import '../bridge/FaceInfoBridge.dart';
```

**现在：**

```dart
import 'package:face_recognition_plugin/face_recognition.dart';
```

#### 2. 替换视图组件

**原来：**

```dart
FacePlusView(
  onResult: (result) {
    // 处理结果
  },
)
```

**现在：**

```dart
FaceRecognitionView(
  onFaceDetected: (result) {
    // 处理结果
  },
)
```

#### 3. 替换服务调用

**原来：**

```dart
FaceInfoBridge.checkLiveness(data);
```

**现在：**

```dart
final service = FaceRecognitionPluginFactory.createService();
await service.checkLiveness(entity);
```

### 迁移检查清单

- [ ] 已安装插件依赖
- [ ] 已配置 Android 权限
- [ ] 已复制 Face++ SDK 文件
- [ ] 已复制证书文件
- [ ] 已更新导入语句
- [ ] 已替换视图组件
- [ ] 已替换服务调用
- [ ] 已测试基本功能
- [ ] 已测试错误处理

## ⚙️ 配置说明

### 推荐配置

#### 高精度模式

```dart
const highAccuracyConfig = FaceRecognitionConfig(
  livenessThreshold: 0.8,
  blurThreshold: 0.9,
  brightnessThreshold: 0.5,
  poseThreshold: 20.0,
  enableDualCamera: true,
  timeoutMs: 20000,
);
```

#### 快速模式

```dart
const fastModeConfig = FaceRecognitionConfig(
  livenessThreshold: 0.6,
  blurThreshold: 0.7,
  brightnessThreshold: 0.3,
  poseThreshold: 35.0,
  enableDualCamera: false,
  timeoutMs: 8000,
);
```

#### 高安全要求

```dart
FaceRecognitionConfig(
  livenessThreshold: 0.9,
  blurThreshold: 0.9,
  brightnessThreshold: 0.5,
  poseThreshold: 15.0,
  enableDualCamera: true,
  timeoutMs: 10000,
)
```

### 参数调优指南

1. **livenessThreshold**: 活体检测阈值
   - 0.5-0.6: 宽松模式，误识率较高但通过率高
   - 0.7-0.8: 平衡模式，推荐使用
   - 0.8-0.9: 严格模式，安全性高但可能影响用户体验

2. **blurThreshold**: 模糊度阈值
   - 0.6-0.7: 允许轻微模糊
   - 0.8-0.9: 要求清晰图像

3. **poseThreshold**: 姿态角度阈值
   - 15-20度: 严格要求正脸
   - 25-30度: 平衡模式
   - 35-45度: 宽松模式

## ❓ 常见问题

### Q: 为什么没有使用官方插件模板？

A: 我们选择了更灵活的插件化架构，原因如下：

1. **即时可用**: 无需发布流程，直接复制即可使用
2. **完全控制**: 包含所有 Face++ 相关代码，无外部依赖
3. **高度定制**: 可根据项目需求自由修改
4. **版本自主**: 不依赖外部版本管理

### Q: 插件如何在其他项目中复用？

A: 非常简单：

1. 复制整个插件目录到新项目
2. 在 `pubspec.yaml` 中添加路径依赖
3. 复制 Face++ SDK 文件和证书
4. 按照文档配置权限

### Q: 插件包含完整的 Face++ 功能吗？

A: 是的，插件包含：

- ✅ 完整的 Face++ SDK 封装
- ✅ 相机管理和预览
- ✅ 人脸检测和活体识别
- ✅ 配置管理和错误处理
- ✅ 所有原有功能的插件化实现

### Q: 插件初始化失败怎么办？

A: 请检查以下几点：

1. Face++ SDK 文件是否正确放置在 `android/app/libs/` 目录
2. 证书文件是否放置在 `android/app/src/main/assets/` 目录
3. 证书是否有效且未过期
4. 设备是否支持 Face++ SDK

### Q: 相机预览显示黑屏？

A: 可能的原因：

1. 相机权限未授予
2. 相机被其他应用占用
3. 设备不支持所请求的相机参数

### Q: 检测准确率不高？

A: 建议：

1. 调整检测阈值参数
2. 确保光照条件良好
3. 提示用户保持人脸正对相机
4. 启用双目摄像头（如果硬件支持）

## 🔒 风险控制

### 多线程安全

- 所有 Face++ SDK 调用都在后台线程执行
- UI 更新通过主线程进行
- 使用线程安全的数据结构

### 资源释放

- 自动管理相机资源生命周期
- 页面销毁时自动释放 Face++ SDK 资源
- 内存泄漏检测和预防

### 错误处理

- 完善的异常捕获和处理
- 用户友好的错误提示
- 自动重试机制

## 📋 插件信息

- **版本**: 1.0.0
- **作者**: Fiberhome Team
- **许可证**: MIT
- **支持平台**: Android (iOS 计划中)
- **最低 Flutter 版本**: 3.0.0
- **最低 Android 版本**: API 21 (Android 5.0)
- **特性**: 完整 Face++ 集成、跨项目复用、插件化架构

## 🤝 贡献

欢迎提交Issue和Pull Request来改进这个插件。

## 📞 支持

如有问题，请通过以下方式联系：

- 提交GitHub Issue
- 发送邮件至开发团队
- 查看项目Wiki文档
