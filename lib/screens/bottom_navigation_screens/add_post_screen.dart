import 'package:flutter/material.dart';
import 'package:just_lost_and_found/helpers/my_listings.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  bool _isLost = true;

  String? _selectedCategory;
  String? _selectedLocation;

  final Color _fillColor = const Color(0xFFDFE7ED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeManager.primaryBlue,
        elevation: 0,
        title: Text(
          "Add Post",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
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
              _buildSectionTitle("Add Photos of the item (up to 4)"),
              GestureDetector(
                onTap: () {},
                child: _buildImagePickerBox(
                  height: 180,
                  width: double.infinity,
                ),
              ),

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

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Location:"),
                        _buildDropdown(
                          hint: "Select",
                          value: _selectedLocation,
                          items: ListingOptions.locations,
                          onChanged: (val) =>
                              setState(() => _selectedLocation = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Category:"),
                        _buildDropdown(
                          hint: "Select",
                          value: _selectedCategory,
                          items: ListingOptions.categories,
                          onChanged: (val) =>
                              setState(() => _selectedCategory = val),
                        ),
                      ],
                    ),
                  ),
                ],
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeManager.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
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
        hintStyle: TextStyle(color: Colors.grey.shade500),
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
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      dropdownColor: Colors.white,
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? "Required" : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: _fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: ThemeManager.primaryYellow,
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
}
