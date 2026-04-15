import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_lost_and_found/screens/SignIn_screen.dart';
import 'package:just_lost_and_found/screens/bottom_navigation_screens/my_posts_screen.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshUser();
  }

  Future<void> _refreshUser() async {
    await user?.reload();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final blueHeaderHight = 120.0;
    final avatarRadius = 60.0;
    final String userName = user?.displayName ?? "Student Name";
    final String userEmail = user?.email ?? "email@just.edu.jo";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: blueHeaderHight,
            width: double.infinity,
            color: ThemeManager.primaryBlue,
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ThemeManager.primaryYellow,
                          width: 8,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 85.0,
                        backgroundColor: Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          size: avatarRadius,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: ThemeManager.primaryYellow,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: ThemeManager.primaryBlue,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Text(
                  userName,
                  style: const TextStyle(
                    color: ThemeManager.primaryBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userEmail,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(left: 30.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "My Posts",
                      style: TextStyle(
                        color: ThemeManager.primaryBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "View All",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      leading: Icon(Icons.post_add, color: Colors.black),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: ThemeManager.primaryYellow,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyPostsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.only(left: 30.0),
                  child: Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Text(
                      "Settings",
                      style: TextStyle(
                        color: ThemeManager.primaryBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            "Language",
                            style: TextStyle(color: Colors.black),
                          ),
                          leading: Icon(Icons.language, color: Colors.black),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: ThemeManager.primaryYellow,
                          ),
                          onTap: () {},
                        ),
                        Divider(
                          height: 0,
                          indent: 0.0,
                          endIndent: 20.0,
                          thickness: 0.5,
                        ),
                        ListTile(
                          title: Text("Light Mode"),
                          leading: Icon(
                            Icons.wb_sunny_outlined,
                            color: ThemeManager.primaryYellow,
                          ),
                          trailing: Switch(
                            value: true,
                            activeColor: ThemeManager.primaryYellow,
                            onChanged: (val) {},
                          ),
                        ),
                        const Divider(
                          height: 0,
                          indent: 0.0,
                          endIndent: 20.0,
                          thickness: 0.5,
                        ),
                        ListTile(
                          title: Text("Log Out"),
                          leading: Icon(Icons.logout, color: Colors.red),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: ThemeManager.primaryYellow,
                          ),
                          onTap: () async {
                            try{  
                            await FirebaseAuth.instance.signOut();
                            if (!mounted)return ;
                            // Navigator.of(context,rootNavigator: true).pushAndRemoveUntil(
                            //   MaterialPageRoute(builder: (context)=>const SigninScreen()),
                            //   (route)=>false);
                            // Navigator.pushAndRemoveUntil(context, 
                            // MaterialPageRoute(builder: (context)=>const SigninScreen()),
                            //  (Route)=>false);
                            Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SigninScreen()),
  );
                
                          }catch(e){
                            print("Log Out Error:$e");
                          }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
}
