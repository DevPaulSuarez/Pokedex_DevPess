import 'package:flutter/material.dart';
import '../models/pokemon_basic.dart';
import '../models/pokemon_detail.dart';
import 'package:pokedexdevpess/services/pokemon_services.dart';

class PokemonDetailScreen extends StatefulWidget {
  final PokemonBasic pokemon;

  const PokemonDetailScreen({super.key, required this.pokemon});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  late Future<PokemonDetail> _pokemonDetail;

  @override
  void initState() {
    super.initState();
    _pokemonDetail = PokemonService().fetchPokemonDetail(widget.pokemon.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pokemon.name.toUpperCase())),
      body: FutureBuilder<PokemonDetail>(
        future: _pokemonDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No se encontró el Pokémon'));
          }

          final pokemon = snapshot.data!;
          final imageUrl =
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${pokemon.id}.png';

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(imageUrl, height: 200),
                const SizedBox(height: 20),
                Text('Nombre: ${pokemon.name.toUpperCase()}',
                    style: const TextStyle(fontSize: 24)),
                Text('Altura: ${pokemon.height / 10} m'),
                Text('Peso: ${pokemon.weight / 10} kg'),
                Text('Tipo(s): ${pokemon.types.join(', ')}'),
              ],
            ),
          );
        },
      ),
      
    );
  }
}
