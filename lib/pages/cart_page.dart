import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CartPage extends StatefulWidget {
  final String username;
  const CartPage({super.key, required this.username});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Box cartBox;

  @override
  void initState() {
    super.initState();
    cartBox = Hive.box('cartBox');
  }

  // Fungsi tambah/kurang qty
  Future<void> updateQty(dynamic key, Map item, int delta) async {
    int currentQty = (item['qty'] as num?)?.toInt() ?? 1;
    int newQty = currentQty + delta;
    if (newQty < 1) return; 

    item['qty'] = newQty;
    await cartBox.put(key, item);
    setState(() {});
  }

  Future<void> deleteItem(dynamic key) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final primary = Theme.of(context).colorScheme.primary;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Column(
            children: [
              Icon(Icons.delete_outline, size: 60, color: primary),
              const SizedBox(height: 16),
              const Text('Konfirmasi Hapus', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text('Apakah Anda yakin ingin menghapus Game ini dari keranjang?', textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(width: 100, child: TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal'))),
            const SizedBox(width: 16),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await cartBox.delete(key);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Game berhasil dihapus')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final allItems = cartBox.toMap().entries.toList();
    final items = allItems.where((entry) => entry.value['username'] == widget.username).toList();

    double total = 0;
    for (var entry in items) {
      final item = entry.value;
      total += (item['price'] as num? ?? 0) * (item['qty'] as num? ?? 0);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang Belanja')),
      body: items.isEmpty
          ? const Center(child: Text('Keranjang masih kosong', style: TextStyle(fontSize: 18)))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final entry = items[i];
                      final key = entry.key;
                      final item = entry.value;
                      final subtotal = (item['price'] as num? ?? 0) * (item['qty'] as num? ?? 0);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item['thumbnail'] ?? '',
                              width: 60, height: 60, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                            ),
                          ),
                          title: Text(item['title'] ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
                              Row(
                                children: [
                                  IconButton(onPressed: () => updateQty(key, Map.from(item), -1), icon: const Icon(Icons.remove_circle_outline, size: 20)),
                                  Text('${item['qty']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  IconButton(onPressed: () => updateQty(key, Map.from(item), 1), icon: const Icon(Icons.add_circle_outline, size: 20)),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteItem(key),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}