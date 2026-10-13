import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/fitness_plan.dart';

class ApiService {
  String get baseUrl {
    final v = dotenv.env['API_BASE_URL']?.trim();
    if (v == null || v.isEmpty) throw Exception('Set API_BASE_URL in mobile/.env.');
    return v.replaceFirst(RegExp(r'/$'), '');
  }
  Future<FitnessPlan> generatePlan({
    required int age, required String goal, required String experience,
    required int daysPerWeek, required int minutesPerSession,
    required String equipment, required String limitations,
  }) async {
    final response = await http.post(Uri.parse('$baseUrl/api/fitness-plan'),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({'age':age,'goal':goal,'experience':experience,'daysPerWeek':daysPerWeek,
        'minutesPerSession':minutesPerSession,'equipment':equipment,'limitations':limitations.isEmpty?'None':limitations}),
    ).timeout(const Duration(seconds: 90));
    Map<String,dynamic> body;
    try { body = jsonDecode(response.body) as Map<String,dynamic>; }
    catch (_) { throw Exception('Invalid server response. Is the backend running?'); }
    if (response.statusCode < 200 || response.statusCode >= 300) throw Exception(body['error']?.toString() ?? 'Request failed (${response.statusCode}).');
    if (body['plan'] is! Map<String,dynamic>) throw Exception('No plan found in server response.');
    return FitnessPlan.fromJson(body['plan'] as Map<String,dynamic>);
  }
}
