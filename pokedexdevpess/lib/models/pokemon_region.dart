class Region {
  final String name;
  final String url;

  Region({required this.name, required this.url});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      name: json['name'],
      url: json['url'],
    );
  }
}