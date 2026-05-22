import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_lost_and_found/helpers/post_actions_helper.dart';
import 'package:just_lost_and_found/features/chat/chat_screen.dart';
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
    final String title = data['title'] ?? "post_details.no_title".tr();
    final rawLocation = data['location'];
    List<String> locationsList = [];

    if (rawLocation is List) {
      locationsList = rawLocation.map((e) => e.toString().trim()).toList();
    } else if (rawLocation is String) {
      locationsList = [rawLocation];
    }
    locationsList.sort((a, b) => b.length.compareTo(a.length));
    final String category = data['category'] ?? 'General';
    final String status = data['status'] ?? 'Found';
    final String description =
        data['description'] ?? "post_details.no_description".tr();
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
                              String sName = "post_details.loading".tr();
                              String sImage = "";
                              if (snapshot.hasData && snapshot.data!.exists) {
                                final userData =
                                    snapshot.data!.data()
                                        as Map<String, dynamic>;
                                sName =
                                    userData['name'] ??
                                    "post_details.user".tr();
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
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.access_time_rounded,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  timeAgo,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.category_outlined,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "categories.$category".tr(),
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

                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (FirebaseAuth
                                                .instance
                                                .currentUser
                                                ?.uid ==
                                            widget.post['userId'])
                                          PopupMenuButton<String>(
                                            color: Colors.white,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            child: Icon(
                                              Icons.more_horiz_rounded,
                                              color: Colors.grey[700],
                                              size: 28,
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
                                              PopupMenuItem(
                                                value: 'resolved',
                                                child: ListTile(
                                                  leading: Icon(
                                                    Icons.check_circle_outline,
                                                    color: Colors.green,
                                                  ),
                                                  title: Text(
                                                    "post_actions.mark_resolved_title"
                                                        .tr(),
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
                                                  title: Text(
                                                    "home_page.edit".tr(),
                                                  ),
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: ListTile(
                                                  leading: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  title: Text(
                                                    "post_actions.delete_title"
                                                        .tr(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          const SizedBox(height: 28),
                                        const SizedBox(height: 4),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: status == 'Found'
                                                ? Colors.green
                                                : ThemeManager.errorRed,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            status == 'Found'
                                                ? "main_layout.filter.found"
                                                      .tr()
                                                      .toUpperCase()
                                                : "main_layout.filter.lost"
                                                      .tr()
                                                      .toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                          _buildResolutionPrompt(
                            context,
                            widget.post,
                            widget.postId,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Builder(
                              builder: (context) {
                                bool isArabic = RegExp(
                                  r'[\u0600-\u06FF]',
                                ).hasMatch(description);
                                return Text(
                                  title,
                                  textAlign: isArabic
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  textDirection: isArabic
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
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
                          const SizedBox(height: 24),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_pin,
                                    color: ThemeManager.primaryBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "post_details.location_title".tr(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: locationsList.asMap().entries.map((
                                    entry,
                                  ) {
                                    int index = entry.key;
                                    String loc = entry.value;
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 18.0,
                                            horizontal: 16.0,
                                          ),
                                          child: Text(
                                            "locations.$loc".tr(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),

                                        if (index < locationsList.length - 1)
                                          Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: Colors.grey.shade300,
                                            indent: 20,
                                            endIndent: 20,
                                          ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [const SizedBox(height: 8)],
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
                  String name = "post_details.user".tr();
                  if (snapshot.hasData && snapshot.data!.exists) {
                    name =
                        (snapshot.data!.data() as Map<String, dynamic>)['name']
                            ?.split(' ')[0] ??
                        "post_details.user".tr();
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
                        "post_details.chat_with".tr(args: [name]),
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

  Widget _buildResolutionPrompt(
    BuildContext context,
    Map<String, dynamic> post,
    String postId,
  ) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final bool isOwner = currentUserId == post['userId'];
    final bool isResolved = post['isResolved'] ?? false;
    final String status = post['status'] ?? 'Lost';

    final createdAt =
        (post['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final difference = DateTime.now().difference(createdAt).inDays;

    if (!isOwner || isResolved || difference < 5) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeManager.primaryYellow.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeManager.primaryYellow.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              status == 'Lost'
                  ? "post_details.did_you_find_prompt".tr()
                  : "post_details.was_returned_prompt".tr(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: ThemeManager.primaryBlue,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () async {
              PostActionsHelper.markAsResolved(
                context,
                postId,
                onSuccess: () => Navigator.pop(context),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeManager.primaryYellow,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              "post_details.resolve_btn".tr(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
