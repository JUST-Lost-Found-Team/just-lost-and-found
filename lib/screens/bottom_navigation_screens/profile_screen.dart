import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_lost_and_found/screens/SignIn_screen.dart';
import 'package:just_lost_and_found/screens/bottom_navigation_screens/my_posts_screen.dart';
import 'package:just_lost_and_found/services/cloudinary_service.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';
import 'dart:io';

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

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }

  Future<void> _refreshUser() async {
    await user?.reload();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
      if (selectedImage != null) {
        setState(() {
          _imageFile = selectedImage;
        });
        await uploadToCloudinary();
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> uploadToCloudinary() async {
    if (_imageFile == null) return;
    setState(() {
      isUploading = true;
    });
    try {
      Cloudinary cloudinary = Cloudinary();
      String? imageUrl = await cloudinary.uploadToCloudinary(File(_imageFile!.path));
      if (imageUrl != null && user != null) {
        await user!.updatePhotoURL(imageUrl);
        await user!.reload();
        await _refreshUser();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile picture updated successfully!!")),
          );
        }
      }
    } catch (e) {
      print("Error uploading profile image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating picture: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final blueHeaderHight = 120.0;
    final avatarRadius = 60.0;
    final String userName = user?.displayName ?? "Student Name";
    final String userEmail = user?.email ?? "email@just.edu.jo";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: blueHeaderHight,
            width: double.infinity,
            color: ThemeManager.primaryBlue,
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ThemeManager.primaryYellow,
                          width: 8,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 85.0,
                        backgroundColor: Colors.grey[300],
                        // 💡 هون الترتيب الصح للعرض
                        child: isUploading 
                          ? const CircularProgressIndicator(color: ThemeManager.primaryBlue)
                          : _imageFile != null 
                              ? ClipOval(child: Image.file(File(_imageFile!.path), width: 170, height: 170, fit: BoxFit.cover))
                              : user?.photoURL != null 
                                  ? ClipOval(child: Image.network(user!.photoURL!, width: 170, height: 170, fit: BoxFit.cover))
                                  : Icon(Icons.person, size: avatarRadius, color: Colors.grey[600]),
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickImage, // 👈 ربطنا كبسة القلم بالاستوديو
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: ThemeManager.primaryYellow,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: ThemeManager.primaryBlue,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: const TextStyle(
                    color: ThemeManager.primaryBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userEmail,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "My Posts",
                      style: TextStyle(
                        color: ThemeManager.primaryBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: ListTile(
                      title: const Text("View All", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                      leading: const Icon(Icons.post_add, color: Colors.black),
                      trailing: const Icon(Icons.arrow_forward_ios, color: ThemeManager.primaryYellow),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MyPostsScreen()));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Settings",
                      style: TextStyle(color: ThemeManager.primaryBlue, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text("Language", style: TextStyle(color: Colors.black)),
                          leading: const Icon(Icons.language, color: Colors.black),
                          trailing: const Icon(Icons.arrow_forward_ios, color: ThemeManager.primaryYellow),
                          onTap: () {},
                        ),
                        const Divider(height: 0, indent: 0.0, endIndent: 20.0, thickness: 0.5),
                        ListTile(
                          title: const Text("Light Mode"),
                          leading: const Icon(Icons.wb_sunny_outlined, color: ThemeManager.primaryYellow),
                          trailing: Switch(value: true, activeColor: ThemeManager.primaryYellow, onChanged: (val) {}),
                        ),
                        const Divider(height: 0, indent: 0.0, endIndent: 20.0, thickness: 0.5),
                        ListTile(
                          title: const Text("Log Out"),
                          leading: const Icon(Icons.logout, color: Colors.red),
                          trailing: const Icon(Icons.arrow_forward_ios, color: ThemeManager.primaryYellow),
                          onTap: () async {
                            try {
                              await FirebaseAuth.instance.signOut();
                              if (!mounted) return;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const SigninScreen()),
                                (route) => false,
                              );
                            } catch (e) {
                              print("Log Out Error: $e");
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}