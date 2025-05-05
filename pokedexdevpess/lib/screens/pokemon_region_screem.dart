import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pokemon_detail_screen.dart';


class Pokemon {
  final int number;
  final String name;

  Pokemon({required this.number, required this.name});
}

class RegionPokemonsScreen extends StatefulWidget {
  final String regionName;
  final String regionUrl;

  const RegionPokemonsScreen({
    super.key,
    required this.regionName,
    required this.regionUrl,
  });

  @override
  State<RegionPokemonsScreen> createState() => _RegionPokemonsScreenState();
}

class _RegionPokemonsScreenState extends State<RegionPokemonsScreen> {
  late Future<List<Pokemon>> _pokemonFuture;
  bool _isGridView = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _pokemonFuture = fetchPokemonNames();

  }

  Future<List<Pokemon>> fetchPokemonNames() async {
    final response = await http.get(Uri.parse(widget.regionUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List pokedexes = data['pokedexes'];

      if (pokedexes.isEmpty) return [];

      final pokedexUrl = pokedexes[0]['url'];
      final pokedexResponse = await http.get(Uri.parse(pokedexUrl));

      if (pokedexResponse.statusCode == 200) {
        final pokedexData = json.decode(pokedexResponse.body);
        final entries = pokedexData['pokemon_entries'] as List;

        return entries
            .map<Pokemon>((entry) => Pokemon(
                  number: entry['entry_number'],
                  name: entry['pokemon_species']['name'],
                ))
            .toList();
      } else {
        throw Exception('Error al cargar Pokédex');
      }
    } else {
      throw Exception('Error al cargar región');
    }
  }

  void _toggleView() {
    setState(() => _isGridView = !_isGridView);
  }

  void _goBack(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: Text(widget.regionName.toUpperCase()),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar Pokémon',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Pokemon>>(
              future: _pokemonFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay Pokémon en esta región.'));
                } else {
                  final filteredList = snapshot.data!
                      .where((pokemon) => pokemon.name.toLowerCase().contains(_searchQuery))
                      .toList();

                  if (_isGridView) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 3 / 2,
                      ),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final pokemon = filteredList[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PokemonDetailScreen(
                                  name: pokemon.name,
                                  number: pokemon.number,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://img.pokemondb.net/sprites/home/normal/${pokemon.name.toLowerCase()}.png',
                                  width: 80,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                ),
                                const SizedBox(height: 8),
                                Text('#${pokemon.number.toString().padLeft(3, '0')} ${pokemon.name.toUpperCase()}'),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final pokemon = filteredList[index];
                        return ListTile(
                          leading: Image.network(
                            'https://img.pokemondb.net/sprites/home/normal/${pokemon.name.toLowerCase()}.png',
                            width: 80,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                          ),
                          title: Text('#${pokemon.number.toString().padLeft(3, '0')} ${pokemon.name.toUpperCase()}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PokemonDetailScreen(
                                  name: pokemon.name,
                                  number: pokemon.number,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleView,
                  icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                  label: Text(_isGridView ? 'Vista Lista' : 'Vista Tarjeta'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _goBack(context),
                  icon: const Icon(Icons.home),
                  label: const Text('Inicio'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
