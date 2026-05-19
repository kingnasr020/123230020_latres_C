class Product {
  final String id;
  final String name;
  final String released;
  final double rating;
  final String backgroundImage;
  final int ratingsCount;
  final int reviewsCount;
  final String updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.released,
    required this.rating,
    required this.backgroundImage,
    required this.ratingsCount,
    required this.reviewsCount,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      released: json['released'] ?? 'N/A',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      backgroundImage: json['background_image'] ?? '',
      ratingsCount: json['ratings_count'] ?? 0,
      reviewsCount: json['reviews_count'] ?? 0,
      updatedAt: json['updated_at'] ?? 'N/A',
    );
  }
}