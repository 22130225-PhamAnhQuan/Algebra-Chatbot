import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'solution_model.dart';

class HistoryItem {
  final int id;
  final DateTime createdAt;
  final String problemContent;
  final String inputType;
  final String result;
  final List<StepModel> steps;
  final String latex;
  final String? graphImage;
  final int? conversationId;

  HistoryItem({
    required this.id,
    required this.createdAt,
    required this.problemContent,
    required this.inputType,
    required this.result,
    required this.steps,
    required this.latex,
    required this.graphImage,
    required this.conversationId,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    var rawSteps = json['steps'];
    List<StepModel> parsedSteps = [];

    if (rawSteps != null) {
      try {
        if (rawSteps is List) {
          parsedSteps = (rawSteps as List).map((s) {
            if (s is Map<String, dynamic>) {
              return StepModel.fromJson(s);
            } else {
              return StepModel(
                stepNumber: 0,
                description: s.toString(),
                latex: '',
              );
            }
          }).toList();

          for (int i = 0; i < parsedSteps.length; i++) {
            parsedSteps[i] = StepModel(
              stepNumber: i + 1,
              description: parsedSteps[i].description,
              latex: parsedSteps[i].latex,
            );
          }
        } else if (rawSteps is String) {
          try {

            final decoded = jsonDecode(rawSteps);

            if (decoded is List) {

              parsedSteps = decoded.asMap().entries.map((entry) {
                return StepModel(
                  stepNumber: entry.key + 1,
                  description: '',
                  latex: entry.value.toString(),
                );
              }).toList();

            }

          } catch (e) {

            final parts = rawSteps
                .split('|')
                .where((s) => s.trim().isNotEmpty)
                .toList();

            parsedSteps = parts.asMap().entries.map((entry) {
              return StepModel(
                stepNumber: entry.key + 1,
                description: entry.value,
                latex: '',
              );
            }).toList();

          } catch (e) {
            debugPrint("Lỗi parse steps history: $e");
          }
        }
      } catch (e) {
        debugPrint("Lỗi khi parse steps: $e");
      }
    }

    return HistoryItem(
      id: json['id'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      problemContent: json['problem_content'] ?? "Không có nội dung",
      inputType: json['input_type'] ?? "text",
      result: json['result']?.toString() ?? "",
      steps: parsedSteps,
      latex: json['latex'] ?? "",
      graphImage: json['graph_image'],
      conversationId: json['conversation_id'],
    );
  }
}
