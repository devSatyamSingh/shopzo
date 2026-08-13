/// Lightweight model for the typeahead suggestions dropdown.
/// Matches GET /v1/website/search/suggestions?q=&limit= response:
/// { "data": { "products": [ {id, name, slug, image, price} ] } }
class SearchSuggestionModel {
  final String id;
  final String name;
  final String slug;
  final String? image;
  final double price;

  SearchSuggestionModel({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    required this.price,
  });

  factory SearchSuggestionModel.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      image: (json['image'] as String?),
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse('${json['price']}') ?? 0,
    );
  }

  String get formattedPrice {
    final whole = price.toStringAsFixed(0);
    final withCommas =
    whole.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
    return '₹$withCommas';
  }
}