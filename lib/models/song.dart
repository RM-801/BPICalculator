import 'package:json_annotation/json_annotation.dart';

part 'song.g.dart';


// 难度映射表
final Map<String, String> difficultyNames = {
  '3': 'SPH',
  '4': 'SPA',
  '10': 'SPL',
  '8': 'DPH',
  '9': 'DPA',
  '11': 'DPL',
};

// 歌曲数据模型
@JsonSerializable()
class Song {
  final String title;
  final String difficulty;
  final int wr;
  final int avg;
  final int notes;
  final String bpm;
  final String difficultyLevel;
  final String dpLevel;
  final double coef;

  Song({
    required this.title,
    required this.difficulty,
    required this.wr,
    required this.avg,
    required this.notes,
    required this.bpm,
    required this.difficultyLevel,
    required this.dpLevel,
    required this.coef,
  });

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);

  Map<String, dynamic> toJson() => _$SongToJson(this);
}