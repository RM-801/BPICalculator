import 'dart:convert';
import 'dart:io';

void main() async {
  // 读取原始 JSON 文件
  final file = File('assets/data.json');
  final jsonString = await file.readAsString();
  final jsonData = json.decode(jsonString);

  // 处理 body 数组中的每个歌曲对象
  final fixedBody = (jsonData['body'] as List).map((song) {
    // 创建新的歌曲对象，确保数值字段是数字类型
    return {
      'title': song['title'],
      'difficulty': song['difficulty'],
      'wr': int.tryParse(song['wr']?.toString() ?? '0') ?? 0,
      'avg': int.tryParse(song['avg']?.toString() ?? '0') ?? 0,
      'notes': int.tryParse(song['notes']?.toString() ?? '0') ?? 0,
      'bpm': song['bpm'],
      'textage': song['textage'],
      'difficultyLevel': song['difficultyLevel'],
      'dpLevel': song['dpLevel'],
      'coef': double.tryParse(song['coef']?.toString() ?? '0.0') ?? 0.0,
    };
  }).toList();

  // 创建新的 JSON 对象
  final fixedJson = {
    'version': jsonData['version'],
    'lastUpdated': jsonData['lastUpdated'],
    'body': fixedBody,
  };

  // 写入新的 JSON 文件
  final outputFile = File('assets/data_fixed.json');
  await outputFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(fixedJson),
  );

  print('JSON 数据已修复并保存到 assets/data_fixed.json');
} 