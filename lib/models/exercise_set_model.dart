import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'exercise_set_model.freezed.dart';
part 'exercise_set_model.g.dart';

@freezed
class ExerciseSet with _$ExerciseSet {
  const factory ExerciseSet({
    required bool v2,
    required String author,
    required String description,
    required String id,
    required String name,
    required String repetitionType,
    required List<String> types,
    required List<Map<String, dynamic>> warmups,
    required String video,
    required String videoThumbnail,
  }) = _ExerciseSet;

  factory ExerciseSet.fromJson(Map<String, Object?> json) =>
      _$ExerciseSetFromJson(json);
}
