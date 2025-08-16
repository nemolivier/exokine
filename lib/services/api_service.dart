
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercise.dart';
import '../models/protocol.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:3000/api';

  Future<List<Exercise>> getExercises() async {
    final response = await http.get(Uri.parse('$_baseUrl/exercises'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Exercise.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load exercises');
    }
  }

  Future<List<Protocol>> getProtocols() async {
    final response = await http.get(Uri.parse('$_baseUrl/protocols'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Protocol.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load protocols');
    }
  }

  Future<Protocol> createProtocol(Protocol protocol) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/protocols'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(protocol.toJson()),
    );
    if (response.statusCode == 201) {
      return Protocol.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create protocol');
    }
  }

  Future<void> deleteProtocol(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/protocols/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete protocol');
    }
  }

  Future<void> deleteProtocolExercise(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/protocol-exercises/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete exercise');
    }
  }

  Future<Exercise> createExercise(String name, List<String> articulation, List<String> muscles) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/exercises'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'articulation': articulation, 'muscles': muscles}),
    );
    if (response.statusCode == 201) {
      return Exercise.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create exercise');
    }
  }

  Future<Exercise> updateExercise(Exercise exercise) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/exercises/${exercise.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(exercise.toJson()),
    );
    if (response.statusCode == 200) {
      return Exercise.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update exercise');
    }
  }

  Future<void> deleteExercise(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/exercises/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete exercise');
    }
  }
}
