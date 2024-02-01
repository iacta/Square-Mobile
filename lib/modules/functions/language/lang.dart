import 'tradutions/message.dart';

class Translations {
  final Map<String, String> _translations = {};

  Translations.fromMap(Map<String, dynamic> map) {
    map.forEach((key, value) {
      if (value is String) {
        _translations[key] = value;
      } else if (value is List) {
        _translations[key] = value.join('\n');
      } else if (value is Map) {
        value.forEach((nestedKey, nestedValue) {
          _translations['${key}_$nestedKey'] = nestedValue;
        });
      }
    });
  }

  String get(String key, String locale) {
    return _translations['${key}_$locale'] ?? '';
  }
}

String translate(String locale, String type, String message) {
  final Map<String, dynamic>? translationMap = {
    'upload': upload,
    'messages': messages,
    'plan': infoUser,
    'appInfo': appInfo,
    'input': input,
    'commit': commit,
    'page1': page1Screen,
    'page2': page2Screen,
    'pageLogin': pageLoginScreen,
    'config': config,
    'bot': bot,
    'deploy': deploy,
    'fileDelete': fileDelete,
    'help': help,
    'load': load,
    'greetings': greetings,
    'hours': hours,
    'footer': footer,
    'months': months,
    'uploadMessages': uploadMessages
  }[type];

  return (translationMap?[locale] as Map<String, String>?)?[message] ?? '';
}
