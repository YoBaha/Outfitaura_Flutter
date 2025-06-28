import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../view_models/marketplace_view_model.dart';
import '../widgets/sidebar.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  _MarketplacePageState createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  XFile? _image;
  String? _editingProductId;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    setState(() {
      _image = null;
      _editingProductId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MarketplaceViewModel()..fetchProducts(),
      child: Consumer<MarketplaceViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            body: Row(
              children: [
                const Sidebar(),
                Expanded(
                  child: Container(
                    color: const Color(0xFFDDEAE0),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Manage Marketplace',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF007180),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Add/Update Product Form
                        Card(
                          color: const Color(0xFF82BECC),
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Add/Update Product',
                                  style: TextStyle(fontSize: 20, color: Colors.white),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _titleController,
                                  decoration: const InputDecoration(
                                    labelText: 'Title',
                                    labelStyle: TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Color(0xFFDDEAE0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _descriptionController,
                                  decoration: const InputDecoration(
                                    labelText: 'Description',
                                    labelStyle: TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Color(0xFFDDEAE0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _priceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Price',
                                    labelStyle: TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Color(0xFFDDEAE0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: _pickImage,
                                      child: const Text('Pick Image'),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _image != null ? _image!.name : 'No image selected',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (_titleController.text.isEmpty ||
                                            _descriptionController.text.isEmpty ||
                                            _priceController.text.isEmpty ||
                                            (_editingProductId == null && _image == null)) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('All fields are required')),
                                          );
                                          return;
                                        }
                                        final price = double.tryParse(_priceController.text);
                                        if (price == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Invalid price')),
                                          );
                                          return;
                                        }
                                        if (_editingProductId == null) {
                                          await viewModel.addProduct(
                                            _titleController.text,
                                            _descriptionController.text,
                                            price,
                                            _image!,
                                          );
                                        } else {
                                          await viewModel.updateProduct(
                                            _editingProductId!,
                                            _titleController.text,
                                            _descriptionController.text,
                                            price,
                                            _image,
                                          );
                                        }
                                        _resetForm();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(_editingProductId == null
                                                ? 'Product added'
                                                : 'Product updated'),
                                          ),
                                        );
                                      },
                                      child: Text(_editingProductId == null ? 'Add Product' : 'Update Product'),
                                    ),
                                    const SizedBox(width: 10),
                                    if (_editingProductId != null)
                                      ElevatedButton(
                                        onPressed: _resetForm,
                                        child: const Text('Cancel'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Product List
                        if (viewModel.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (viewModel.errorMessage != null)
                          Text(
                            viewModel.errorMessage!,
                            style: const TextStyle(color: Color(0xFFE15757), fontSize: 16),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              itemCount: viewModel.products.length,
                              itemBuilder: (context, index) {
                                final product = viewModel.products[index];
                                return Card(
                                  color: const Color(0xFFDDEAE0),
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: Image.network(
                                      product.imageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.error),
                                    ),
                                    title: Text(product.title),
                                    subtitle: Text('\$${product.price.toStringAsFixed(2)}\n${product.description}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Color(0xFF007180)),
                                          onPressed: () {
                                            setState(() {
                                              _editingProductId = product.id;
                                              _titleController.text = product.title;
                                              _descriptionController.text = product.description;
                                              _priceController.text = product.price.toString();
                                              _image = null;
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Color(0xFFE15757)),
                                          onPressed: () async {
                                            await viewModel.deleteProduct(product.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Product deleted')),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}