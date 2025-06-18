import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static Future<void> saveCurrentScreen(String screen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_screen', screen);
  }

  static Future<String?> getCurrentScreen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_screen');
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
