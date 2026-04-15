import 'package:flutter/material.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';
import 'bottom_navigation_screens/home_screen.dart';
import 'bottom_navigation_screens/chats_screen.dart';
import 'bottom_navigation_screens/explore_screen.dart';
import 'bottom_navigation_screens/profile_screen.dart';
import 'bottom_navigation_screens/add_post_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({Key? key}) : super(key: key);

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> pages = [HomePage(), ExplorePage(), Chat(), ProfileScreen()];
  final List pageTitles = ["Home", "Explore", "Messages", "Profile"];
  String selectedFilter = "All";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        titleSpacing: 20,
        backgroundColor: ThemeManager.primaryBlue,
        elevation: 5,

        title: _currentIndex == 0
            ? Image.asset("assets/images/logo.png", height: 50)
            : Text(
                pageTitles[_currentIndex],
                style: TextStyle(color: Colors.white),
              ),
        centerTitle: _currentIndex == 0 ? false : true,
        actions: [
          if (_currentIndex == 0) ...[
            IconButton(
              icon: const Icon(Icons.notifications_rounded),
              color: Colors.white,
              onPressed: () {},
            ),

            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_alt_rounded, color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              offset: const Offset(0, 45),
              onSelected: (String newValue) {
                setState(() {
                  selectedFilter = newValue;
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'All',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All',
                        style: TextStyle(
                          fontWeight: selectedFilter == 'All'
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selectedFilter == 'All'
                              ? ThemeManager.primaryBlue
                              : Colors.black87,
                        ),
                      ),
                      if (selectedFilter == 'All')
                        Icon(
                          Icons.check,
                          color: ThemeManager.primaryBlue,
                          size: 20,
                        ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Lost',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lost',
                        style: TextStyle(
                          fontWeight: selectedFilter == 'Lost'
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selectedFilter == 'Lost'
                              ? ThemeManager.primaryBlue
                              : Colors.black87,
                        ),
                      ),
                      if (selectedFilter == 'Lost')
                        Icon(
                          Icons.check,
                          color: ThemeManager.primaryBlue,
                          size: 20,
                        ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Found',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Found',
                        style: TextStyle(
                          fontWeight: selectedFilter == 'Found'
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selectedFilter == 'Found'
                              ? ThemeManager.primaryBlue
                              : Colors.black87,
                        ),
                      ),
                      if (selectedFilter == 'Found')
                        Icon(
                          Icons.check,
                          color: ThemeManager.primaryBlue,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: pages[_currentIndex],

      floatingActionButton: SizedBox(
        height: 55,
        width: 55,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPost()),
            );
          },
          backgroundColor: ThemeManager.primaryYellow,
          child: const Icon(
            Icons.add,
            size: 35,
            color: ThemeManager.primaryBlue,
          ),
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
