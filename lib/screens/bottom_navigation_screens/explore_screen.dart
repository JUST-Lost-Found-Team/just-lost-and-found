import 'package:flutter/material.dart';
import 'package:just_lost_and_found/helpers/explore_options.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';

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

  final List<String> allItems = [
    "Wallet",
    "Phone",
    "Keys",
    "Laptop",
    "Bag",
    "ID Card",
    "Headphones",
    "Notebook",
  ];

  List<String> filteredItems = [];

  void searchItem(String query) {
    final results = allItems.where((item) {
      return item.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredItems = results;
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
          onChanged: searchItem,
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
              });
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
                    : const Color.fromARGB(192, 255, 255, 255),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                Categories.categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationList() {
    return Center(child: Text("List"));
  }

  Widget _buildPosts() {
    return Expanded(
      child: filteredItems.isEmpty
          ? const Center(
              child: Text("No results", style: TextStyle(color: Colors.grey)),
            )
          : ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return Card(child: ListTile(title: Text(filteredItems[index])));
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  onSelected: (String value) {
                    setState(() {
                      selectedType = value;
                    });
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'categories',
                          child: Text('Categories'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'location',
                          child: Text('Location'),
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

          _buildPosts(),
        ],
      ),
    );
  }
}
