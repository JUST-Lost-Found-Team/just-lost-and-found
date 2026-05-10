import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_lost_and_found/helpers/post_actions_helper.dart';
import 'package:just_lost_and_found/screens/bottom_navigation_screens/chat_screen.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';
import 'package:just_lost_and_found/helpers/date_helper.dart';

class PostDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final String postId;
  const PostDetailsScreen({
    super.key,
    required this.post,
    required this.postId,
  });

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  int _currentImageIndex = 0;
  late Future<DocumentSnapshot> _postUserFuture;

  @override
  void initState() {
    super.initState();
    final String userId = widget.post['userId'] ?? '';
    _postUserFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.post;
    final List<dynamic> images = data['images'] ?? [];
    final String title = data['title'] ?? 'No Title';
    final String location = data['location'] ?? 'Unknown Location';
    final String category = data['category'] ?? 'General';
    final String status = data['status'] ?? 'Found';
    final String description = data['description'] ?? 'No Description';
    final timeAgo = DateHelper.getTimeAgo(data['createdAt']);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: images.isNotEmpty ? 280.0 : null,
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: ThemeManager.primaryBlue,
                elevation: 0,

                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black12.withOpacity(0.42),
                    ),

                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                flexibleSpace: images.isNotEmpty
                    ? FlexibleSpaceBar(
                        background: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            PageView.builder(
                              itemCount: images.length,
                              onPageChanged: (index) =>
                                  setState(() => _currentImageIndex = index),
                              itemBuilder: (context, index) {
                                return CachedNetworkImage(
                                  imageUrl: images[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                );
                              },
                            ),
                            if (images.length > 1)
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: images.asMap().entries.map((entry) {
                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      width: _currentImageIndex == entry.key
                                          ? 24.0
                                          : 12.0,
                                      height: 12.0,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: _currentImageIndex == entry.key
                                            ? ThemeManager.primaryBlue
                                            : Colors.white,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      )
                    : null,
              ),

              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    if (images.isEmpty)
                      Container(
                        height: 70,
                        width: double.infinity,
                        color: ThemeManager.primaryBlue,
                      ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          SizedBox(height: images.isEmpty ? 25 : 20),

                          FutureBuilder<DocumentSnapshot>(
                            future: _postUserFuture,
                            builder: (context, snapshot) {
                              String sName = "Loading...";
                              String sImage = "";
                              if (snapshot.hasData && snapshot.data!.exists) {
                                final userData =
                                    snapshot.data!.data()
                                        as Map<String, dynamic>;
                                sName = userData['name'] ?? "User";
                                sImage = userData['profileImage'] ?? "";
                              }

                              return Container(
                                padding: images.isEmpty
                                    ? const EdgeInsets.all(16)
                                    : EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),

                                  boxShadow: images.isEmpty
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.08,
                                            ),
                                            blurRadius: 15,
                                            offset: const Offset(0, 5),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundImage: sImage.isNotEmpty
                                              ? CachedNetworkImageProvider(
                                                  sImage,
                                                )
                                              : null,
                                          child: sImage.isEmpty
                                              ? const Icon(Icons.person)
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: ThemeManager.primaryBlue,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.access_time_rounded,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  timeAgo,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (FirebaseAuth
                                            .instance
                                            .currentUser
                                            ?.uid ==
                                        widget.post['userId'])
                                      PopupMenuButton<String>(
                                        color: Colors.white,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.more_horiz_rounded,
                                              color: Colors.grey[700],
                                              size: 28,
                                            ),
                                          ],
                                        ),
                                        onSelected: (value) {
                                          if (value == 'resolved') {
                                            PostActionsHelper.markAsResolved(
                                              context,
                                              widget.postId,
                                              onSuccess: () =>
                                                  Navigator.pop(context),
                                            );
                                          } else if (value == 'edit') {
                                            PostActionsHelper.editPost(
                                              context,
                                              widget.postId,
                                              data,
                                            );
                                          } else if (value == 'delete') {
                                            PostActionsHelper.deletePost(
                                              context,
                                              widget.postId,
                                              onSuccess: () =>
                                                  Navigator.pop(context),
                                            );
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => [
                                          const PopupMenuItem(
                                            value: 'resolved',
                                            child: ListTile(
                                              leading: Icon(
                                                Icons.check_circle_outline,
                                                color: Colors.green,
                                              ),
                                              title: Text('Mark as resolved'),
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: ListTile(
                                              leading: Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                              ),
                                              title: Text('Edit'),
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: ListTile(
                                              leading: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              title: Text('Delete'),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildCustomChip(
                                  Icons.verified_rounded,
                                  "status",
                                  status,
                                  isStatus: true,
                                ),
                                _buildCustomChip(
                                  Icons.location_pin,
                                  "Location",
                                  location,
                                ),
                                _buildCustomChip(
                                  Icons.category,
                                  "Category",
                                  category,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Description",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: Builder(
                                    builder: (context) {
                                      bool isArabic = RegExp(
                                        r'[\u0600-\u06FF]',
                                      ).hasMatch(description);
                                      return Text(
                                        description,
                                        textAlign: isArabic
                                            ? TextAlign.right
                                            : TextAlign.left,
                                        textDirection: isArabic
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          height: 1.4,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (FirebaseAuth.instance.currentUser?.uid != widget.post['userId'])
            Positioned(
              bottom: 30,
              left: 30,
              right: 30,
              child: FutureBuilder<DocumentSnapshot>(
                future: _postUserFuture,
                builder: (context, snapshot) {
                  String name = "User";
                  if (snapshot.hasData && snapshot.data!.exists) {
                    name =
                        (snapshot.data!.data() as Map<String, dynamic>)['name']
                            ?.split(' ')[0] ??
                        "User";
                  }
                  return SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Map<String, dynamic> postDataWithId = Map.from(
                          widget.post,
                        );
                        postDataWithId['postId'] = widget.postId;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              receiverId: widget.post['userId'],
                              receiverName: name,
                              postData: postDataWithId,
                            ),
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF326182),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Chat with $name",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomChip(
    IconData icon,
    String label,
    String value, {
    bool isStatus = false,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[700]),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 5),
          isStatus
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: value == 'Found' ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
        ],
      ),
    );
  }
}
