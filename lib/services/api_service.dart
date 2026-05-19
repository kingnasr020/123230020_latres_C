import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/games_model.dart'; 

class ApiService {
  
  static const String baseUrl = 'https://jsonfakery.com/games/paginated?page=1';

  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil data: $e');
    }
  }
}