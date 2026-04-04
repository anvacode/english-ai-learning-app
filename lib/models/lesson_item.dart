import 'package:flutter/material.dart';

/// Ítem individual dentro de una lección.
/// Representa una instancia específica del concepto (ej. el color rojo).
class LessonItem {
  final String id;
  final String title;
  final Color? stimulusColor;
  final String? stimulusImageAsset;
  final String? stimulusText;
  final List<String> options;
  final int correctAnswerIndex;

  LessonItem({
    required this.id,
    required this.title,
    this.stimulusColor,
    this.stimulusImageAsset,
    this.stimulusText,
    required this.options,
    required this.correctAnswerIndex,
  });
}
