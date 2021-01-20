import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:notification/controllers/index.dart';
import 'package:notification/pages/profile.dart';
import 'package:notification/providers/user.dart';
import 'package:notification/screens/aboutUs.dart';
import 'package:notification/screens/bookmark.dart';
import 'package:notification/screens/channels.dart';
import 'package:notification/screens/home.dart';
import 'package:notification/screens/channels.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  // final userSnapshot;
  HomePage();
  final List<Widget> _screens = [
    HomeScreen(),
    ChannelsScreen(),
    ProfilePage(),
    BookMarkScreen(),
    AboutUsScreen(),
  ];

  final fcm=FirebaseMessaging();
  Map user={};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetX<IndexState>(
        init: IndexState(),
        builder: (indexController) => Scaffold(
          appBar: _buildAppbar(context),
          body: _buildBody(context, indexController),
          bottomNavigationBar: _buildBottomNavBar(context, indexController),
        ),
      ),
    );
  }

  Widget _buildAppbar(BuildContext context) {
    if(user["uid"]==null || user["uid"]==''){
      Future.delayed(const Duration(milliseconds: 100),(){
        final _userProvider = Provider.of<UserProvider>(context, listen: false);
        var box=Hive.box('myBox');
        var userData=box.get('userData');
        _userProvider.setUser(userData);
        user=_userProvider.user;
        fcm.configure(
          onLaunch: (Map<String,dynamic> message) async {
            print("onLaunch: $message");
          },
          onResume: (Map<String,dynamic> message) async {
            print("onResume: $message");
          },
          onMessage: (Map<String,dynamic> message) async {
            print("onMessage: $message");
          },
        );
        _userProvider.user["subscriptions"].forEach((element){
          fcm.subscribeToTopic(element.replaceAll(" ","_"));
        });
      });
    }
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 4,
      title: Text(
        "Notifier",
        textAlign: TextAlign.center,
        style: GoogleFonts.ubuntu(
            textStyle: TextStyle(
                color: Colors.black.withOpacity(0.88),
                fontSize: 18,
                fontWeight: FontWeight.w500)),
      ),
      actions: [
        IconButton(
            icon: Icon(
              Icons.exit_to_app,
              size: 22,
              color: Colors.black.withOpacity(0.75),
            ),
            onPressed: () async {
              FirebaseAuth auth = FirebaseAuth.instance;
              await auth.signOut();
              Get.offAndToNamed('/login');
            })
      ],
    );
  }

  Widget _buildBody(BuildContext context, dynamic indexState) {
    //final IndexState indexState = Get.put(IndexState());
    return _screens[indexState.indexCounter.value];
  }

  Widget _buildBottomNavBar(context, dynamic indexState) {
    int _currentindex = indexState.indexCounter.toInt();
    return BottomNavigationBar(
      // backgroundColor: Color.fromRGBO(240, 240, 240, 1),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: Colors.black.withOpacity(0.75),
      selectedItemColor: Colors.indigo[800],
      currentIndex: _currentindex,
      onTap: (value) {
        indexState.changeIndex(value);
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            size: 27,
          ),
          title: Text(
            "Home",
            style: TextStyle(color: Colors.black, fontSize: 11),
          ),
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.view_headline, size: 27),
            title: Text(
              "Channels",
              style: TextStyle(color: Colors.black, fontSize: 11),
            )),
        BottomNavigationBarItem(
          icon: Container(
            height: 27,
            width: 27,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: AssetImage('assets/avatars/avatar.jpg')),
              border: Border.all(
                width: 0.5,
                color: Colors.black.withOpacity(0.75),
              ),
            ),
          ),
          title: Text(
            "Profile",
            style: TextStyle(color: Colors.black, fontSize: 11),
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark, size: 27),
          title: Text(
            'BookMark',
            style: TextStyle(color: Colors.black, fontSize: 11),
          ),
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.info, size: 27),
            title: Text(
              'About',
              style: TextStyle(color: Colors.black, fontSize: 11),
            )),
      ],
    );
  }
}
