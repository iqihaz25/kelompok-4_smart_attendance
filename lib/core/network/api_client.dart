import 'dart:convert';

class ApiClient {
  final String baseUrl = "https://api.attendoai.com/v1";

  // Simulasi HTTP POST request untuk kebutuhan masa depan
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulasi network latency
    return {
      "status": "success",
      "message": "Data processed successfully",
      "data": data
    };
  }
}
