import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_lost_and_found/screens/auth_screens/login_screen.dart';
import 'package:just_lost_and_found/screens/bottom_navigation_screens/my_posts_screen.dart';
import 'package:just_lost_and_found/services/cloudinary_service.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  bool isUploading = false;
  String? _firestoreProfileImageUrl = FirebaseAuth.instance.currentUser?.photoURL;

  @override
  void initState() {
    super.initState();
    _refreshUser();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        if (doc.exists && mounted) {
          setState(() {
            _firestoreProfileImageUrl = (doc.data() as Map<String, dynamic>)['profileImage'];
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> _refreshUser() async {
    await user?.reload();
    setState(() { user = FirebaseAuth.instance.currentUser; });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
      if (selectedImage != null) {
        setState(() { _imageFile = selectedImage; });
        await uploadToCloudinary();
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> uploadToCloudinary() async {
    if (_imageFile == null) return;
    setState(() { isUploading = true; });
    try {
      Cloudinary cloudinary = Cloudinary();
      String? imageUrl = await cloudinary.uploadToCloudinary(File(_imageFile!.path));
      if (imageUrl != null && user != null) {
        await user!.updatePhotoURL(imageUrl);
        await user!.reload();
        await _refreshUser();
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({'profileImage': imageUrl});
        if (mounted) { setState(() { _firestoreProfileImageUrl = imageUrl; }); }
      }
    } catch (e) {
      print("Upload error: $e");
    } finally {
      if (mounted) { setState(() { isUploading = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userName = user?.displayName ?? "Student Name";
    final String userEmail = user?.email ?? "email@just.edu.jo";

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
         
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight, 
              ),
              child: IntrinsicHeight(
              
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    
                    Column(
                      children: [
                        Container(
                          height: 180,
                          width: double.infinity,
                          color: ThemeManager.primaryBlue,
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.only(top: 50),
                          // child: const Text('Profile',
                          //     style: TextStyle(
                          //         color: Colors.white,
                          //         fontSize: 22,
                          //         fontWeight: FontWeight.bold)),
                        ),
                        
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            color: Colors.white,
                            child: Column(
                              children: [
                                const SizedBox(height: 95), 
                                Text(userName,
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeManager.primaryBlue)),
                                Text(userEmail,
                                    style: const TextStyle(color: Colors.grey)),

                                const SizedBox(height: 30),
                                _buildSectionHeader("My Posts"),
                                _buildMenuItem(Icons.post_add, "View All", () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPostsScreen()));
                                }),

                                const SizedBox(height: 20),
                                _buildSectionHeader("Settings"),
                                _buildSettingsBox(),

                                const Spacer(), 
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                   
                    Positioned(
                      top: 180 - 100,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _buildProfileImage(85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

 
  Widget _buildProfileImage(double radius) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ThemeManager.primaryYellow, width: 8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
            ],
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey[300],
            child: isUploading
                ? const CircularProgressIndicator(color: ThemeManager.primaryBlue)
                : _imageFile != null
                    ? ClipOval(child: Image.file(File(_imageFile!.path), width: radius * 2, height: radius * 2, fit: BoxFit.cover))
                    : (_firestoreProfileImageUrl != null && _firestoreProfileImageUrl!.isNotEmpty)
                        ? ClipOval(child: CachedNetworkImage(imageUrl: _firestoreProfileImageUrl!, width: radius * 2, height: radius * 2, fit: BoxFit.cover, placeholder: (context, url) => const CircularProgressIndicator(), errorWidget: (context, url, error) => const Icon(Icons.person, size: 60)))
                        : const Icon(Icons.person, size: 60, color: Colors.grey),
          ),
        ),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 40, width: 40,
            decoration: BoxDecoration(
              color: ThemeManager.primaryYellow,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.edit, color: ThemeManager.primaryBlue, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, bottom: 8),
      child: Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(color: ThemeManager.primaryBlue, fontSize: 18, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(30)),
        child: ListTile(
          title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
          leading: Icon(icon, color: Colors.black),
          trailing: const Icon(Icons.arrow_forward_ios, color: ThemeManager.primaryYellow, size: 18),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildSettingsBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(30)),
        child: Column(
          children: [
            _buildListTile("Language", Icons.language, () {}),
            const Divider(height: 0, thickness: 0.5, endIndent: 20, indent: 20),
            ListTile(
              title: const Text("Light Mode"),
              leading: const Icon(Icons.wb_sunny_outlined, color: ThemeManager.primaryYellow),
              trailing: Switch(value: true, activeColor: ThemeManager.primaryYellow, onChanged: (val) {}),
            ),
            const Divider(height: 0, thickness: 0.5, endIndent: 20, indent: 20),
            _buildListTile("Log Out", Icons.logout, () => _showLogoutDialog(context), isRed: true),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, VoidCallback onTap, {bool isRed = false}) {
    return ListTile(
      title: Text(title, style: TextStyle(color: isRed ? Colors.red : Colors.black, fontWeight: FontWeight.w500)),
      leading: Icon(icon, color: isRed ? Colors.red : Colors.black),
      trailing: const Icon(Icons.arrow_forward_ios, color: ThemeManager.primaryYellow, size: 18),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.logout, color: ThemeManager.errorRed), SizedBox(width: 9), Text('Log Out')]),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (r) => false);
          }, child: const Text('Log Out', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}