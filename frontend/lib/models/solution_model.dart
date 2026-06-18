import 'dart:convert';

import 'package:flutter/cupertino.dart';

class SolutionModel {
  final int? conversationId;
  final int? problemId;
  final String result;
  final List<StepModel> steps;
  final String latex;
  final String? image;
  final String? solver;
  final String? type;
  final Map<String, dynamic>? features;

  SolutionModel({
    this.conversationId,
    this.problemId,
    required this.result,
    required this.steps,
    required this.latex,
    this.image,
    this.solver,
    this.type,
    this.features,
  });

  factory SolutionModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json['solution'] ?? json;

    var rawSteps = data['steps_latex'] ?? data['steps'];


    if (rawSteps is String) {
      String cleanStr = rawSteps.trim();
      if (cleanStr.startsWith('[') && cleanStr.endsWith(']')) {
        try {
          String safeStr = cleanStr.replaceAll(r'\', r'\\');

          safeStr = safeStr.replaceAll(r'\\\\', r'\\').replaceAll(r'\\\\', r'\\');

          rawSteps = jsonDecode(safeStr);

        } catch (e) {
          debugPrint("jsonDecode thất bại, dùng phương pháp cắt chuỗi thủ công: $e");

          String content = cleanStr.substring(1, cleanStr.length - 1).trim();

          if (content.startsWith('"') && content.endsWith('"')) {
            content = content.substring(1, content.length - 1);
            List<String> items = content.split('", "');
            rawSteps = items.map((e) => e.replaceAll(r'\"', '"').replaceAll(r'\\', r'\')).toList();
          } else {
            rawSteps = [cleanStr];
          }
        }
      }
    }

    List<StepModel> parsedSteps = [];

    if (rawSteps is List) {
      parsedSteps = rawSteps.asMap().entries.map((entry) {
        final index = entry.key;
        final s = entry.value;

        if (s is Map<String, dynamic>) {
          return StepModel.fromJson(s);
        }

        return StepModel(
          stepNumber: index + 1,
          description: '',
          latex: s.toString(),
        );
      }).toList();
    }
    else if (rawSteps is String) {
      parsedSteps = rawSteps
          .split('\n')
          .where((e) => e.trim().isNotEmpty)
          .toList()
          .asMap()
          .entries
          .map((entry) => StepModel(
        stepNumber: entry.key + 1,
        description: entry.value.trim(),
        latex: entry.value.trim(),
      ))
          .toList();
    }

    return SolutionModel(
      conversationId: json['conversation_id'] is int ? json['conversation_id'] : null,
      problemId: json['problem_id'] is int ? json['problem_id'] : null,
      result: data['result']?.toString() ?? "",
      steps: parsedSteps,
      latex: data['latex']?.toString() ?? "",
      image: data['graph_image']?.toString() ?? data['image']?.toString(),
      solver: data['solver']?.toString(),
      type: data['type']?.toString(),
      features: data['features'] is Map<String, dynamic> ? data['features'] : null,
    );
  }

  bool get isGraph {
    return hasImage;
  }

  bool get hasImage {
    return image != null && image!.isNotEmpty;
  }
}

class StepModel {
  final int stepNumber;
  final String description;
  final String latex;

  StepModel({
    required this.stepNumber,
    required this.description,
    required this.latex,
  });

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      stepNumber: json['step_number'] ?? 0,
      description: json['description']?.toString() ?? "",
      latex: json['latex']?.toString() ?? "",
    );
  }
}