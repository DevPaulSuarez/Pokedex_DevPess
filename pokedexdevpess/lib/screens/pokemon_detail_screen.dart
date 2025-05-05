import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonDetailScreen extends StatefulWidget {
  final String name;
  final int number;

  const PokemonDetailScreen({
    super.key,
    required this.name,
    required this.number,
  });

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  late Future<Map<String, dynamic>> _pokemonDataFuture;
  late String currentPokemonName;

  @override
  void initState() {
    super.initState();
    currentPokemonName = widget.name.toLowerCase();
    _pokemonDataFuture = fetchPokemonData();
  }

  Future<Map<String, dynamic>> fetchPokemonData() async {
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$currentPokemonName'));
    if (response.statusCode != 200) throw Exception('Failed to load Pokémon data');
    final data = json.decode(response.body);

    final speciesResponse = await http.get(Uri.parse(data['species']['url']));
    if (speciesResponse.statusCode != 200) throw Exception('Failed to load species data');
    final speciesData = json.decode(speciesResponse.body);

    final evolutionChainResponse = await http.get(Uri.parse(speciesData['evolution_chain']['url']));
    if (evolutionChainResponse.statusCode != 200) throw Exception('Failed to load evolution chain');
    final evolutionData = json.decode(evolutionChainResponse.body);

    return {
      'types': data['types'],
      'description': speciesData['flavor_text_entries']
          .firstWhere((entry) => entry['language']['name'] == 'en')['flavor_text'],
      'evolution_chain': evolutionData['chain'],
    };
  }

  Color getTypeColor(String type) {
    switch (type) {
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow;
      case 'psychic':
        return Colors.purple;
      case 'ice':
        return Colors.cyan;
      case 'dragon':
        return Colors.indigo;
      case 'dark':
        return Colors.black;
      case 'fairy':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  Widget buildEvolutionChain(Map<String, dynamic> chain) {
    List<Widget> evolutionWidgets = [];
    void traverseChain(Map<String, dynamic> node) {
      evolutionWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              currentPokemonName = node['species']['name'];
              _pokemonDataFuture = fetchPokemonData();
            });
          },
          child: Column(
            children: [
              Image.network(
                'https://img.pokemondb.net/sprites/home/normal/${node['species']['name']}.png',
                width: 80,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
              Text(node['species']['name'].toUpperCase()),
            ],
          ),
        ),
      );
      if (node['evolves_to'] != null && node['evolves_to'].isNotEmpty) {
        evolutionWidgets.add(const Icon(Icons.arrow_forward));
        traverseChain(node['evolves_to'][0]);
      }
    }

    traverseChain(chain);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: evolutionWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _pokemonDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        } else {
          final types = snapshot.data!['types'] as List;
          final primaryType = types[0]['type']['name'];
          final backgroundColor = getTypeColor(primaryType);
          final description = snapshot.data!['description'];
          final evolutionChain = snapshot.data!['evolution_chain'];

          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: backgroundColor,
              elevation: 0,
              leading: const BackButton(color: Colors.white),
              title: Center(
                child: Text(
                  currentPokemonName.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              actions: const [SizedBox(width: 48)],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    primaryType.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Image.network(
                    'https://img.pokemondb.net/sprites/home/normal/$currentPokemonName.png',
                    width: 200,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                  const SizedBox(height: 20),
                  buildEvolutionChain(evolutionChain),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      description.replaceAll('\n', ' '),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Table(
                      border: TableBorder.all(color: Colors.white),
                      children: [
                        const TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Resistente a',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                  textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Débil a',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                  textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                getResistances(primaryType).join(', '),
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                getWeaknesses(primaryType).join(', '),
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/regions');
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('Regiones'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: backgroundColor),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.list),
                        label: const Text('Lista Pokémon'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: backgroundColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  List<String> getResistances(String type) {
    switch (type) {
      case 'fire':
        return ['Fire', 'Grass', 'Ice', 'Bug', 'Steel', 'Fairy'];
      case 'water':
        return ['Fire', 'Water', 'Ice', 'Steel'];
      case 'grass':
        return ['Water', 'Electric', 'Grass', 'Ground'];
      default:
        return ['None'];
    }
  }

  List<String> getWeaknesses(String type) {
    switch (type) {
      case 'fire':
        return ['Water', 'Ground', 'Rock'];
      case 'water':
        return ['Electric', 'Grass'];
      case 'grass':
        return ['Fire', 'Ice', 'Poison', 'Flying', 'Bug'];
      default:
        return ['None'];
    }
  }
}
