import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_lost_and_found/screens/bottom_navigation_screens/post_details.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';
import 'package:just_lost_and_found/helpers/date_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_lost_and_found/helpers/post_actions_helper.dart';

class HomePage extends StatefulWidget {
  final String filter;

  const HomePage({Key? key, required this.filter}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, Future<DocumentSnapshot>> _userFuturesCache = {};

  @override
  Widget build(BuildContext context) {
    Query postsQuery = FirebaseFirestore.instance
        .collection("posts")
        .where("isResolved", isEqualTo: false);

    if (widget.filter != 'All') {
      postsQuery = postsQuery.where("status", isEqualTo: widget.filter);
    }

    postsQuery = postsQuery.orderBy("createdAt", descending: true);

    return Scaffold(
      backgroundColor: const Color(0xFFD5D5D5),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: postsQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: ThemeManager.primaryBlue,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "home_page.error_msg".tr() + snapshot.error.toString(),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "home_page.no_posts".tr(),
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final posts = snapshot.data!.docs;

                return RefreshIndicator(
                  color: ThemeManager.primaryBlue,
                  backgroundColor: Colors.white,

                  onRefresh: () async {
                    setState(() {
                      _userFuturesCache.clear();
                    });

                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final postDoc = posts[index];
                      final docId = postDoc.id;
                      final post = postDoc.data() as Map<String, dynamic>;
                      final title = post['title'] ?? 'home_page.no_title'.tr();
                      final description =
                          post['description'] ??
                          'home_page.no_description'.tr();
                      final location =
                          post['location'] ?? 'home_page.unknown_location'.tr();
                      final status =
                          post['status'] ?? 'main_layout.filter.lost".tr()';
                      final createdAt = post['createdAt'];
                      final images = post['images'] as List<dynamic>? ?? [];

                      final postUserId = post['userId'];

                      return _buildPostCard(
                        post: post,
                        docId: docId,
                        title: title,
                        description: description,
                        location: location,
                        status: status,
                        createdAt: createdAt,
                        images: images,
                        userId: postUserId,
                      );
                    },
                  ),
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
    required String docId,
    required String title,
    required String description,
    required dynamic location,
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

    final rawLocation = post['location'];
    List<dynamic> locationsList = [];

    if (rawLocation is List) {
      locationsList = rawLocation;
    } else if (rawLocation is String) {
      locationsList = [rawLocation];
    }
    String displayLocation = "home_page.unknown_location".tr();

    if (locationsList.isNotEmpty) {
      List<String> processedLocs = locationsList.map((loc) {
        String s = "locations.${loc.toString().trim()}".tr();

        if (s.contains('-')) {
          s = s.split('-').last.trim();
        }

        if (s.toLowerCase().startsWith('the ')) {
          s = s.substring(4).trim();
        }

        return s;
      }).toList();

      displayLocation = processedLocs.join(', ');
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailsScreen(post: post, postId: docId),
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
                    postUserName =
                        userData['name'] ?? "home_page.unknown_user".tr();
                    postAvatarUrl = userData['profileImage'];
                  } else if (userSnapshot.connectionState ==
                      ConnectionState.done) {
                    postUserName = "home_page.unknown_user".tr();
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

                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 12,
                                  color: Colors.grey[700],
                                ),
                                Expanded(
                                  child: Text(
                                    displayLocation,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 2),

                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  DateHelper.getTimeAgo(createdAt),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
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

                                  child: PopupMenuButton<String>(
                                    color: Colors.grey[100],

                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.more_horiz,
                                      size: 24,
                                    ),
                                    onSelected: (value) {
                                      if (value == 'resolved') {
                                        PostActionsHelper.markAsResolved(
                                          context,
                                          docId,
                                        );
                                      } else if (value == 'edit') {
                                        PostActionsHelper.editPost(
                                          context,
                                          docId,
                                          post,
                                        );
                                      } else if (value == 'delete') {
                                        PostActionsHelper.deletePost(
                                          context,
                                          docId,
                                        );
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => [
                                      PopupMenuItem(
                                        value: 'resolved',
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green,
                                          ),
                                          title: Text(
                                            'home_page.mark_resolved'.tr(),
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          title: Text('home_page.edit'.tr()),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          title: Text('home_page.delete'.tr()),
                                        ),
                                      ),
                                    ],
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
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              status == 'Lost'
                                  ? "main_layout.filter.lost".tr().toUpperCase()
                                  : "main_layout.filter.found"
                                        .tr()
                                        .toUpperCase(),
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
              SizedBox(
                width: double.infinity,
                child: Builder(
                  builder: (context) {
                    bool isArabic = RegExp(
                      r'[\u0600-\u06FF]',
                    ).hasMatch(description);
                    return Text(
                      title,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      textDirection: isArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),

              SizedBox(
                width: double.infinity,
                child: Builder(
                  builder: (context) {
                    bool isArabic = RegExp(
                      r'[\u0600-\u06FF]',
                    ).hasMatch(description);

                    return RichText(
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      textDirection: isArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
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
                            TextSpan(
                              text: "home_page.see_more".tr(),
                              style: const TextStyle(
                                color: ThemeManager.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
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
