import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
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

  Widget _buildSearch() {
    final theme = Theme.of(context);
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
            fillColor: theme.cardColor,
            // fillColor: const Color.fromARGB(192, 255, 255, 255),
            hintText: "explore_page.search_hint".tr(),
            hintStyle: const TextStyle(fontSize: 15, color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: theme.primaryColor, size: 25),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      applyFilters();
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
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (post['userId'] == currentUserId) {
        return false;
      }

      final title = post['title']?.toString().toLowerCase() ?? '';
      final description = post['description']?.toString().toLowerCase() ?? '';
      final category = post['category']?.toString().trim().toLowerCase() ?? '';
      final location = post['location']?.toString().trim().toLowerCase() ?? '';

      final normalizedTitle = normalizeArabic(title);
      final normalizedDescription = normalizeArabic(description);
      final normalizedQuery = normalizeArabic(query);

      if (isSearching) {
        return normalizedTitle.contains(normalizedQuery) ||
            normalizedDescription.contains(normalizedQuery);
      }

      if (isFilteringByLocation) {
        return location.contains(selectedLocationFilter!.trim().toLowerCase());
      }
      selectedLocationFilter = null;

      return category == selectedCategoryName.trim().toLowerCase();
    }).toList();

    setState(() {
      filteredPosts = results;
    });
  }

  Widget _buildCategoryList() {
    final theme = Theme.of(context);
    return SizedBox(
      height: 55,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 5),
        itemCount: Categories.categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedCategory == index;
          final catName = Categories.categories[index];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = index;
                searchController.clear();
                FocusScope.of(context).unfocus();
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
                    blurRadius: 5,
                    spreadRadius: -4,
                  ),
                ],
                color: isSelected
                    ? ThemeManager.primaryYellow
                    : theme.cardColor,
                //const Color.fromARGB(236, 255, 255, 255),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    categoryIcons.icons[catName],
                    size: 18,
                    color: isSelected ? Colors.white : theme.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "categories.$catName".tr(),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : theme.textTheme.titleMedium!.color,
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

  String normalizeArabic(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[أإآٱى]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'[ئ]'), 'ي')
        .trim();
  }

  Widget _buildLocationList() {
    final theme = Theme.of(context);
    String displayLocation = "explore_page.campus_facilities".tr();
    if (selectedLocationFilter != null) {
      String translatedLoc = "locations.$selectedLocationFilter".tr();
      displayLocation = translatedLoc.contains("-")
          ? translatedLoc.split("-").last.trim()
          : translatedLoc;
    }

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
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              const Icon(
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
                      displayLocation,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.textTheme.titleMedium!.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedLocationFilter == null
                          ? "explore_page.find_items_by_building".tr()
                          : "explore_page.tap_to_change_building".tr(),
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
                const SizedBox(
                  height: 70,
                  width: 120,
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 60,
                    color: Color.fromARGB(97, 228, 151, 63),
                  ),
                ),
                Text(
                  "explore_page.select_location_continue".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: 200,
                  child: Text(
                    "explore_page.choose_campus_facility".tr(),
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
            ? Center(
                child: Text(
                  "explore_page.no_posts".tr(),
                  style: const TextStyle(color: Colors.grey),
                ),
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
                    final title = post['title'] ?? "explore_page.no_title".tr();
                    final docId = post['docId'];
                    final status = post['status'] ?? 'Found';
                    final description =
                        post['description'] ??
                        "explore_page.no_description".tr();
                    final createdAt = post['createdAt'];
                    final images = post['images'] as List<dynamic>? ?? [];
                    final postUserId = post['userId'];
                    final String category = post['category'] ?? 'General';

                    return _buildPostCard(
                      focusNode: _focusNode,
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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        //  backgroundColor: const Color(0xFFD5D5D5),
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            const SizedBox(height: 20),
            _buildSearch(),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    "explore_page.browse_by".tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  PopupMenuButton<String>(
                    color: theme.popupMenuTheme.color,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    offset: const Offset(0, 30),
                    onOpened: () {
                      setState(() {
                        searchController.clear();
                      });
                    },
                    //  color: Colors.white,
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
                            child: Text(
                              "explore_page.categories_type".tr(),
                              style: TextStyle(
                                color: selectedType == 'Categories'
                                    ? ThemeManager.primaryYellow
                                    : theme.textTheme.titleMedium!.color,
                                fontWeight: selectedType == 'Categories'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'Location',
                            child: Text(
                              "explore_page.location_type".tr(),
                              style: TextStyle(
                                color: selectedType == 'Location'
                                    ? ThemeManager.primaryYellow
                                    : theme.textTheme.titleMedium!.color,
                                fontWeight: selectedType == 'Location'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
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
                            selectedType == 'Categories'
                                ? "explore_page.categories_type".tr()
                                : "explore_page.location_type".tr(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
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
            const SizedBox(height: 10),
            SizedBox(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: selectedType.toLowerCase() == 'categories'
                    ? _buildCategoryList()
                    : _buildLocationList(),
              ),
            ),
            const SizedBox(height: 15),
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
    final theme = Theme.of(context);
    final locations = LocationData.locations;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.cardColor,
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
          Text(
            "explore_page.select_location_sheet_title".tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final location = locations[index];

                final parts = location.split(" - ");
                final category = parts[0];

                String translatedLoc = "locations.$location".tr();
                String building = translatedLoc.contains("-")
                    ? translatedLoc.split("-").last.trim()
                    : translatedLoc;

                final fullCategoryName = category == "General"
                    ? "explore_page.general_facilities".tr()
                    : "explore_page.buildings_format".tr(
                        args: ["categories.$category".tr()],
                      );

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
                              color: theme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              fullCategoryName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
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
          const Row(children: []),
        ],
      ),
    );
  }
}

Widget _buildPostCard({
  required FocusNode focusNode,
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
  final theme = Theme.of(context);
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  bool isArabicDesc = RegExp(r'[\u0600-\u06FF]').hasMatch(description);

  return GestureDetector(
    onTap: () {
      focusNode.unfocus();
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
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            images.isNotEmpty
                ? ClipRRect(
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
                          color: Colors.grey,
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 90,
                      color: Colors.grey.shade400,
                      child: Center(
                        child: Icon(
                          categoryIcons.icons[category],
                          color: Colors.grey.shade200,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title.length > 18 ? "${title.substring(0, 18)}... " : title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      //   color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateHelper.getTimeAgo(createdAt),
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Directionality(
              textDirection: isArabicDesc
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Center(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      //  color: Colors.black87,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: description.length > 28
                            ? "${description.substring(0, 28)}... "
                            : description,
                        style: TextStyle(
                          color: theme.textTheme.titleMedium!.color,
                        ),
                      ),
                      if (description.length > 28)
                        TextSpan(
                          text: "explore_page.see_more".tr(),
                          style: TextStyle(
                            color: theme.primaryColor,
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
                    status == 'Found'
                        ? "main_layout.filter.found".tr().toUpperCase()
                        : "main_layout.filter.lost".tr().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                if (currentUserId == userId)
                  SizedBox(
                    height: 22,
                    child: PopupMenuButton<String>(
                      color: theme.popupMenuTheme.color,

                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.more_horiz, size: 24),
                      onSelected: (value) {
                        if (value == 'resolved') {
                          PostActionsHelper.markAsResolved(context, docId);
                        } else if (value == 'edit') {
                          PostActionsHelper.editPost(context, docId, post);
                        } else if (value == 'delete') {
                          PostActionsHelper.deletePost(context, docId);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: 'resolved',
                          child: ListTile(
                            leading: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                            ),
                            title: Text(
                              "post_actions.mark_resolved_title".tr(),
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: const Icon(Icons.edit, color: Colors.blue),
                            title: Text("home_page.edit".tr()),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            title: Text("post_actions.delete_title".tr()),
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
