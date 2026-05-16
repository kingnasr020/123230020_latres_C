// lib/pages/detail_page.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/product_model.dart';

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

    int existingIndex = -1;

    // Cek apakah produk yang sama sudah ada di keranjang
    for (int i = 0; i < box.length; i++) {
      final item = box.getAt(i);

      if (item['username'] == widget.username &&
          item['productId'] == widget.product.id) {
        existingIndex = i;
        break;
      }
    }

    if (existingIndex != -1) {
      // Update qty jika produk sudah ada
      final existingItem = box.getAt(existingIndex);
      final currentQty = existingItem['qty'] as int;
      final newQty = currentQty + qty;

      await box.putAt(existingIndex, {
        'username': widget.username,
        'productId': widget.product.id,
        'title': widget.product.title,
        'price': widget.product.price,
        'thumbnail': widget.product.thumbnail,
        'qty': newQty,
      });
    } else {
      // Tambah item baru jika belum ada
      await box.add({
        'username': widget.username,
        'productId': widget.product.id,
        'title': widget.product.title,
        'price': widget.product.price,
        'thumbnail': widget.product.thumbnail,
        'qty': qty,
      });
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Produk berhasil ditambahkan ke keranjang'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar produk
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Image.network(
                    product.thumbnail,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Nama produk
            Text(
              product.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Informasi kategori
            const Text(
              'Brand: Essence | Category: beauty',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 16),

            // Harga
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),

            const SizedBox(height: 10),

            // Rating dan stok
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 4),
                const Text('2.56'),
                const SizedBox(width: 12),
                Container(
                  width: 1,
                  height: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 12),
                Text('Stok: ${product.stock}'),
              ],
            ),

            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade300),

            const SizedBox(height: 16),

            // Judul deskripsi
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Isi deskripsi
            Text(
              product.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.7,
              ),
            ),

            const SizedBox(height: 30),

            // Jumlah
            Row(
              children: [
                OutlinedButton(
                  onPressed: qty > 1
                      ? () {
                          setState(() {
                            qty--;
                          });
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                Text(
                  '$qty',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: qty < product.stock
                      ? () {
                          setState(() {
                            qty++;
                          });
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Tombol Add to Cart
            ElevatedButton.icon(
              onPressed: addToCart,
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text(
                'Add to Cart',
                style: TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}