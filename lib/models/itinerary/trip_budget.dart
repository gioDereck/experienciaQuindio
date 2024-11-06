class TripBudget {
  final int id;
  final String name;
  final String description;
  final String image;

  TripBudget({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  // Método para construir el objeto desde un Map (ej. de JSON)
  factory TripBudget.fromJson(Map<String, dynamic> json) {
    return TripBudget(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
    );
  }
}
