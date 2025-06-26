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
        title: const Text('Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: cartViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartViewModel.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cartViewModel.errorMessage!),
                      ElevatedButton(
                        onPressed: () => cartViewModel.fetchCart(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartViewModel.items.length,
                        itemBuilder: (context, index) {
                          final item = cartViewModel.items[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: Image.network(
                                item.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                              ),
                              title: Text(item.title),
                              subtitle: Text('\$${item.price} x ${item.quantity} = \$${item.price * item.quantity}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => cartViewModel.deleteCartItem(item.id),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Total: \$${cartViewModel.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
    );
  }
}