import 'dart:async';

import 'package:flutter/services.dart';

class FlutterYidunCaptcha {
  static const MethodChannel _channel =
      const MethodChannel('flutter_yidun_captcha');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
