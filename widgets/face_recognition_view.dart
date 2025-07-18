/// Face++人脸识别插件 - 视图组件实现
/// 第二阶段：可复用视图组件

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import '../interfaces/i_face_recognition_service.dart';
import '../models/face_recognition_models.dart';
import '../implementations/faceplus_service_impl.dart';

/// 人脸识别视图组件
class FaceRecognitionView extends StatefulWidget {
  /// 人脸识别配置
  final FaceRecognitionConfig config;
  
  /// 回调接口
  final IFaceRecognitionCallback? callback;
  
  /// 视图宽度
  final double? width;
  
  /// 视图高度
  final double? height;
  
  /// 是否自动开始检测
  final bool autoStart;

  const FaceRecognitionView({
    Key? key,
    required this.config,
    this.callback,
    this.width,
    this.height,
    this.autoStart = true,
  }) : super(key: key);

  @override
  State<FaceRecognitionView> createState() => _FaceRecognitionViewState();
}

class _FaceRecognitionViewState extends State<FaceRecognitionView>
    implements IFaceRecognitionView, IFaceRecognitionCallback {
  
  static const String _viewType = 'face_recognition_platform_view';
  static const MethodChannel _channel = MethodChannel('face_recognition_view');
  
  IFaceRecognitionService? _service;
  IFaceRecognitionCallback? _callback;
  FaceDetectionState _currentState = FaceDetectionState.initial;
  int? _viewId;

  @override
  void initState() {
    super.initState();
    _callback = widget.callback;
    _initializeService();
  }

  @override
  void dispose() {
    _service?.dispose();
    super.dispose();
  }

  /// 初始化服务
  Future<void> _initializeService() async {
    try {
      _service = FacePlusServiceImpl();
      final success = await _service!.initialize(widget.config);
      
      if (success && widget.autoStart) {
        await startDetection();
      }
    } catch (e) {
      onError('服务初始化失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: _buildPlatformView(),
    );
  }

  /// 构建平台视图
  Widget _buildPlatformView() {
    return PlatformViewLink(
      viewType: _viewType,
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        return PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: _viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: widget.config.toMap(),
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () {
            params.onFocusChanged(true);
          },
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
          ..create();
      },
    );
  }

  /// 平台视图创建完成回调
  void _onPlatformViewCreated(int id) {
    _viewId = id;
    _setupMethodChannel();
  }

  /// 设置方法通道
  void _setupMethodChannel() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// 处理原生方法调用
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onFaceDetected':
        final result = FaceRecognitionResult.fromMap(
          Map<String, dynamic>.from(call.arguments),
        );
        onFaceDetected(result);
        break;
        
      case 'onLivenessDetected':
        final isLive = call.arguments['isLive'] as bool;
        final confidence = (call.arguments['confidence'] as num).toDouble();
        onLivenessDetected(isLive, confidence);
        break;
        
      case 'onError':
        final error = call.arguments['error'] as String;
        final code = call.arguments['code'] as String?;
        onError(error, code: code);
        break;
        
      case 'onStateChanged':
        final stateIndex = call.arguments['state'] as int;
        final state = FaceDetectionState.values[stateIndex];
        onStateChanged(state);
        break;
        
      default:
        print('未知方法调用: ${call.method}');
    }
  }

  // IFaceRecognitionView 接口实现
  
  @override
  Future<void> startDetection() async {
    try {
      await _channel.invokeMethod('startDetection', {'viewId': _viewId});
      onStateChanged(FaceDetectionState.detecting);
    } catch (e) {
      onError('开始检测失败: $e');
    }
  }

  @override
  Future<void> stopDetection() async {
    try {
      await _channel.invokeMethod('stopDetection', {'viewId': _viewId});
      onStateChanged(FaceDetectionState.initial);
    } catch (e) {
      onError('停止检测失败: $e');
    }
  }

  @override
  void setCallback(IFaceRecognitionCallback callback) {
    _callback = callback;
  }

  @override
  Future<void> updateConfig(FaceRecognitionConfig config) async {
    try {
      await _channel.invokeMethod('updateConfig', {
        'viewId': _viewId,
        'config': config.toMap(),
      });
      
      if (_service != null && _service is FacePlusServiceImpl) {
        await (_service as FacePlusServiceImpl).updateConfig(config);
      }
    } catch (e) {
      onError('更新配置失败: $e');
    }
  }

  @override
  FaceDetectionState get currentState => _currentState;

  // IFaceRecognitionCallback 接口实现
  
  @override
  void onFaceDetected(FaceRecognitionResult result) {
    _callback?.onFaceDetected(result);
  }

  @override
  void onLivenessDetected(bool isLive, double confidence) {
    _callback?.onLivenessDetected(isLive, confidence);
  }

  @override
  void onError(String error, {String? code}) {
    _callback?.onError(error, code: code);
  }

  @override
  void onStateChanged(FaceDetectionState state) {
    if (mounted) {
      setState(() {
        _currentState = state;
      });
    }
    _callback?.onStateChanged(state);
  }
}