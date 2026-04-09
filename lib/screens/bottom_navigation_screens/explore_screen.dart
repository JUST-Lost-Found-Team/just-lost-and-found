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
    //filteredItems = allItems;
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

  int selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          SizedBox(height: 10),
          SizedBox(
            width: 335,
            height: 50,
            child: TextField(
              cursorColor: ThemeManager.primaryBlue,
              controller: searchController,
              focusNode: _focusNode,
              onChanged: searchItem,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: _focusNode.hasFocus
                    ? const Color(0xFFF0F0F9)
                    : const Color.fromARGB(255, 224, 224, 233),
                hintText: "Search...",
                hintStyle: TextStyle(fontSize: 15),
                prefixIcon: Icon(
                  Icons.search,
                  color: _focusNode.hasFocus
                      ? ThemeManager.primaryBlue
                      : Colors.grey[700],
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
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: ThemeManager.primaryBlue,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 5),

          SizedBox(
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
                          color: const Color.fromARGB(255, 171, 170, 170),
                          blurRadius: 5,
                          offset: Offset(0, 4),
                        ),
                      ],
                      color: isSelected
                          ? ThemeManager.primaryYellow
                          : const Color(0xFFF0F0F9),
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
          ),

          SizedBox(height: 20),

          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      "No results",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(title: Text(filteredItems[index])),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
