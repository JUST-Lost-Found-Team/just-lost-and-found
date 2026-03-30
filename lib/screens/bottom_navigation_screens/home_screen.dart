import 'package:flutter/material.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  int _currentIndex = 0;

  final List<String> categories = [
    "All",
    "Electronics",
    "Clothes",
    "Accessories",
    "Documents",
    "Others",
  ];

  int selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeManager.primaryBlue,
        elevation: 5,
        title: const Text("JLF", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            color: Colors.white,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                "No posts yet",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: SizedBox(
        height: 55,
        width: 55,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: ThemeManager.primaryYellow,
          child: const Icon(Icons.add, size: 35, color: Colors.black),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => setState(() => _currentIndex = 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home,
                          size: 28,
                          color: _currentIndex == 0
                              ? ThemeManager.primaryYellow
                              : ThemeManager.primaryBlue,
                        ),
                        Text(
                          "Home",
                          style: TextStyle(
                            fontSize: 12,
                            color: _currentIndex == 0
                                ? ThemeManager.primaryYellow
                                : ThemeManager.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 35),
                  GestureDetector(
                    onTap: () => setState(() => _currentIndex = 1),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.manage_search_outlined,
                          size: 28,
                          color: _currentIndex == 1
                              ? ThemeManager.primaryYellow
                              : ThemeManager.primaryBlue,
                        ),
                        Text(
                          "Explore",
                          style: TextStyle(
                            fontSize: 12,
                            color: _currentIndex == 1
                                ? ThemeManager.primaryYellow
                                : ThemeManager.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _currentIndex = 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat,
                          size: 28,
                          color: _currentIndex == 2
                              ? ThemeManager.primaryYellow
                              : ThemeManager.primaryBlue,
                        ),
                        Text(
                          "Messages",
                          style: TextStyle(
                            fontSize: 12,
                            color: _currentIndex == 2
                                ? ThemeManager.primaryYellow
                                : ThemeManager.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 30),
                  GestureDetector(
                    onTap: () => setState(() => _currentIndex = 3),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person,
                          size: 28,
                          color: _currentIndex == 3
                              ? ThemeManager.primaryYellow
                              : ThemeManager.primaryBlue,
                        ),
                        Text(
                          "Profile",
                          style: TextStyle(
                            fontSize: 12,
                            color: _currentIndex == 3
                                ? ThemeManager.primaryYellow
                                : ThemeManager.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
