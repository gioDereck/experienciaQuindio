class TravelPreference {
  final int id;
  final String name;
  final String image;

  TravelPreference({
    required this.id,
    required this.name,
    required this.image,
  });

  // Método para construir el objeto desde un Map (ej. de JSON)
  factory TravelPreference.fromJson(Map<String, dynamic> json) {
    return TravelPreference(
      id: json['id'],
      name: json['name'],
      image: json['image'],
    );
  }
}
