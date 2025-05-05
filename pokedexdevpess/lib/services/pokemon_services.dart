import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pokemon_basic.dart';
import '../models/pokemon_detail.dart';
import '../models/pokemon_region.dart'; // Importa el modelo de la región

class PokemonService {
  final String _baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<PokemonBasic>> fetchPokemonBasics() async {
    final url = Uri.parse('$_baseUrl/pokemon?limit=20');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((p) => PokemonBasic.fromJson(p)).toList();
    } else {
      throw Exception('No se pudo cargar la lista de Pokémon');
    }
  }

  Future<PokemonDetail> fetchPokemonDetail(int id) async {
    final url = Uri.parse('$_baseUrl/pokemon/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PokemonDetail.fromJson(data);
    } else {
      throw Exception('No se pudo cargar el detalle del Pokémon');
    }
  }

  Future<List<Region>> fetchRegions() async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/region'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Region.fromJson(json)).toList();
    } else {
      throw Exception('No se pudo cargar las regiones');
    }
  }
}
