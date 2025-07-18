/// Face++人脸识别插件 - 状态管理（Bloc模式）
/// 优化建议实现：统一状态管理

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/face_recognition_models.dart';
import '../interfaces/i_face_recognition_service.dart';

/// 人脸识别事件基类
abstract class FaceRecognitionEvent {
  const FaceRecognitionEvent();
}

/// 初始化事件
class FaceRecognitionInitializeEvent extends FaceRecognitionEvent {
  final FaceRecognitionConfig config;
  
  const FaceRecognitionInitializeEvent(this.config);
}

/// 开始检测事件
class FaceRecognitionStartDetectionEvent extends FaceRecognitionEvent {
  const FaceRecognitionStartDetectionEvent();
}

/// 停止检测事件
class FaceRecognitionStopDetectionEvent extends FaceRecognitionEvent {
  const FaceRecognitionStopDetectionEvent();
}

/// 配置更新事件
class FaceRecognitionUpdateConfigEvent extends FaceRecognitionEvent {
  final FaceRecognitionConfig config;
  
  const FaceRecognitionUpdateConfigEvent(this.config);
}

/// 人脸检测结果事件
class FaceRecognitionDetectedEvent extends FaceRecognitionEvent {
  final FaceRecognitionResult result;
  
  const FaceRecognitionDetectedEvent(this.result);
}

/// 活体检测结果事件
class FaceRecognitionLivenessDetectedEvent extends FaceRecognitionEvent {
  final bool isLive;
  final double confidence;
  
  const FaceRecognitionLivenessDetectedEvent(this.isLive, this.confidence);
}

/// 错误事件
class FaceRecognitionErrorEvent extends FaceRecognitionEvent {
  final String message;
  final String? code;
  
  const FaceRecognitionErrorEvent(this.message, {this.code});
}

/// 状态变更事件
class FaceRecognitionStateChangedEvent extends FaceRecognitionEvent {
  final FaceDetectionState state;
  
  const FaceRecognitionStateChangedEvent(this.state);
}

/// 资源释放事件
class FaceRecognitionDisposeEvent extends FaceRecognitionEvent {
  const FaceRecognitionDisposeEvent();
}

/// 人脸识别状态类
class FaceRecognitionState {
  final FaceDetectionState detectionState;
  final FaceRecognitionConfig? config;
  final FaceRecognitionResult? lastResult;
  final bool isInitialized;
  final bool isDetecting;
  final String? errorMessage;
  final String? errorCode;
  final bool isLive;
  final double livenessConfidence;
  final DateTime lastUpdateTime;

  const FaceRecognitionState({
    this.detectionState = FaceDetectionState.initial,
    this.config = const FaceRecognitionConfig(),
    this.lastResult,
    this.isInitialized = false,
    this.isDetecting = false,
    this.errorMessage,
    this.errorCode,
    this.isLive = false,
    this.livenessConfidence = 0.0,
    required this.lastUpdateTime,
  });

  /// 创建初始状态
  factory FaceRecognitionState.initial() {
    return FaceRecognitionState(
      lastUpdateTime: DateTime.now(),
    );
  }

  /// 复制状态并更新部分字段
  FaceRecognitionState copyWith({
    FaceDetectionState? detectionState,
    FaceRecognitionConfig? config,
    FaceRecognitionResult? lastResult,
    bool? isInitialized,
    bool? isDetecting,
    String? errorMessage,
    String? errorCode,
    bool? isLive,
    double? livenessConfidence,
    bool clearError = false,
  }) {
    return FaceRecognitionState(
      detectionState: detectionState ?? this.detectionState,
      config: config ?? this.config,
      lastResult: lastResult ?? this.lastResult,
      isInitialized: isInitialized ?? this.isInitialized,
      isDetecting: isDetecting ?? this.isDetecting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      isLive: isLive ?? this.isLive,
      livenessConfidence: livenessConfidence ?? this.livenessConfidence,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// 是否有错误
  bool get hasError => errorMessage != null;

  /// 是否可以开始检测
  bool get canStartDetection => isInitialized && !isDetecting && !hasError;

  /// 是否可以停止检测
  bool get canStopDetection => isInitialized && isDetecting;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FaceRecognitionState &&
        other.detectionState == detectionState &&
        other.config == config &&
        other.lastResult == lastResult &&
        other.isInitialized == isInitialized &&
        other.isDetecting == isDetecting &&
        other.errorMessage == errorMessage &&
        other.errorCode == errorCode &&
        other.isLive == isLive &&
        other.livenessConfidence == livenessConfidence;
  }

  @override
  int get hashCode {
    return Object.hash(
      detectionState,
      config,
      lastResult,
      isInitialized,
      isDetecting,
      errorMessage,
      errorCode,
      isLive,
      livenessConfidence,
    );
  }

  @override
  String toString() {
    return 'FaceRecognitionState(detectionState: $detectionState, isInitialized: $isInitialized, isDetecting: $isDetecting, hasError: $hasError)';
  }
}

/// 人脸识别 Bloc
class FaceRecognitionBloc {
  final IFaceRecognitionService _service;
  
  // 状态流控制器
  final _stateController = StreamController<FaceRecognitionState>.broadcast();
  final _eventController = StreamController<FaceRecognitionEvent>();
  
  // 当前状态
  FaceRecognitionState _currentState = FaceRecognitionState.initial();
  
  // 事件订阅
  late StreamSubscription _eventSubscription;
  
  /// 构造函数
  FaceRecognitionBloc(this._service) {
    _eventSubscription = _eventController.stream.listen(_handleEvent);
  }

  /// 状态流
  Stream<FaceRecognitionState> get stateStream => _stateController.stream;
  
  /// 当前状态
  FaceRecognitionState get currentState => _currentState;
  
  /// 添加事件
  void add(FaceRecognitionEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  /// 处理事件
  Future<void> _handleEvent(FaceRecognitionEvent event) async {
    try {
      switch (event.runtimeType) {
        case FaceRecognitionInitializeEvent:
          await _handleInitialize(event as FaceRecognitionInitializeEvent);
          break;
        case FaceRecognitionStartDetectionEvent:
          await _handleStartDetection();
          break;
        case FaceRecognitionStopDetectionEvent:
          await _handleStopDetection();
          break;
        case FaceRecognitionUpdateConfigEvent:
          await _handleUpdateConfig(event as FaceRecognitionUpdateConfigEvent);
          break;
        case FaceRecognitionDetectedEvent:
          _handleDetected(event as FaceRecognitionDetectedEvent);
          break;
        case FaceRecognitionLivenessDetectedEvent:
          _handleLivenessDetected(event as FaceRecognitionLivenessDetectedEvent);
          break;
        case FaceRecognitionErrorEvent:
          _handleError(event as FaceRecognitionErrorEvent);
          break;
        case FaceRecognitionStateChangedEvent:
          _handleStateChanged(event as FaceRecognitionStateChangedEvent);
          break;
        case FaceRecognitionDisposeEvent:
          await _handleDispose();
          break;
        default:
          debugPrint('未知事件类型: ${event.runtimeType}');
      }
    } catch (e, stackTrace) {
      debugPrint('处理事件时发生错误: $e');
      debugPrint('堆栈跟踪: $stackTrace');
      _emitState(_currentState.copyWith(
        errorMessage: '处理事件时发生错误: $e',
        errorCode: 'EVENT_HANDLING_ERROR',
      ));
    }
  }

  /// 处理初始化
  Future<void> _handleInitialize(FaceRecognitionInitializeEvent event) async {
    _emitState(_currentState.copyWith(
      detectionState: FaceDetectionState.detecting,
      config: event.config,
      clearError: true,
    ));

    try {
      final success = await _service.initialize(event.config);
      if (success) {
        _emitState(_currentState.copyWith(
          isInitialized: true,
          detectionState: FaceDetectionState.initial,
        ));
      } else {
        _emitState(_currentState.copyWith(
          errorMessage: '初始化失败',
          errorCode: 'INITIALIZATION_FAILED',
          detectionState: FaceDetectionState.failed,
        ));
      }
    } catch (e) {
      _emitState(_currentState.copyWith(
        errorMessage: '初始化异常: $e',
        errorCode: 'INITIALIZATION_EXCEPTION',
        detectionState: FaceDetectionState.failed,
      ));
    }
  }

  /// 处理开始检测
  Future<void> _handleStartDetection() async {
    if (!_currentState.canStartDetection) {
      _emitState(_currentState.copyWith(
        errorMessage: '无法开始检测：状态不允许',
        errorCode: 'INVALID_STATE_FOR_START',
      ));
      return;
    }

    _emitState(_currentState.copyWith(
      isDetecting: true,
      detectionState: FaceDetectionState.detecting,
      clearError: true,
    ));

    try {
      // 注意：IFaceRecognitionService 接口没有 startDetection 方法
      // 这里应该通过视图组件来启动检测
      // await _service.startDetection();
    } catch (e) {
      _emitState(_currentState.copyWith(
        isDetecting: false,
        errorMessage: '开始检测失败: $e',
        errorCode: 'START_DETECTION_FAILED',
        detectionState: FaceDetectionState.failed,
      ));
    }
  }

  /// 处理停止检测
  Future<void> _handleStopDetection() async {
    if (!_currentState.canStopDetection) {
      _emitState(_currentState.copyWith(
        errorMessage: '无法停止检测：状态不允许',
        errorCode: 'INVALID_STATE_FOR_STOP',
      ));
      return;
    }

    try {
      // 注意：IFaceRecognitionService 接口没有 stopDetection 方法
      // 这里应该通过视图组件来停止检测
      // await _service.stopDetection();
      _emitState(_currentState.copyWith(
        isDetecting: false,
        detectionState: FaceDetectionState.initial,
        clearError: true,
      ));
    } catch (e) {
      _emitState(_currentState.copyWith(
        errorMessage: '停止检测失败: $e',
        errorCode: 'STOP_DETECTION_FAILED',
      ));
    }
  }

  /// 处理配置更新
  Future<void> _handleUpdateConfig(FaceRecognitionUpdateConfigEvent event) async {
    try {
      // 注意：IFaceRecognitionService 接口没有 updateConfig 方法
      // 配置更新应该通过重新初始化来实现
      await _service.initialize(event.config);
      _emitState(_currentState.copyWith(
        config: event.config,
        clearError: true,
      ));
    } catch (e) {
      _emitState(_currentState.copyWith(
        errorMessage: '更新配置失败: $e',
        errorCode: 'UPDATE_CONFIG_FAILED',
      ));
    }
  }

  /// 处理人脸检测结果
  void _handleDetected(FaceRecognitionDetectedEvent event) {
    _emitState(_currentState.copyWith(
      lastResult: event.result,
      detectionState: FaceDetectionState.success,
      clearError: true,
    ));
  }

  /// 处理活体检测结果
  void _handleLivenessDetected(FaceRecognitionLivenessDetectedEvent event) {
    _emitState(_currentState.copyWith(
      isLive: event.isLive,
      livenessConfidence: event.confidence,
      detectionState: event.isLive ? FaceDetectionState.livenessSuccess : FaceDetectionState.livenessDetecting,
      clearError: true,
    ));
  }

  /// 处理错误
  void _handleError(FaceRecognitionErrorEvent event) {
    _emitState(_currentState.copyWith(
      errorMessage: event.message,
      errorCode: event.code,
      detectionState: FaceDetectionState.failed,
      isDetecting: false,
    ));
  }

  /// 处理状态变更
  void _handleStateChanged(FaceRecognitionStateChangedEvent event) {
    _emitState(_currentState.copyWith(
      detectionState: event.state,
    ));
  }

  /// 处理资源释放
  Future<void> _handleDispose() async {
    try {
      await _service.dispose();
      _emitState(_currentState.copyWith(
        isInitialized: false,
        isDetecting: false,
        detectionState: FaceDetectionState.initial,
        clearError: true,
      ));
    } catch (e) {
      debugPrint('释放资源时发生错误: $e');
    }
  }

  /// 发射新状态
  void _emitState(FaceRecognitionState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      if (!_stateController.isClosed) {
        _stateController.add(newState);
      }
    }
  }

  /// 清理错误状态
  void clearError() {
    _emitState(_currentState.copyWith(clearError: true));
  }

  /// 重置状态
  void reset() {
    _emitState(FaceRecognitionState.initial());
  }

  /// 释放资源
  Future<void> dispose() async {
    await _eventSubscription.cancel();
    await _eventController.close();
    await _stateController.close();
  }
}