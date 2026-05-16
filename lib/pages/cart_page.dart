// lib/pages/cart_page.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CartPage extends StatefulWidget {
  final String username;

  const CartPage({
    super.key,
    required this.username,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Future<void> deleteItem(int index) async {
    final box = Hive.box('cartBox');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final primary = Theme.of(context).colorScheme.primary;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Column(
            children: [
              Icon(
                Icons.delete_outline,
                size: 60,
                color: primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Konfirmasi Hapus',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus produk ini dari keranjang?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Ya, Hapus'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (result == true) {
      await box.deleteAt(index);

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil dihapus dari keranjang'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('cartBox');

    final items = box.values.toList().asMap().entries.where(
      (entry) => entry.value['username'] == widget.username,
    ).toList();

    double total = 0;
    for (var entry in items) {
      total += (entry.value['price'] as num) *
          (entry.value['qty'] as num);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'Keranjang masih kosong',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final entry = items[i];
                      final index = entry.key;
                      final item = entry.value;

                      final subtotal =
                          (item['price'] as num) *
                          (item['qty'] as num);

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item['thumbnail'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            item['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Qty: ${item['qty']}'),
                              Text(
                                'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              deleteItem(index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Total pembayaran
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}