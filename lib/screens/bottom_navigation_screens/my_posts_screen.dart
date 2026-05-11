import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:just_lost_and_found/screens/bottom_navigation_screens/edit_post_screen.dart';
import 'package:just_lost_and_found/screens/bottom_navigation_screens/post_details.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});
  
  

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeManager.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "My Posts",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('userId', isEqualTo: currentUserId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: ThemeManager.primaryBlue),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.post_add_rounded, size: 100, color: Colors.grey[300]),
                  const SizedBox(height: 15),
                  const Text("No posts yet!", style: TextStyle(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          var docs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.88,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              var docId = docs[index].id;
              return _buildPostCard(data, docId, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> data, String docId, BuildContext context) {
    bool hasImage = data['images'] != null && (data['images'] as List).isNotEmpty;
    String? imageURL = hasImage ? data['images'][0] : null;
    bool isLost = data['status'] == 'Lost';
    bool resolved = data['isResolved'] ?? false;

    return GestureDetector(
        onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailsScreen(post: data, postId: docId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Opacity(
                  opacity: resolved ? 0.5 : 1.0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: hasImage
                        ? Image.network(
                            imageURL!,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                          )
                        : _buildImagePlaceholder(),
                  ),
                ),
                if (!resolved)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isLost ? Colors.red.withOpacity(0.9) : Colors.green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(data["status"] ?? "Lost",
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                if (resolved)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.blueGrey, borderRadius: BorderRadius.circular(10)),
                          child: const Text("RESOLVED", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data['title'] ?? "Untitled",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ThemeManager.primaryBlue),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.more_horiz, size: 18),
                        onSelected: (value) {
                          if (value == 'resolved') _markAsResolved(docId, context);
                          if (value == 'edit') Navigator.push(context, MaterialPageRoute(builder: (context) => EditPostScreen(postData: data, postId: docId)));
                          if (value == 'delete') _showDeleteConfirmation(docId, context); 
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'resolved', child: ListTile(leading: Icon(Icons.check_circle_outline, color: Colors.green), title: Text("Resolved"))),
                          const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit, color: Colors.blue), title: Text("Edit"))),
                          const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text("Delete"))),
                        ],
                      ),
                    ],
                  ),
                  Text(data['description'] ?? "No description", style: TextStyle(color: Colors.grey[700], fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                  //const Divider(height: 10, thickness: 0.5),
                  // Row(
                  //   children: [
                  //     const Icon(Icons.location_on, size: 10, color: ThemeManager.primaryYellow),
                  //     const SizedBox(width: 4),
                  //     Expanded(child: Text(data['location'] ?? "JUST", style: TextStyle(fontSize: 9, color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
                  //   ],
                  // ),
                  // const SizedBox(height: 4),
                  // Row(
                  //   children: [
                  //     const Icon(Icons.category, size: 10, color: ThemeManager.primaryBlue),
                  //     const SizedBox(width: 4),
                  //     Expanded(child: Text(data['category'] ?? "General", style: TextStyle(fontSize: 9, color: Colors.grey[600], fontStyle: FontStyle.italic), overflow: TextOverflow.ellipsis)),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 120,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey),
    );
  }

  
  void _showDeleteConfirmation(String docId, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title:Row(children: [
            Icon(Icons.warning_amber_rounded,color: ThemeManager.errorRed,),
            SizedBox(width: 9,),
            Text("Delete Post",style: TextStyle(fontWeight: FontWeight.bold),),
          ],),
         
        
          
          content: const Text("Are you sure you want to delete this post?\nThis action cannot be undone."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: SizedBox(
                width: 90, height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _deletePost(docId, context);
                  },
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _markAsResolved(String docId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(docId).update({'isResolved': true});
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post marked as resolved!')));
    } catch (e) { debugPrint("Error: $e"); }
  }

  void _deletePost(String docId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(docId).delete();
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post deleted successfully"), backgroundColor: Colors.red));
    } catch (e) { debugPrint("Error: $e"); }
  }
}