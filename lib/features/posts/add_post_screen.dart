import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
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
  final GlobalKey<FormFieldState> _locationDropdownKey =
      GlobalKey<FormFieldState>();
  List<String> _selectedLocations = [];

  final Color _fillColor = Colors.grey.shade200;

  Future<void> _pickImagesFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 70,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (images.isNotEmpty) {
      int availableSlots = 3 - _selectedImages.length;

      if (images.length > availableSlots && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("add_post.snack_max_images_ignored".tr()),
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

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (image != null) {
      if (_selectedImages.length < 3) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("add_post.snack_max_images".tr()),
              backgroundColor: ThemeManager.errorRed,
            ),
          );
        }
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: ThemeManager.primaryBlue,
                ),
                title: Text('add_post.choose_from_gallery'.tr()),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImagesFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: ThemeManager.primaryBlue,
                ),
                title: Text('add_post.take_a_photo'.tr()),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLocations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("add_post.snack_location_required".tr()),
          backgroundColor: ThemeManager.errorRed,
        ),
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
        'location': _selectedLocations,
        'category': _selectedCategory,
        'status': _isLost ? 'Lost' : 'Found',
        'images': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'isResolved': false,
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('add_post.snack_success'.tr()),
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
            content: Text('${"add_post.snack_failed".tr()}$e'),
            behavior: SnackBarBehavior.floating,
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
    int maxLocations = _isLost ? 3 : 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeManager.primaryBlue,
        elevation: 0,
        title: Text(
          "add_post.app_bar_title".tr(),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("add_post.what_reporting".tr()),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLost = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _isLost
                                ? ThemeManager.primaryBlue
                                : Colors.white,
                            border: Border.all(
                              color: _isLost
                                  ? ThemeManager.primaryBlue
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "add_post.lost_item".tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _isLost
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLost = false;

                            if (_selectedLocations.length > 1) {
                              _selectedLocations = [_selectedLocations.first];
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: !_isLost
                                ? ThemeManager.primaryBlue
                                : Colors.white,
                            border: Border.all(
                              color: !_isLost
                                  ? ThemeManager.primaryBlue
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "add_post.found_item".tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: !_isLost
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildSectionTitle("add_post.add_photos".tr()),

                if (!_isLost)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      "add_post.security_tip".tr(),
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),

                _selectedImages.isEmpty
                    ? GestureDetector(
                        onTap: () => _showImageSourceActionSheet(context),
                        child: _buildImagePickerBox(
                          height: 180,
                          width: double.infinity,
                        ),
                      )
                    : _buildImagePreviewList(),

                const SizedBox(height: 24),

                _buildSectionTitle("add_post.title_label".tr()),
                _buildTextField(
                  controller: _titleController,
                  hint: "add_post.title_hint".tr(),
                  maxLines: 1,
                ),

                const SizedBox(height: 16),

                _buildSectionTitle("add_post.desc_label".tr()),
                _buildTextField(
                  controller: _descController,
                  hint: "add_post.desc_hint".tr(),
                  maxLines: 4,
                ),

                const SizedBox(height: 16),

                _buildSectionTitle(
                  _isLost
                      ? "add_post.possible_locations".tr()
                      : "add_post.location_label".tr(),
                ),

                if (_selectedLocations.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _selectedLocations.map((loc) {
                        return InputChip(
                          label: Text(
                            "locations.$loc".tr(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          // backgroundColor: Colors.grey.shade400,
                          backgroundColor: Colors.white,

                          deleteIconColor: ThemeManager.errorRed,
                          onDeleted: () {
                            setState(() {
                              _selectedLocations.remove(loc);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),

                if (_selectedLocations.length < maxLocations)
                  _buildDropdown(
                    key: _locationDropdownKey,

                    hint: _selectedLocations.isEmpty
                        ? "add_post.select_location_hint".tr()
                        : "add_post.add_another_location_hint".tr(),
                    value: null,
                    validator: (val) => _selectedLocations.isEmpty
                        ? "add_post.error_required_dropdown".tr()
                        : null,
                    items: LocationData.locations.map((loc) {
                      bool isSelected = _selectedLocations.contains(loc);
                      return DropdownMenuItem<String>(
                        value: loc,
                        enabled: !isSelected,
                        child: Text(
                          "locations.$loc".tr(),
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected
                                ? Colors.grey.shade400
                                : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _selectedLocations.add(val);
                        });

                        _locationDropdownKey.currentState?.reset();
                      }
                    },
                  ),
                const SizedBox(height: 16),

                _buildSectionTitle("add_post.category_label".tr()),
                _buildDropdown(
                  hint: "add_post.select_category_hint".tr(),
                  value: _selectedCategory,
                  validator: (value) => value == null
                      ? "add_post.error_required_dropdown".tr()
                      : null,
                  items: Categories.categories
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            "categories.$item".tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    FocusScope.of(context).unfocus();

                    setState(() {
                      _selectedCategory = val;
                    });
                  },
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
                        : Text(
                            "add_post.submit_btn".tr(),
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
      validator: (value) => value == null || value.trim().isEmpty
          ? "add_post.error_required".tr()
          : null,
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
    Key? key,
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      key: key,
      isExpanded: true,
      value: value,
      dropdownColor: Colors.white,
      menuMaxHeight: 400,
      borderRadius: BorderRadius.circular(15),
      items: items,
      onChanged: onChanged,
      validator: validator,
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
            "add_post.press_to_add_photos".tr(),
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
              onTap: () => _showImageSourceActionSheet(context),
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
