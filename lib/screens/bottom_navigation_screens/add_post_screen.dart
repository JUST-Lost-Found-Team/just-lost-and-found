import 'package:flutter/material.dart';
import 'package:just_lost_and_found/helpers/explore_options.dart';
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

  late List<DropdownMenuItem<String>> _locationDropdownItems;

  @override
  void initState() {
    super.initState();

    _locationDropdownItems = _getLocationDropdownItems();
  }

  List<DropdownMenuItem<String>> _getLocationDropdownItems() {
    List<DropdownMenuItem<String>> items = [];

    LocationData.locationsMap.forEach((sectionTitle, buildings) {
      items.add(
        DropdownMenuItem<String>(
          enabled: false,
          value: null,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(
              sectionTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: ThemeManager.primaryBlue,
              ),
            ),
          ),
        ),
      );

      // I am keeping this because I think this is how I am gonna store the locations in the database.

      String cleanSectionTitle = sectionTitle
          .replaceAll(RegExp(r'[^\w\s]+'), '')
          .trim();

      for (var building in buildings) {
        String uniqueValue = "$building - $cleanSectionTitle";

        items.add(
          DropdownMenuItem<String>(
            value: uniqueValue,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                building,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
        );
      }
    });

    return items;
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

              _buildSectionTitle("Location:"),
              _buildDropdown(
                hint: "Select Campus Location...",
                value: _selectedLocation,
                items: _locationDropdownItems,
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
      items: items,
      onChanged: onChanged,
      validator: (value) => value == null ? "Required" : null,
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
          vertical: 18,
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: ThemeManager.primaryYellow,
        size: 28,
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
