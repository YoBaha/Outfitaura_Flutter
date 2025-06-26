import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outfitaura/models/product.dart';
import 'package:outfitaura/viewmodels/marketplace_viewmodel.dart';
import 'package:outfitaura/services/api_service.dart';
import 'package:outfitaura/viewmodels/cart_viewmodel.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  // Controllers to capture input from TextFields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Get values from controllers and convert price to double
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final priceText = _priceController.text.trim();
      if (title.isEmpty || description.isEmpty || priceText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
        return;
      }
      final price = double.tryParse(priceText);
      if (price == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid price')),
        );
        return;
      }
      context.read<MarketplaceViewModel>().uploadProduct(title, description, price, image);
      // Optional: Clear fields after successful upload
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MarketplaceViewModel>(context);
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(viewModel.errorMessage!),
                      ElevatedButton(
                        onPressed: () => viewModel.fetchProducts(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : FutureBuilder<Map<String, dynamic>?>(
                  future: ApiService.getUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading user data'));
                    }
                    final user = snapshot.data;
                    return Column(
                      children: [
                        if (user?['role'] == 'admin') ...[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _titleController,
                                    decoration: const InputDecoration(labelText: 'Title'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _descriptionController,
                                    decoration: const InputDecoration(labelText: 'Description'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _priceController,
                                    decoration: const InputDecoration(labelText: 'Price'),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: _pickImage,
                                  child: const Text('Upload'),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Implement update/delete logic here
                            },
                            child: const Text('Manage Products'),
                          ),
                        ],
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: viewModel.products.length,
                            itemBuilder: (context, index) {
                              final product = viewModel.products[index];
                              return Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: ListTile(
                                  leading: Image.network(
                                    product.imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                  ),
                                  title: Text(product.title),
                                  subtitle: Text('${product.description} - \$${product.price}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (user?['role'] == 'admin')
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => viewModel.deleteProduct(product.id),
                                        ),
                                      IconButton(
                                        icon: const Icon(Icons.add_shopping_cart),
                                        onPressed: () => cartViewModel.addToCart(product.id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}