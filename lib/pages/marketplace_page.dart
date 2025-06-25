import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outfitaura/models/product.dart';
import 'package:outfitaura/viewmodels/marketplace_viewmodel.dart';
import 'package:outfitaura/services/api_service.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      context.read<MarketplaceViewModel>().uploadProduct('New Product', 'Description', 29.99, image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MarketplaceViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                  future: ApiService.getUser(), // Use getUser instead of getCurrentUser
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
                                    decoration: const InputDecoration(labelText: 'Title'),
                                    onChanged: (value) {},
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(labelText: 'Description'),
                                    onChanged: (value) {},
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(labelText: 'Price'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {},
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () => _pickImage(context),
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
                                  trailing: user?['role'] == 'admin'
                                      ? IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => viewModel.deleteProduct(product.id),
                                        )
                                      : null,
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
}