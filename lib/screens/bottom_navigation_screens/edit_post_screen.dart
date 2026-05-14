import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_lost_and_found/helpers/explore_options.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';

class EditPostScreen extends StatefulWidget {
  final Map<String, dynamic> postData;
  final String postId;

  const EditPostScreen({super.key, required this.postId, required this.postData});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descController;
  
  bool _isLost = true;
  bool _isLoading = false;
  String? _selectedCategory;
  List<String> _selectedLocations = [];

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

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'location': _selectedLocations,
        'category': _selectedCategory,
        'status': _isLost ? 'Lost' : 'Found',
        'updatedAt': FieldValue.serverTimestamp(),
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
            content: Text('Update failed: $e'),
            backgroundColor: ThemeManager.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: const Text("Edit Post", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              _buildTextField(controller: _titleController, hint: "Title..."),
              const SizedBox(height: 16),
              _buildSectionTitle("Description:"),
              _buildTextField(controller: _descController, hint: "Description...", maxLines: 4),
              const SizedBox(height: 16),
              _buildSectionTitle(_isLost ? "Possible Locations (Up to 3):" : "Location:"),
              
              if (_selectedLocations.isNotEmpty)
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _selectedLocations.map((loc) => InputChip(
                    label: Text(loc, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF333333))),
                    backgroundColor: const Color(0xFFF3C08E),
                    deleteIconColor: Colors.red.shade700,
                    deleteIcon: const Icon(Icons.close, size: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onDeleted: () => setState(() => _selectedLocations.remove(loc)),
                  )).toList(),
                ),
                
              const SizedBox(height: 10),

              if (_selectedLocations.length < maxLocations)
                _buildDropdown(
                  hint: "Add location...",
                  value: null,
                  items: LocationData.locations
                      .where((loc) => !_selectedLocations.contains(loc))
                      .map((item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontSize: 14))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLocations.add(val));
                  },
                ),

              const SizedBox(height: 16),
              _buildSectionTitle("Category:"),
              _buildDropdown(
                hint: "Select Category...",
                value: _selectedCategory,
                items: Categories.categories.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),

              const SizedBox(height: 40),
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
                      : const Text("Update Post", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
  );

  Widget _buildToggleButton(String text, bool isActive) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      color: isActive ? ThemeManager.primaryBlue : Colors.white,
      border: Border.all(color: isActive ? ThemeManager.primaryBlue : Colors.grey.shade300, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isActive ? Colors.white : Colors.grey.shade600)),
    ),
  );

  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1}) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    validator: (v) => v!.isEmpty ? "Required" : null,
    decoration: InputDecoration(
      filled: true, fillColor: _fillColor, hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    ),
  );

  Widget _buildDropdown({required String hint, required String? value, required List<DropdownMenuItem<String>> items, required Function(String?) onChanged}) => DropdownButtonFormField<String>(
    value: value,
    items: items,
    onChanged: onChanged,
    isExpanded: true,
    menuMaxHeight: 300,
    iconEnabledColor: const Color(0xFFF3C08E),
    decoration: InputDecoration(
      filled: true, fillColor: _fillColor, hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    ),
  );
}