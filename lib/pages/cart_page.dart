import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:outfitaura/viewmodels/cart_viewmodel.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartViewModel = Provider.of<CartViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png', // Replace with your logo asset
              height: 40,
            ),
            const SizedBox(width: 8),
            const Text(
              'Cart',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF007180),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: cartViewModel.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF007180)),
            )
          : cartViewModel.errorMessage != null
              ? Center(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: const Color(0xFFE15757).withOpacity(0x1),
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cartViewModel.errorMessage!,
                            style: const TextStyle(color: Color(0xFFE15757), fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4ACDEB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => cartViewModel.fetchCart(),
                            child: const Text('Retry', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        color: const Color(0xFF82BECC),
                        margin: const EdgeInsets.all(16),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: cartViewModel.items.length,
                          itemBuilder: (context, index) {
                            final item = cartViewModel.items[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              color: const Color(0xFFDDEAE0),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(8),
                                leading: Image.network(
                                  item.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red),
                                ),
                                title: Text(
                                  item.title,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF007180)),
                                ),
                                subtitle: Text(
                                  '\$${item.price} x ${item.quantity} = \$${item.price * item.quantity}',
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Color(0xFFE15757)),
                                  onPressed: () => cartViewModel.deleteCartItem(item.id),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: const Color(0xFF82BECC),
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              '\$${cartViewModel.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}