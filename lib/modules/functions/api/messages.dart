import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:square/modules/functions/language/lang.dart';

class Messages {
  static String send(BuildContext context, String key) {
    return translate(context.locale.toString(), 'messages', key);
  }
}
