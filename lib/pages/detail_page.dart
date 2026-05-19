import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/games_model.dart';

class DetailPage extends StatefulWidget {
  final Product product;
  final String username;

  const DetailPage({
    super.key,
    required this.product,
    required this.username,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int qty = 1;

  Future<void> addToCart() async {
    final box = Hive.box('cartBox');

    // Data yang disimpan di sini harus SAMA key-nya dengan yang di CartPage
    await box.add({
      'username': widget.username,
      'title': widget.product.name,
      'thumbnail': widget.product.backgroundImage,
      'price': (widget.product.rating as num? ?? 0) * 100, 
      'qty': qty,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Game berhasil ditambahkan ke keranjang!'),
        duration: Duration(seconds: 1),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.product;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Game')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  game.backgroundImage,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey,
                    child: const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                game.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Released: ${game.released}', style: const TextStyle(fontSize: 16)),
              Text('Rating: ${game.rating}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              
              // Counter Quantity
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: qty > 1 ? () => setState(() => qty--) : null,
                    icon: const Icon(Icons.remove_circle_outline, size: 30),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('$qty', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    onPressed: () => setState(() => qty++),
                    icon: const Icon(Icons.add_circle_outline, size: 30),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              // Add to Cart Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: addToCart,
                child: const Text('Add to Cart', style: TextStyle(fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }
}