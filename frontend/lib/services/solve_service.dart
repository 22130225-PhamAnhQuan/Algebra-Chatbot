// lib/services/solve_service.dart
//
// Map tới app/routers/solve_router.py:
//   POST /solve/math
//
// Và app/routers/math_router.py:
//   POST /math/solve
//   POST /math/graph
//
import '../core/api_client.dart';

class SolveResult {
  final String solution;
  final String? steps;
  final String? graphUrl;

  SolveResult({required this.solution, this.steps, this.graphUrl});

  factory SolveResult.fromJson(Map<String, dynamic> j) => SolveResult(
        solution: j['solution']?.toString() ?? j['result']?.toString() ?? '',
        steps:    j['steps']?.toString(),
        graphUrl: j['graph_url']?.toString(),
      );
}

class SolveService {
  final _api = ApiClient();

  // ── POST /solve/math ───────────────────────────────────────────
  // Body: {content, user_id}  (SolveRequest schema)
  // Dùng khi cần lưu lịch sử vào DB theo user

  Future<SolveResult> solveMath({
    required String content,
    required int userId,
  }) async {
    final res = await _api.post(
      '/solve/math',
      {'content': content, 'user_id': userId},
      auth: true,
    );
    return SolveResult.fromJson(res as Map<String, dynamic>);
  }

  // ── POST /math/solve ───────────────────────────────────────────
  // Body: {content}
  // Dùng để giải nhanh, không cần user_id

  Future<SolveResult> quickSolve(String content) async {
    final res = await _api.post('/math/solve', {'content': content}, auth: true);
    return SolveResult.fromJson(res as Map<String, dynamic>);
  }

  // ── POST /math/graph ───────────────────────────────────────────
  // Body: {expression}
  // Returns: URL hoặc base64 của graph image

  Future<String> plotGraph(String expression) async {
    final res = await _api.post(
      '/math/graph',
      {'expression': expression},
      auth: true,
    );
    return res['graph_url']?.toString() ??
        res['image']?.toString() ??
        '';
  }
}
