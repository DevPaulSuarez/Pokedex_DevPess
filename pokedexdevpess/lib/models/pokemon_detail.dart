class PokemonDetail {
  final int id;
  final String name;
  final int height;
  final int weight;
  final List<String> types;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final typesList = (json['types'] as List)
        .map((item) => item['type']['name'] as String)
        .toList();

    return PokemonDetail(
      id: json['id'],
      name: json['name'],
      height: json['height'],
      weight: json['weight'],
      types: typesList,
    );
  }
}
