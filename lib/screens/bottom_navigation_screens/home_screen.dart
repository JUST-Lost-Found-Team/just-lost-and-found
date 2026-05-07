import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_lost_and_found/screens/bottom_navigation_screens/post_details.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';
import 'package:just_lost_and_found/helpers/date_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, Future<DocumentSnapshot>> _userFuturesCache = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5D5D5),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("posts")
                  .where("isResolved", isEqualTo: false)
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: ThemeManager.primaryBlue,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No posts available yet.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final posts = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index].data() as Map<String, dynamic>;

                    final title = post['title'] ?? 'No Title';
                    final description = post['description'] ?? 'No Description';
                    final location = post['location'] ?? 'Unknown Location';
                    final status = post['status'] ?? 'Found';
                    final createdAt = post['createdAt'];
                    final images = post['images'] as List<dynamic>? ?? [];

                    final postUserId = post['userId'];

                    return _buildPostCard(
                      post: post,
                      title: title,
                      description: description,
                      location: location,
                      status: status,
                      createdAt: createdAt,
                      images: images,
                      userId: postUserId,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard({
    required Map<String, dynamic> post,
    required String title,
    required String description,
    required String location,
    required String status,
    required dynamic createdAt,
    required List<dynamic> images,
    required String? userId,
  }) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null && !_userFuturesCache.containsKey(userId)) {
      _userFuturesCache[userId] = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailsScreen(post: post),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<DocumentSnapshot>(
                future: userId != null ? _userFuturesCache[userId] : null,
                builder: (context, userSnapshot) {
                  String postUserName = "";
                  String? postAvatarUrl;

                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    postUserName = userData['name'] ?? "Unknown User";
                    postAvatarUrl = userData['profileImage'];
                  } else if (userSnapshot.connectionState ==
                      ConnectionState.done) {
                    postUserName = "Unknown User";
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ThemeManager.primaryYellow,
                            width: 2.5,
                          ),
                        ),
                        child: postAvatarUrl != null
                            ? CachedNetworkImage(
                                imageUrl: postAvatarUrl,
                                imageBuilder: (context, imageProvider) =>
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundImage: imageProvider,
                                    ),
                                placeholder: (context, url) =>
                                    const CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.grey,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    ),
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.grey,
                                      child: Icon(
                                        Icons.error,
                                        color: Colors.white,
                                      ),
                                    ),
                              )
                            : CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              postUserName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: ThemeManager.primaryBlue,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              location.split("-").last,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateHelper.getTimeAgo(createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          currentUserId == userId
                              ? SizedBox(
                                  height: 22,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.more_horiz_rounded,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : const SizedBox(height: 22),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: status == 'Lost'
                                  ? ThemeManager.errorRed
                                  : ThemeManager.successGreen,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 12),

              Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: description.length > 80
                                ? "${description.substring(0, 80)}... "
                                : description,
                          ),
                          if (description.length > 80)
                            const TextSpan(
                              text: "see more",
                              style: TextStyle(
                                color: ThemeManager.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              if (images.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: images[0],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.grey[400],
                          size: 40,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 40,
                        ),
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
}
