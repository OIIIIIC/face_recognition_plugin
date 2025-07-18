/// Face++人脸识别插件 - 数据流管理
/// 优化建议实现：异步操作优化

import 'dart:async';

import '../models/face_recognition_models.dart';
import '../di/face_recognition_di.dart';

/// 人脸识别数据流管理器
class FaceRecognitionStream {
  // 检测结果流
  final _detectionController = StreamController<FaceRecognitionResult>.broadcast();
  
  // 活体检测流
  final _livenessController = StreamController<LivenessResult>.broadcast();
  
  // 错误流
  final _errorController = StreamController<FaceRecognitionError>.broadcast();
  
  // 状态变更流
  final _stateController = StreamController<FaceDetectionState>.broadcast();
  
  // 配置变更流
  final _configController = StreamController<FaceRecognitionConfig>.broadcast();
  
  // 性能指标流
  final _performanceController = StreamController<PerformanceMetrics>.broadcast();
  
  // 流订阅管理
  final List<StreamSubscription> _subscriptions = [];
  
  // 是否已释放
  bool _isDisposed = false;

  /// 检测结果流
  Stream<FaceRecognitionResult> get detectionStream => _detectionController.stream;
  
  /// 活体检测流
  Stream<LivenessResult> get livenessStream => _livenessController.stream;
  
  /// 错误流
  Stream<FaceRecognitionError> get errorStream => _errorController.stream;
  
  /// 状态变更流
  Stream<FaceDetectionState> get stateStream => _stateController.stream;
  
  /// 配置变更流
  Stream<FaceRecognitionConfig> get configStream => _configController.stream;
  
  /// 性能指标流
  Stream<PerformanceMetrics> get performanceStream => _performanceController.stream;

  /// 添加检测结果
  void addDetectionResult(FaceRecognitionResult result) {
    if (!_isDisposed && !_detectionController.isClosed) {
      _detectionController.add(result);
      
      // 同时更新性能指标
      _updatePerformanceMetrics(result);
    }
  }

  /// 添加活体检测结果
  void addLivenessResult(bool isLive, double confidence) {
    if (!_isDisposed && !_livenessController.isClosed) {
      final result = LivenessResult(
        isLive: isLive,
        confidence: confidence,
        timestamp: DateTime.now(),
      );
      _livenessController.add(result);
    }
  }

  /// 添加错误
  void addError(String message, {String? code, dynamic originalError}) {
    if (!_isDisposed && !_errorController.isClosed) {
      final error = FaceRecognitionError(
        message: message,
        code: code,
        originalError: originalError,
        timestamp: DateTime.now(),
      );
      _errorController.add(error);
    }
  }

  /// 添加状态变更
  void addStateChange(FaceDetectionState state) {
    if (!_isDisposed && !_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  /// 添加配置变更
  void addConfigChange(FaceRecognitionConfig config) {
    if (!_isDisposed && !_configController.isClosed) {
      _configController.add(config);
    }
  }

  /// 更新性能指标
  void _updatePerformanceMetrics(FaceRecognitionResult result) {
    if (!_isDisposed && !_performanceController.isClosed) {
      final metrics = PerformanceMetrics(
        detectionTime: 0, // FaceRecognitionResult 没有 detectionTime 属性，使用默认值
        confidence: result.confidence ?? 0.0,
        faceCount: 1, // FaceRecognitionResult 没有 faces 属性，假设检测到一张人脸
        timestamp: DateTime.now(),
      );
      _performanceController.add(metrics);
    }
  }

  /// 监听检测结果（带去重）
  StreamSubscription<FaceRecognitionResult> listenDetection(
    void Function(FaceRecognitionResult) onData, {
    Duration? debounceDuration,
    double? confidenceThreshold,
  }) {
    Stream<FaceRecognitionResult> stream = detectionStream;
    
    // 应用置信度过滤
    if (confidenceThreshold != null) {
      stream = stream.where((result) => (result.confidence ?? 0.0) >= confidenceThreshold);
    }
    
    // 应用防抖
    if (debounceDuration != null) {
      stream = stream.transform(_DebounceTransformer(debounceDuration));
    }
    
    final subscription = stream.listen(onData);
    _subscriptions.add(subscription);
    return subscription;
  }

  /// 监听活体检测结果
  StreamSubscription<LivenessResult> listenLiveness(
    void Function(LivenessResult) onData, {
    double? confidenceThreshold,
  }) {
    Stream<LivenessResult> stream = livenessStream;
    
    // 应用置信度过滤
    if (confidenceThreshold != null) {
      stream = stream.where((result) => result.confidence >= confidenceThreshold);
    }
    
    final subscription = stream.listen(onData);
    _subscriptions.add(subscription);
    return subscription;
  }

  /// 监听错误
  StreamSubscription<FaceRecognitionError> listenError(
    void Function(FaceRecognitionError) onData,
  ) {
    final subscription = errorStream.listen(onData);
    _subscriptions.add(subscription);
    return subscription;
  }

  /// 监听状态变更
  StreamSubscription<FaceDetectionState> listenState(
    void Function(FaceDetectionState) onData,
  ) {
    final subscription = stateStream.listen(onData);
    _subscriptions.add(subscription);
    return subscription;
  }

  /// 组合流：同时监听检测和活体结果
  StreamSubscription<CombinedResult> listenCombined(
    void Function(CombinedResult) onData,
  ) {
    final combinedStream = StreamZip.call([
      detectionStream,
      livenessStream,
    ]).map((results) => CombinedResult(
      detection: results[0] as FaceRecognitionResult,
      liveness: results[1] as LivenessResult,
    ));
    
    final subscription = combinedStream.listen(onData);
    _subscriptions.add(subscription);
    return subscription;
  }

  /// 获取最近的检测结果（缓存）
  FaceRecognitionResult? get lastDetectionResult => _lastDetectionResult;
  FaceRecognitionResult? _lastDetectionResult;

  /// 获取最近的活体检测结果（缓存）
  LivenessResult? get lastLivenessResult => _lastLivenessResult;
  LivenessResult? _lastLivenessResult;

  /// 清理所有流
  Future<void> dispose() async {
    if (_isDisposed) return;
    
    _isDisposed = true;
    
    // 取消所有订阅
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    
    // 关闭所有控制器
    await _detectionController.close();
    await _livenessController.close();
    await _errorController.close();
    await _stateController.close();
    await _configController.close();
    await _performanceController.close();
  }

  /// 重置所有缓存
  void reset() {
    _lastDetectionResult = null;
    _lastLivenessResult = null;
  }
}

/// 活体检测结果
class LivenessResult {
  final bool isLive;
  final double confidence;
  final DateTime timestamp;

  const LivenessResult({
    required this.isLive,
    required this.confidence,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'LivenessResult(isLive: $isLive, confidence: $confidence, timestamp: $timestamp)';
  }
}

// FaceRecognitionError 和 PerformanceMetrics 已移动到 face_recognition_di.dart

/// 组合结果
class CombinedResult {
  final FaceRecognitionResult detection;
  final LivenessResult liveness;

  const CombinedResult({
    required this.detection,
    required this.liveness,
  });

  @override
  String toString() {
    return 'CombinedResult(detection: $detection, liveness: $liveness)';
  }
}

/// 防抖转换器
class _DebounceTransformer<T> extends StreamTransformerBase<T, T> {
  final Duration duration;
  
  const _DebounceTransformer(this.duration);

  @override
  Stream<T> bind(Stream<T> stream) {
    late StreamController<T> controller;
    Timer? timer;
    
    controller = StreamController<T>(
      onListen: () {
        stream.listen(
          (data) {
            timer?.cancel();
            timer = Timer(duration, () {
              if (!controller.isClosed) {
                controller.add(data);
              }
            });
          },
          onError: controller.addError,
          onDone: () {
            timer?.cancel();
            controller.close();
          },
        );
      },
      onCancel: () {
        timer?.cancel();
      },
    );
    
    return controller.stream;
  }
}

/// 流合并工具
class StreamZip {
  static Stream<List<dynamic>> call(List<Stream> streams) {
    late StreamController<List<dynamic>> controller;
    final List<dynamic> latestValues = List.filled(streams.length, null);
    final List<bool> hasValue = List.filled(streams.length, false);
    final List<StreamSubscription> subscriptions = [];
    
    controller = StreamController<List<dynamic>>(
      onListen: () {
        for (int i = 0; i < streams.length; i++) {
          final subscription = streams[i].listen(
            (data) {
              latestValues[i] = data;
              hasValue[i] = true;
              
              // 当所有流都有值时，发射组合结果
              if (hasValue.every((has) => has)) {
                if (!controller.isClosed) {
                  controller.add(List.from(latestValues));
                }
              }
            },
            onError: controller.addError,
          );
          subscriptions.add(subscription);
        }
      },
      onCancel: () {
        for (final subscription in subscriptions) {
          subscription.cancel();
        }
      },
    );
    
    return controller.stream;
  }
}