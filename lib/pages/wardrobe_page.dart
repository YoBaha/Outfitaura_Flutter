import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outfitaura/pages/login_page.dart';
import 'package:outfitaura/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:outfitaura/models/clothing_item.dart';
import 'package:outfitaura/viewmodels/wardrobe_viewmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key});

  void _logout(BuildContext context) async {
    await ApiService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text('Add Clothing Item', style: TextStyle(color: Color(0xFF007180), fontWeight: FontWeight.bold)),
              content: SizedBox(
                height: MediaQuery.of(statefulContext).size.height * 0.4,
                child: RepaintBoundary(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: 'Title (e.g., Hoodie)',
                            labelStyle: const TextStyle(color: Color(0xFF007180)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFF007180)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          autofocus: false,
                        ),
                        const SizedBox(height: 15),
                        if (selectedImage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SizedBox(
                              height: 100,
                              width: double.maxFinite,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4ACDEB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            final picker = ImagePicker();
                            final image = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 85,
                              maxWidth: 800,
                            );
                            if (image != null) {
                              setState(() async {
                                selectedImage = image;
                                debugPrint('Image set: ${selectedImage!.path}, size: ${await image.length()} bytes');
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
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(statefulContext),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF007180))),
                ),
                Builder(
                  builder: (builderContext) {
                    final viewModel = Provider.of<WardrobeViewModel>(context, listen: false);
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ACDEB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WardrobeViewModel()..fetchWardrobe(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 40,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Wardrobe',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF007180),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () => _logout(context),
              ),
            ],
          ),
          body: Container(
            color: const Color(0xFFDDEAE0),
            child: Consumer<WardrobeViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF007180)),
                  );
                }
                if (viewModel.errorMessage != null) {
                  return Center(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: const Color(0xFFE15757).withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                      ),
                    ),
                  );
                }
                if (viewModel.items.isEmpty) {
                  return const Center(
                    child: Text(
                      'Your wardrobe is empty',
                      style: TextStyle(fontSize: 18, color: Color(0xFF007180)),
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: viewModel.items.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.items[index];
                    return Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: const Color(0xFF82BECC),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                              child: Stack(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: item.imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xFF007180))),
                                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                      onPressed: () async {
                                        final viewModel = Provider.of<WardrobeViewModel>(context, listen: false);
                                        await viewModel.deleteClothingItem(item.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Item deleted')),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Added: ${item.createdAt.toLocal().toString().split('.')[0]}',
                                  style: const TextStyle(fontSize: 12, color: Colors.white70),
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
            child: const Icon(Icons.add, color: Colors.white),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      ),
    );
  }
}