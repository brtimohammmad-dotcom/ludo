@JS()
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('window')
external JSObject? get jsWindow;

class BaleUserService {

  static String getInitData() {
    try {
      final window = jsWindow;
      if (window == null) return '';

      // دسترسی به Bale.WebApp.initData با بررسی null در هر مرحله
      final bale = window.getProperty('Bale'.toJS);
      if (bale == null) return '';

      final webApp = (bale as JSObject).getProperty('WebApp'.toJS);
      if (webApp == null) return '';

      final initData = (webApp as JSObject).getProperty('initData'.toJS);
      if (initData == null) return '';

      return (initData as JSString).toDart;
    } catch (e) {
      print('Error: $e');
      return '';
    }
  }

  static Future<Map<String, dynamic>> getUserInfo() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final window = jsWindow;
      if (window == null) return _getDefaultUser();

      final bale = window.getProperty('Bale'.toJS);
      if (bale == null) return _getDefaultUser();

      final webApp = (bale as JSObject).getProperty('WebApp'.toJS);
      if (webApp == null) return _getDefaultUser();

      final initDataUnsafe = (webApp as JSObject).getProperty('initDataUnsafe'.toJS);
      if (initDataUnsafe == null) return _getDefaultUser();

      final user = (initDataUnsafe as JSObject).getProperty('user'.toJS);
      if (user == null) return _getDefaultUser();

      final userObj = user as JSObject;

      return {
        'id': (userObj.getProperty('id'.toJS) as JSNumber?)?.toDartInt ?? 0,
        'firstName': (userObj.getProperty('first_name'.toJS) as JSString?)?.toDart ?? '',
        'lastName': (userObj.getProperty('last_name'.toJS) as JSString?)?.toDart ?? '',
        'username': (userObj.getProperty('username'.toJS) as JSString?)?.toDart ?? '',
        'languageCode': (userObj.getProperty('language_code'.toJS) as JSString?)?.toDart ?? 'fa',
      };
    } catch (e) {
      print('Error: $e');
      return _getDefaultUser();
    }
  }

  static Map<String, dynamic> _getDefaultUser() {
    return {
      'id': 0,
      'firstName': 'مهمان',
      'lastName': '',
      'username': '',
      'languageCode': 'fa',
    };
  }
}