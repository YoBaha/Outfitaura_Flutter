import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:outfitaura/models/clothing_item.dart';
import 'package:outfitaura/viewmodels/wardrobe_viewmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WardrobeViewModel()..fetchWardrobe(),
      child: Builder( // Wrap in Builder to ensure context is accessible
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Wardrobe'),
            backgroundColor: const Color(0xFF007180),
          ),
          body: Container(
            color: const Color(0xFFDDEAE0),
            child: Consumer<WardrobeViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (viewModel.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${viewModel.errorMessage}',
                          style: const TextStyle(color: Color(0xFFE15757), fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ACDEB)),
                          onPressed: () => viewModel.fetchWardrobe(),
                          child: const Text('Retry', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }
                if (viewModel.items.isEmpty) {
                  return const Center(child: Text('Your wardrobe is empty'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: viewModel.items.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.items[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                              child: CachedNetworkImage(
                                imageUrl: item.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'Added: ${item.createdAt.toLocal().toString().split('.')[0]}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF4ACDEB),
            onPressed: () => _showUploadDialog(context),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    final titleController = TextEditingController();
    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setState) {
            return AlertDialog(
              title: const Text('Add Clothing Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title (e.g., Hoodie)'),
                    autofocus: false,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ACDEB)),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          selectedImage = image;
                        });
                        ScaffoldMessenger.of(statefulContext).showSnackBar(
                          const SnackBar(content: Text('Image selected')),
                        );
                      }
                    },
                    child: const Text('Pick Image', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(statefulContext),
                  child: const Text('Cancel'),
                ),
                Builder(
                  builder: (builderContext) {
                    final viewModel = Provider.of<WardrobeViewModel>(context, listen: false);
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ACDEB)),
                      onPressed: () async {
                        if (titleController.text.isEmpty || selectedImage == null) {
                          ScaffoldMessenger.of(statefulContext).showSnackBar(
                            const SnackBar(content: Text('Please provide a title and image')),
                          );
                          return;
                        }
                        try {
                          await viewModel.uploadClothingItem(titleController.text, selectedImage!);
                          Navigator.pop(statefulContext);
                        } catch (e) {
                          ScaffoldMessenger.of(statefulContext).showSnackBar(
                            SnackBar(content: Text('Upload failed: $e')),
                          );
                        }
                      },
                      child: const Text('Upload', style: TextStyle(color: Colors.white)),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}