import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pokemon_region.dart'; // Modelo de región
import '../screens/pokemon_region_screem.dart'; // NUEVO: Importar la pantalla correcta
import 'package:pokedexdevpess/services/pokemon_services.dart';

class RegionsScreen extends StatelessWidget {
  const RegionsScreen({super.key});

  Future<List<Region>> fetchRegions() async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/region'),
    );

    if (response.statusCode == 200) {
      AudioManager().playLoopedMusic();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_off),
            onPressed: () {
              AudioManager().stopMusic();
            },
          ),
        ],
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
                  crossAxisCount:
                      MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? 3
                          : 2,
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
                          builder:
                              (context) => RegionPokemonsScreen(
                                regionName: region.name,
                                regionUrl: region.url,
                              ),
                        ),
                      );
                    },
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
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
                                fit: BoxFit.cover,
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
