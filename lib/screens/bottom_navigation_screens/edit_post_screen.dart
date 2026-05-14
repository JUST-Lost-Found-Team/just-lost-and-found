import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_lost_and_found/helpers/explore_options.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';

class EditPostScreen extends StatefulWidget {
  final Map<String, dynamic> postData;
  final String postId;


  const EditPostScreen({super.key, required this.postId, required this.postData});

  const EditPostScreen({
    super.key,
    required this.postData,
    required this.postId,
  });


  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();

  

  late TextEditingController _titleController;
  late TextEditingController _descController;
  
  bool _isLost = true;
  bool _isLoading = false;
  String? _selectedCategory
    
  List<String> _selectedLocations = [];


  String? _selectedLocation;
  bool _isLoading = false;

  final Color _fillColor = Colors.grey.shade200;

  @override
  void initState() {
    super.initState();

    
    _titleController = TextEditingController(text: widget.postData['title']);
    _descController = TextEditingController(text: widget.postData['description']);
    _isLost = widget.postData['status'] == 'Lost';
    _selectedCategory = widget.postData['category'];
    
    if (widget.postData['location'] != null) {
      _selectedLocations = List<String>.from(widget.postData['location']);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _updatePost() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLocations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one location"),
          backgroundColor: ThemeManager.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      
      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'location': _selectedLocations,
        'category': _selectedCategory,
        'status': _isLost ? 'Lost' : 'Found',
        'updatedAt': FieldValue.serverTimestamp(),
      });


    _titleController = TextEditingController(text: widget.postData['title']);
    _descController = TextEditingController(
      text: widget.postData['description'],
    );
    _selectedCategory =
        Categories.categories.contains(widget.postData['category'])
        ? widget.postData['category']
        : null;
    _selectedLocation =
        LocationData.locations.contains(widget.postData['location'])
        ? widget.postData['location']
        : null;
    _isLost = widget.postData['status'] == 'Lost';
  }

  Future<void> _updatePost() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({
            'title': _titleController.text.trim(),
            'description': _descController.text.trim(),
            'location': _selectedLocation,
            'category': _selectedCategory,
            'status': _isLost ? 'Lost' : 'Found',
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post updated successfully!'),
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

            content: Text('Failed to update post: $e'),

            content: Text('Update failed:$e'),

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

      if (mounted) setState(() => _isLoading = false);
    }
  }


  Widget build(BuildContext context) {
    int maxLocations = _isLost ? 3 : 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeManager.primaryBlue,

        elevation: 0,
        title: const Text(
          "Edit Post",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          'Edit Post',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: Icon(Icons.arrow_back, color: Colors.white),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("What are you reporting?"),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isLost = true),
                      child: _buildToggleButton("I Lost an Item", _isLost),
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
                      child: _buildToggleButton("I Found an Item", !_isLost),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildSectionTitle("Title:"),
              _buildTextField(
                controller: _titleController,
                hint: "Title of the item...",
              ),


              const SizedBox(height: 16),


              const SizedBox(height: 16),

              _buildSectionTitle("Description:"),
              _buildTextField(
                controller: _descController,
                hint: "Description of the item...",
                maxLines: 4,
              ),


              const SizedBox(height: 16),

              _buildSectionTitle(
                _isLost ? "Possible Locations (Up to 3):" : "Location:",
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
                          loc,

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
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            //color: Colors.white,
                          ),
                        ),

                        backgroundColor: ThemeManager.primaryYellow.withOpacity(
                          0.65,
                        ),
                        deleteIconColor: ThemeManager.errorRed,
                      //  deleteIcon: const Icon(Icons.close, size: 18),
                       // shape: StadiumBorder(side: BorderSide(color: ThemeManager.primaryYellow)),
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
                  key: UniqueKey(),
                  hint: "Add location...",
                  value: null,
                  items: LocationData.locations
                      .where((loc) => !_selectedLocations.contains(loc))
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item, style: const TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedLocations.add(val);
                      });
                    }
                  },
                ),

              const SizedBox(height: 16),


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
                validator: (value) => value == null ? "Required" : null,
                items: Categories.categories
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),


              const SizedBox(height: 40),


              const SizedBox(height: 20),
              _buildStatusSwitch(),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeManager.primaryBlue,

                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Update Post",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  
  Widget _buildToggleButton(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isActive ? ThemeManager.primaryBlue : Colors.white,
        border: Border.all(color: isActive ? ThemeManager.primaryBlue : Colors.grey.shade600, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isActive ? Colors.white : Colors.grey.shade600,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Update post",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 0.8),
    child: Text(
      title,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (v) => v!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: _fillColor,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
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
      value: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      alignment: AlignmentDirectional.bottomStart,
      menuMaxHeight: 350,
      borderRadius: BorderRadius.circular(15),
      decoration: InputDecoration(
        filled: true,
        fillColor: _fillColor,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),

      // decoration: InputDecoration(filled: true,fillColor: _fillColor,border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: BorderSide.none)),
    );
  }

  Widget _buildStatusSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _fillColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Item Status",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                "Lost",
                style: TextStyle(color: _isLost ? Colors.black : Colors.grey),
              ),
              Switch(
                value: !_isLost,
                onChanged: (v) => setState(() => _isLost = !v),
                activeColor: ThemeManager.primaryYellow,
              ),
              Text(
                "Found",
                style: TextStyle(color: !_isLost ? Colors.black : Colors.grey),
              ),
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

  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) => value == null || value.trim().isEmpty ? "Required field" : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: _fillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDropdown({Key? key, required String hint, required String? value, required List<DropdownMenuItem<String>> items, required Function(String?) onChanged, String? Function(String?)? validator}) {
    return DropdownButtonFormField<String>(
      key: key,
      isExpanded: true,
      value: value,
      menuMaxHeight: 300,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: _fillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

}

