class CartItem {
  final String username;
  final int productId;
  final String title;
  final double price;
  final String thumbnail;
  final int qty;

  CartItem({
    required this.username,
    required this.productId,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.qty,
  });

  Map<String, dynamic> toMap() => {
        'username': username,
        'productId': productId,
        'title': title,
        'price': price,
        'thumbnail': thumbnail,
        'qty': qty,
      };
}
