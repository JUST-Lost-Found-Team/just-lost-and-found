import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_lost_and_found/helpers/explore_options.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';
import 'package:just_lost_and_found/services/cloudinary_service.dart';

class AddPost extends StatefulWidget {


  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final _formKey = GlobalKey<FormState>();
  List<File> _selectedImages = [];
  
  final ImagePicker _picker = ImagePicker();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLost = true;
  bool _isLoading = false;
  String? _selectedCategory;
  String? _selectedLocation;
  final Color _fillColor = Colors.grey.shade200;

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 70,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (images.isNotEmpty) {
      int availableSlots = 3 - _selectedImages.length;

      if (images.length > availableSlots && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "You can only select up to 3 images, Extra images were ignored",
            ),
            backgroundColor: ThemeManager.errorRed,
          ),
        );
      }

      setState(() {
        for (var img in images) {
          if (_selectedImages.length < 3) {
            _selectedImages.add(File(img.path));
          }
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one image!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> imageUrls = [];
      Cloudinary cloudinary = Cloudinary();

      for (var file in _selectedImages) {
        String? url = await cloudinary.uploadToCloudinary(file);
        if (url != null) {
          imageUrls.add(url);
        }
      }

      await FirebaseFirestore.instance.collection('posts').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'location': _selectedLocation,
        'category': _selectedCategory,
        'status': _isLost ? 'Lost' : 'Found',
        'images': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'isResolved': false,
        'uid': FirebaseAuth.instance.currentUser?.uid,
        
        
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post added successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ThemeManager.successGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload post: $e'),
            backgroundColor: ThemeManager.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeManager.primaryBlue,
        elevation: 0,
        title: const Text(
          "Add Post",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Add Photos of the item (up to 3)"),
              _selectedImages.isEmpty
                  ? GestureDetector(
                      onTap: _pickImages,
                      child: _buildImagePickerBox(
                        height: 180,
                        width: double.infinity,
                      ),
                    )
                  : _buildImagePreviewList(),

              const SizedBox(height: 20),

              _buildSectionTitle("Title:"),
              _buildTextField(
                controller: _titleController,
                hint: "Title of the item...",
              ),

              const SizedBox(height: 16),

              _buildSectionTitle("Description:"),
              _buildTextField(
                controller: _descController,
                hint: "Description of the item...",
                maxLines: 4,
              ),

              const SizedBox(height: 16),

              _buildSectionTitle("Location:"),
              _buildDropdown(
                hint: "Select Campus Location...",
                value: _selectedLocation,

                items: LocationData.locations
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedLocation = val),
              ),

              const SizedBox(height: 16),

              _buildSectionTitle("Category:"),
              _buildDropdown(
                hint: "Select Item Category...",
                value: _selectedCategory,
                items: Categories.categories
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: _fillColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Item Status",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "is this item Lost or Found?",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Lost",
                          style: TextStyle(
                            fontWeight: _isLost
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _isLost ? Colors.black : Colors.grey,
                          ),
                        ),
                        Switch(
                          value: !_isLost,
                          onChanged: (val) {
                            setState(() {
                              _isLost = !val;
                            });
                          },
                          activeColor: ThemeManager.primaryYellow,
                          activeTrackColor: ThemeManager.primaryYellow
                              .withOpacity(0.2),
                          inactiveThumbColor: ThemeManager.primaryYellow,
                          inactiveTrackColor: ThemeManager.primaryYellow
                              .withOpacity(0.2),
                        ),
                        Text(
                          "Found",
                          style: TextStyle(
                            fontWeight: !_isLost
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: !_isLost ? Colors.black : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeManager.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Add Post",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) =>
          value == null || value.trim().isEmpty ? "Required field" : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
        filled: true,
        fillColor: _fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      dropdownColor: Colors.white,
      menuMaxHeight: 400,
      borderRadius: BorderRadius.circular(15),
      items: items,
      onChanged: onChanged,
      validator: (value) => value == null ? "Required" : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
        filled: true,
        fillColor: _fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: ThemeManager.primaryYellow,
        size: 26,
      ),
    );
  }

  Widget _buildImagePickerBox({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: _fillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, size: 50, color: ThemeManager.primaryYellow),
          const SizedBox(height: 10),
          Text(
            "press to add the photos",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreviewList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length < 3
            ? _selectedImages.length + 1
            : _selectedImages.length,
        itemBuilder: (context, index) {
          if (index == _selectedImages.length) {
            return GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 100,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: _fillColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.add, size: 40, color: Colors.grey),
                ),
              ),
            );
          }

          return Stack(
            children: [
              Container(
                width: 120,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(_selectedImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 5,
                right: 15,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
