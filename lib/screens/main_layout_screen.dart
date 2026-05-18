import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';
import 'bottom_navigation_screens/home_screen.dart';
import 'bottom_navigation_screens/chat_list_screen.dart';
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

  String selectedFilter = "Found";

  List<Widget> get pages => [
    HomePage(filter: selectedFilter),
    ExplorePage(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  List<String> get pageTitles => [
    "main_layout.page_titles.home".tr(),
    "main_layout.page_titles.explore".tr(),
    "main_layout.page_titles.messages".tr(),
    "main_layout.page_titles.profile".tr(),
  ];

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index, {
    bool hasUnread = false,
  }) {
    Widget iconWidget = Icon(
      icon,
      size: 28,
      color: _currentIndex == index
          ? ThemeManager.primaryYellow
          : ThemeManager.primaryBlue,
    );

    if (hasUnread) {
      iconWidget = Badge(
        backgroundColor: Colors.redAccent,
        smallSize: 10,
        offset: const Offset(2, -2),
        child: iconWidget,
      );
    }
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,

          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: _currentIndex == index
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: _currentIndex == index
                      ? ThemeManager.primaryYellow
                      : ThemeManager.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        titleSpacing: 20,
        backgroundColor: ThemeManager.primaryBlue,

        title: _currentIndex == 0
            ? Row(
                children: [
                  Image.asset("assets/images/logo.png", height: 50),
                  const Expanded(
                    child: Text(
                      "JUST LOST & FOUND",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Text(
                pageTitles[_currentIndex],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
              color: Colors.white,
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
                        "main_layout.filter.all".tr(),
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
                        "main_layout.filter.lost".tr(),
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
                        "main_layout.filter.found".tr(),
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

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomAppBar(
          elevation: 25,
          shadowColor: Colors.black,
          surfaceTintColor: Colors.white,
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          child: SizedBox(
            height: 70,
            child: Row(
              children: [
                Expanded(
                  child: _buildNavItem(
                    Icons.home,
                    "main_layout.nav.home".tr(),
                    0,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    Icons.manage_search_outlined,
                    "main_layout.nav.explore".tr(),
                    1,
                  ),
                ),
                const SizedBox(width: 60),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chat_rooms')
                        .where(
                          'users',
                          arrayContains: FirebaseAuth.instance.currentUser?.uid,
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      bool hasUnread = false;

                      if (snapshot.hasData) {
                        final currentUserId =
                            FirebaseAuth.instance.currentUser?.uid;
                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          if (data['isRead'] == false &&
                              data['lastMessageSenderId'] != currentUserId) {
                            hasUnread = true;
                            break;
                          }
                        }
                      }

                      return _buildNavItem(
                        Icons.chat,
                        "main_layout.nav.messages".tr(),
                        2,
                        hasUnread: hasUnread,
                      );
                    },
                  ),
                ),

                Expanded(
                  child: _buildNavItem(
                    Icons.person,
                    "main_layout.nav.profile".tr(),
                    3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
