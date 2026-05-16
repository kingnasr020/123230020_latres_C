// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'detail_page.dart';
import 'cart_page.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({
    super.key,
    required this.username,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> allProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final products = await ApiService.fetchProducts();

      if (mounted) {
        setState(() {
          allProducts = products;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Menentukan kategori produk berdasarkan judul
  String getCategory(Product product) {
    final title = product.title.toLowerCase();

    if (title.contains('mascara') ||
        title.contains('lipstick') ||
        title.contains('powder') ||
        title.contains('eyeshadow') ||
        title.contains('nail')) {
      return 'beauty';
    } else if (title.contains('perfume') ||
        title.contains('eau de') ||
        title.contains('cologne') ||
        title.contains("j'adore") ||
        title.contains('chanel') ||
        title.contains('calvin klein')) {
      return 'fragrances';
    } else if (title.contains('chair') ||
        title.contains('table') ||
        title.contains('sofa')) {
      return 'furniture';
    } else if (title.contains('milk') ||
        title.contains('rice') ||
        title.contains('bread')) {
      return 'groceries';
    }

    return 'general';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${widget.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CartPage(
                    username: widget.username,
                  ),
                ),
              );

              // Refresh setelah kembali dari cart
              if (mounted) {
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: allProducts.length,
              itemBuilder: (context, index) {
                final product = allProducts[index];
                final category = getCategory(product);

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),

                    // Gambar produk
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.thumbnail,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Nama produk
                    title: Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    // Kategori | Harga
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$category | \$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                    // Klik ke detail
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(
                            product: product,
                            username: widget.username,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}