import 'package:flutter/material.dart';
import '../models/pokemon_region.dart'; // Modelo de región
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegionsScreen extends StatelessWidget {
  const RegionsScreen({super.key});

  Future<List<Region>> fetchRegions() async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/region'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Region.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load regions');
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      appBar: AppBar(
        title: const Text(
          'POKEDEX',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(238, 61, 94, 177),
          ),
        ),
        backgroundColor: const Color.fromRGBO(176, 234, 238, 1),
      ),
      body: FutureBuilder<List<Region>>(
        future: fetchRegions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No regions found'));
          } else {
            final regions = snapshot.data!;

           return Padding(
  padding: const EdgeInsets.all(8.0),
  child: GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 2,
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
    ),
    itemCount: regions.length,
    itemBuilder: (context, index) {
      final region = regions[index];
return GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegionDetailsScreen(regionName: region.name),
      ),
    );
  },
  child: AspectRatio(
    aspectRatio: 4 / 3, // Puedes probar con 3/2, 16/9, etc.
    child: Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/regions/${region.name}.jpg',
              fit: BoxFit.cover, // Llena el contenedor manteniendo proporción
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
            ),
            Center(
              child: Text(
                region.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);

    },
  ),
);

          }
        },
      ),
    );
  }
}

class RegionDetailsScreen extends StatelessWidget {
  final String regionName;

  const RegionDetailsScreen({super.key, required this.regionName});

  Future<List<String>> fetchPokemonByRegion(String region) async {
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/region/$region'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final pokedexUrl = data['pokedexes'][0]['url'];
      final pokedexResponse = await http.get(Uri.parse(pokedexUrl));
      final pokedexData = json.decode(pokedexResponse.body);
      final entries = pokedexData['pokemon_entries'] as List;
      return entries.map<String>((entry) {
        final id = entry['entry_number'];
        return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
      }).toList();
    } else {
      throw Exception('Failed to load Pokémon');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4C3),
      appBar: AppBar(
        title: Text('$regionName - Detalles'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<String>>(
        future: fetchPokemonByRegion(regionName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No se encontraron Pokémon para esta región.'),
            );
          } else {
            final pokemonImages = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Región: ${regionName.toUpperCase()}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).orientation == Orientation.landscape ? 4 : 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: pokemonImages.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            pokemonImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
