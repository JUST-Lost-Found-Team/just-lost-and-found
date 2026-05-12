import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_lost_and_found/helpers/date_helper.dart';
import 'package:just_lost_and_found/helpers/explore_options.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_lost_and_found/helpers/post_actions_helper.dart';
import 'post_details.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    loadPosts();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  final TextEditingController searchController = TextEditingController();

  bool isLoading = false;

  List<Map<String, dynamic>> allPosts = [];
  List<Map<String, dynamic>> filteredPosts = [];

  Future<void> loadPosts() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where("isResolved", isEqualTo: false)
        .orderBy("createdAt", descending: true)
        .get();

    allPosts = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['docId'] = doc.id;
      return data;
    }).toList();

    applyFilters();

    setState(() {
      isLoading = false;
    });
  }

  void searchItem(String query) {
    final results = allPosts.where((post) {
      final title = post['title'].toString().toLowerCase();

      return title.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredPosts = results;
    });
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 50,
        child: TextField(
          cursorColor: ThemeManager.primaryBlue,
          controller: searchController,
          focusNode: _focusNode,
          onChanged: (value) {
            applyFilters();
            selectedLocationFilter = null;
            selectedCategory = 0;
          },
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color.fromARGB(192, 255, 255, 255),
            hintText: "Search for items...",
            hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
            prefixIcon: Icon(
              Icons.search,
              color: ThemeManager.primaryBlue,
              size: 25,
            ),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      searchItem("");
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(color: Colors.white, width: 0.1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(color: Colors.grey, width: 0.1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: ThemeManager.primaryBlue,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String selectedType = "Categories";
  int selectedCategory = 0;

  String? selectedLocationFilter;

  void applyFilters() {
    final selectedCategoryName = Categories.categories[selectedCategory];
    final query = searchController.text.trim().toLowerCase();

    final bool isSearching = query.isNotEmpty;
    final bool isFilteringByLocation = selectedLocationFilter != null;

    final results = allPosts.where((post) {
      final title = post['title']?.toString().toLowerCase() ?? '';
      final description = post['description']?.toString().toLowerCase() ?? '';
      final category = post['category']?.toString().trim().toLowerCase() ?? '';
      final location = post['location']?.toString().trim().toLowerCase() ?? '';

      if (isSearching) {
        return title.contains(query) || description.contains(query);
      }

      if (isFilteringByLocation) {
        return location == selectedLocationFilter!.trim().toLowerCase();
      }
      selectedLocationFilter = null;

      return category == selectedCategoryName.trim().toLowerCase();
    }).toList();

    setState(() {
      filteredPosts = results;
    });
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 55,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(vertical: 5),
        itemCount: Categories.categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedCategory == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = index;
                searchController.clear();
              });

              applyFilters();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 6),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ],
                color: isSelected
                    ? ThemeManager.primaryYellow
                    : Color.fromARGB(236, 255, 255, 255),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    categoryIcons.icons[Categories.categories[index]],
                    size: 18,
                    color: isSelected ? Colors.white : ThemeManager.primaryBlue,
                  ),

                  SizedBox(width: 6),

                  Text(
                    Categories.categories[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : ThemeManager.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () async {
          searchController.clear();
          final result = await showModalBottomSheet<String>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const LocationSelectionSheet(),
          );

          if (result != null) {
            setState(() {
              selectedLocationFilter = result;
            });
            FocusManager.instance.primaryFocus?.unfocus();
            applyFilters();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(
                Icons.map_outlined,
                color: ThemeManager.primaryYellow,
                size: 30,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selectedLocationFilter ?? "Campus facilities",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedLocationFilter == null
                          ? "find items by specific building"
                          : "Tap to change building",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey.shade400,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosts() {
    if (selectedType == "Location" &&
        selectedLocationFilter == null &&
        searchController.text.isEmpty) {
      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 70,
                  width: 120,
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 60,
                    color: const Color.fromARGB(97, 228, 151, 63),
                  ),
                ),

                // Title
                Text(
                  "Select a location to continue",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),

                SizedBox(height: 2),

                Container(
                  width: 200,
                  child: Text(
                    "Choose a campus facility above to explore available items in that area",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Expanded(
        child: filteredPosts.isEmpty
            ? const Center(
                child: Text("No posts", style: TextStyle(color: Colors.grey)),
              )
            : RefreshIndicator(
                onRefresh: loadPosts,
                color: ThemeManager.primaryBlue,
                backgroundColor: Colors.white,
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = filteredPosts[index];
                    final title = post['title'] ?? 'No Title';
                    final docId = post['docId'];
                    final status = post['status'] ?? 'Found';
                    final description = post['description'] ?? 'No Description';
                    final createdAt = post['createdAt'];
                    final images = post['images'] as List<dynamic>? ?? [];
                    final postUserId = post['userId'];
                    final String category = post['category'] ?? 'General';

                    return _buildPostCard(
                      context: context,
                      post: post,
                      docId: docId,
                      title: title,
                      status: status,
                      createdAt: createdAt,
                      description: description,
                      images: images,
                      userId: postUserId,
                      category: category,
                    );
                  },
                ),
              ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFD5D5D5),
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            SizedBox(height: 20),

            _buildSearch(),

            SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    "Browse by  ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    offset: const Offset(0, 30),
                    onOpened: () {
                      setState(() {
                        searchController.clear();
                      });
                    },
                    color: Colors.white,
                    onSelected: (String value) {
                      setState(() {
                        selectedType = value;
                        FocusManager.instance.primaryFocus?.unfocus();
                        FocusScope.of(context).unfocus();
                        if (selectedType == "Categories") {
                          selectedLocationFilter = null;
                          selectedCategory = 0;
                          applyFilters();
                        }
                      });
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'Categories',
                            child: selectedType == 'Categories'
                                ? Text(
                                    'Categories',
                                    style: TextStyle(
                                      color: ThemeManager.primaryYellow,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Text("Categories"),
                          ),
                          PopupMenuItem<String>(
                            value: 'Location',
                            child: selectedType == 'Location'
                                ? Text(
                                    'Location',
                                    style: TextStyle(
                                      color: ThemeManager.primaryYellow,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Text('Location'),
                          ),
                        ],

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeManager.primaryYellow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedType,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            SizedBox(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: selectedType.toLowerCase() == 'categories'
                    ? _buildCategoryList()
                    : _buildLocationList(),
              ),
            ),

            SizedBox(height: 15),

            isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: ThemeManager.primaryBlue,
                    ),
                  )
                : _buildPosts(),
          ],
        ),
      ),
    );
  }
}

class LocationSelectionSheet extends StatelessWidget {
  const LocationSelectionSheet({Key? key}) : super(key: key);

  IconData getCategoryIcon(String category) {
    if (category.contains("Medical")) return Icons.local_hospital;
    if (category.contains("Engineering")) return Icons.engineering;
    return Icons.account_balance;
  }

  @override
  Widget build(BuildContext context) {
    final locations = LocationData.locations;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),

          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 15),

          const Text(
            "Select Location",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          Expanded(
            child: ListView.builder(
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final location = locations[index];

                final parts = location.split(" - ");
                final category = parts[0];
                final building = parts.length > 1 ? parts[1] : "";

                final fullCategoryName = category == "General"
                    ? "General Facilities"
                    : "$category Buildings";

                bool showHeader = false;
                if (index == 0) {
                  showHeader = true;
                } else {
                  final prevLocation = locations[index - 1];
                  final prevCategory = prevLocation.split(" - ")[0];
                  if (category != prevCategory) {
                    showHeader = true;
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeader)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          top: 15,
                          bottom: 5,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              getCategoryIcon(category),
                              color: ThemeManager.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              fullCategoryName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: ThemeManager.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),

                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 25,
                      ),
                      leading: Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey.shade500,
                      ),
                      title: Text(
                        building,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        fullCategoryName,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context, location);
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          Row(children: [Column(children: [])]),
        ],
      ),
    );
  }
}

Widget _buildPostCard({
  required BuildContext context,
  required Map<String, dynamic> post,
  required docId,
  required String title,
  required String status,
  required String description,
  required dynamic createdAt,
  required List<dynamic> images,
  required String? userId,
  required String category,
}) {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
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
      child: images.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (images.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        images[0],
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 90,
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  SizedBox(height: 4),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: 2),

                        Text(
                          DateHelper.getTimeAgo(createdAt),
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 5),

                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: description.length > 28
                                  ? "${description.substring(0, 28)}... "
                                  : description,
                            ),
                            if (description.length > 28)
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
                    ),
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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

                      SizedBox(width: 3),

                      if (currentUserId == userId)
                        SizedBox(
                          height: 22,

                          child: PopupMenuButton<String>(
                            color: Colors.grey[100],

                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.more_horiz, size: 24),
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
                                PostActionsHelper.deletePost(context, docId);
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
                                  leading: Icon(Icons.edit, color: Colors.blue),
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
                        ),
                    ],
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: 2),

                        Text(
                          DateHelper.getTimeAgo(createdAt),
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: description.length > 95
                                  ? "${description.substring(0, 95)}... "
                                  : description,
                            ),
                            if (description.length > 95)
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
                    ),
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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

                      SizedBox(width: 3),

                      if (currentUserId == userId)
                        SizedBox(
                          height: 22,

                          child: PopupMenuButton<String>(
                            color: Colors.grey[100],

                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.more_horiz, size: 24),
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
                                PostActionsHelper.deletePost(context, docId);
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
                                  leading: Icon(Icons.edit, color: Colors.blue),
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
                        ),
                    ],
                  ),
                ],
              ),
            ),
    ),
  );
}
