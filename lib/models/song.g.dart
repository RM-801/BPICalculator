// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Song _$SongFromJson(Map<String, dynamic> json) => Song(
      title: json['title'] as String,
      difficulty: json['difficulty'] as String,
      wr: (json['wr'] as num).toInt(),
      avg: (json['avg'] as num).toInt(),
      notes: (json['notes'] as num).toInt(),
      bpm: json['bpm'] as String,
      difficultyLevel: json['difficultyLevel'] as String,
      dpLevel: json['dpLevel'] as String,
      coef: (json['coef'] as num).toDouble(),
    );

Map<String, dynamic> _$SongToJson(Song instance) => <String, dynamic>{
      'title': instance.title,
      'difficulty': instance.difficulty,
      'wr': instance.wr,
      'avg': instance.avg,
      'notes': instance.notes,
      'bpm': instance.bpm,
      'difficultyLevel': instance.difficultyLevel,
      'dpLevel': instance.dpLevel,
      'coef': instance.coef,
    };
