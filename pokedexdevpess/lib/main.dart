import 'package:flutter/material.dart';
import 'services/pokemon_services.dart';
import 'models/pokemon_basic.dart';
import 'screens/pokemon_detail_screen.dart';
import 'screens/welcome_screen.dart'; //  Importamos nueva pantalla
import 'screens/regiones_screen.dart'; // importa tu pantalla de regiones

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokédex',
      initialRoute: '/', // 👈 Ruta inicial
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/pokedex': (context) => const PokemonListScreen(),
        '/regions': (context) => const RegionsScreen(),
      },
    );
  }
}

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final _pokemonService = PokemonService();
  late Future<List<PokemonBasic>> _pokemonBasics;

  @override
  void initState() {
    super.initState();
    _pokemonBasics = _pokemonService.fetchPokemonBasics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokédex')),
      body: FutureBuilder<List<PokemonBasic>>(
        future: _pokemonBasics,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron Pokémon'));
          }

          final pokemons = snapshot.data!;
          return ListView.builder(
            itemCount: pokemons.length,
            itemBuilder: (context, index) {
              final pokemon = pokemons[index];
              final imageUrl =
                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon.id}.png';

              return ListTile(
                leading: Image.network(imageUrl),
                title: Text(pokemon.name.toUpperCase()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PokemonDetailScreen(pokemon: pokemon),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
