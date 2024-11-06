class LandMark {
  String? name;
  String? address;
  double? lat;
  double? lng;
  var rating;
  var price;
  String? photoReference;
  String? placeId;

  LandMark(
      {this.name,
      this.address,
      this.lat,
      this.lng,
      this.rating,
      this.price,
      this.photoReference,
      this.placeId});

  factory LandMark.fromJson(Map<String, dynamic> json) {
    return LandMark(
        name: json['name'] ?? '',
        address: json['vicinity'] ?? '',
        lat: json['geometry']['location']['lat'] ?? 0.0,
        lng: json['geometry']['location']['lng'] ?? 0.0,
        rating: json['rating'] ?? 4,
        price: json['price_level'] ?? 0,
        photoReference: json['photos'] == null ||
                json['photos'][0]['photo_reference'] == null
            ? null
            : json['photos'][0]['photo_reference'],
        placeId: json['place_id']);
  }
}
