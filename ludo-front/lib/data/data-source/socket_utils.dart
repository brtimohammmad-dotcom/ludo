import 'dart:convert';
import 'package:flutter/foundation.dart';

class SocketUtils {
  static Map<String, dynamic> convertToJSData(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;

    try {
      if (data is Iterable) {
        final list = data.toList();
        if (list.isNotEmpty) {
          final first = list.first;
          try {
            return Map<String, dynamic>.from(first as Map);
          } catch (_) {
            final decoded = jsonDecode(jsonEncode(first));
            if (decoded is Map) {
              return Map<String, dynamic>.from(decoded);
            }
          }
        }
      }

      if (data is Map) {
        return data.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (e) {
      debugPrint('🚨 JSON conversion error: $e');
    }

    return {};
  }
}