import 'package:shared_preferences/shared_preferences.dart';

// 保存用户分数和BPI到SharedPreferences
Future<void> saveUserScore(
    String songTitle, String difficultyLevel, int score, num bpi) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final key = '${songTitle}_$difficultyLevel';
  await prefs.setString('${key}_score', score.toString());
  await prefs.setDouble('${key}_bpi', bpi.toDouble());
}

// 获取用户分数
Future<int?> getUserScore(String songTitle, String difficultyLevel) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final key = '${songTitle}_$difficultyLevel';
  final scoreStr = prefs.getString('${key}_score');
  if (scoreStr != null) {
    return int.tryParse(scoreStr);
  }
  return null;
}

// 获取用户BPI
Future<double?> getUserBPI(String songTitle, String difficultyLevel) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final key = '${songTitle}_$difficultyLevel';
  return prefs.getDouble('${key}_bpi');
}
