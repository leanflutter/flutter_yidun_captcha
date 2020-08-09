import 'package:flutter/services.dart';

import 'yidun_captcha_config.dart';

const _kMethodChannelName = 'flutter_yidun_captcha';
const _kEventChannelName = 'flutter_yidun_captcha/event_channel';

class YidunCaptcha {
  static const MethodChannel _methodChannel =
      const MethodChannel(_kMethodChannelName);
  static const EventChannel _eventChannel =
      const EventChannel(_kEventChannelName);

  static bool _eventChannelReadied = false;

  static Function() _verifyOnReady;
  static Function(dynamic) _verifyOnValidate;
  static Function(dynamic) _verifyOnError;
  static Function() _verifyOnCancel;
  static Function() _verifyOnClose;

  static Future<String> get sdkVersion async {
    final String sdkVersion =
        await _methodChannel.invokeMethod('getSDKVersion');
    return sdkVersion;
  }

  static Future<bool> verify({
    YidunCaptchaConfig config,
    Function() onReady,
    Function(dynamic data) onValidate,
    Function(dynamic data) onError,
    Function() onCancel,
    Function() onClose,
  }) async {
    if (_eventChannelReadied != true) {
      _eventChannel.receiveBroadcastStream().listen(_handleVerifyOnEvent);
      _eventChannelReadied = true;
    }

    _verifyOnReady = onReady;
    _verifyOnValidate = onValidate;
    _verifyOnClose = onClose;

    return await _methodChannel.invokeMethod('verify', config?.toJson());
  }

  static _handleVerifyOnEvent(dynamic event) {
    String method = '${event['method']}';

    switch (method) {
      case 'onReady':
        if (_verifyOnReady != null) _verifyOnReady();
        break;
      case 'onValidate':
        if (_verifyOnValidate != null) _verifyOnValidate(event['data']);
        break;
      case 'onError':
        if (_verifyOnError != null) _verifyOnError(event['data']);
        break;
      case 'onCancel':
        if (_verifyOnCancel != null) _verifyOnCancel();
        break;
      case 'onClose':
        if (_verifyOnClose != null) _verifyOnClose();
        break;
    }
  }
}
