import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _storageKey = 'weekly-rhythm-data';

  Future<Map<String, dynamic>?> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    // Check new key or legacy key for seamless upgrade
    final localJson = prefs.getString(_storageKey) ?? prefs.getString('keke-schedule');

    if (localJson != null && localJson.isNotEmpty) {
      try {
        final parsed = jsonDecode(localJson);
        if (parsed is Map<String, dynamic>) {
          return parsed;
        }
      } catch (e) {
        debugPrint("Local storage read error: $e");
      }
    }
    return null;
  }

  Future<void> saveData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(data);
    await prefs.setString(_storageKey, jsonStr);
  }

  Future<int> getStorageSizeBytes() async {
    final prefs = await SharedPreferences.getInstance();
    final localJson = prefs.getString(_storageKey) ?? '';
    return localJson.length;
  }
}
