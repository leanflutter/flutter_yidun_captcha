class YidunCaptchaConfig {
  final String? captchaId;
  final String? mode;
  final int? timeout;
  final String? languageType;
  final bool? hideCloseButton;
  final String? loadingText;

  YidunCaptchaConfig({
    this.captchaId,
    this.mode,
    this.timeout,
    this.languageType,
    this.loadingText,
    this.hideCloseButton,
  });

  Map<String, dynamic> toJson() {
    return {
      'captchaId': captchaId,
      'mode': mode,
      'timeout': timeout,
      'languageType': languageType,
      'loadingText': loadingText,
      'hideCloseButton': hideCloseButton,
    }..removeWhere((key, value) => value == null);
  }
}
