class PokemonBasic {
  final String name;
  final int id;

  PokemonBasic({required this.name, required this.id});

  factory PokemonBasic.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    final id = int.parse(url.split('/')[url.split('/').length - 2]);

    return PokemonBasic(
      name: json['name'],
      id: id,
    );
  }
}
