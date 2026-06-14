import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../models/solution_model.dart';
import '../core/theme/app_theme.dart';

class SolutionStepsWidget extends StatelessWidget {
  final List<StepModel> steps;
  final String result;

  const SolutionStepsWidget({
    super.key,
    required this.steps,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                "Giải từng bước",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 18),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Container(
                    width: 40,
                    height: 40,

                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),

                    child: Center(
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: step.latex.isNotEmpty
                        ? Math.tex(
                            step.latex,
                            mathStyle: MathStyle.text,
                            textStyle: const TextStyle(fontSize: 18),
                          )
                        : Text(
                            step.description,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            );
          }),

          const Divider(),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 10),

              Expanded(
                child: Math.tex(
                  result,
                  mathStyle: MathStyle.text,
                  textStyle: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
