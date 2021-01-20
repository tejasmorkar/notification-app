import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:notification/configuration/local.dart';
import 'package:notification/database/circular.dart';
import 'package:notification/pages/home.dart';
import 'package:notification/pages/login.dart';
import 'package:notification/pages/otp.dart';
import 'package:notification/pages/profile.dart';
import 'package:notification/pages/splash.dart';
import 'package:notification/providers/user.dart';
import 'package:notification/screens/error_page.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';

import 'providers/user.dart';

var snapshot;
void main() async {
  // Register controllers
  // Example:
  // Get.put(Controller);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final appDir=await path_provider.getApplicationDocumentsDirectory();

  Hive.init(appDir.path);
  Hive.registerAdapter(CircularAdapter());
  await Hive.openBox('myBox');
  FlutterError.onError=FirebaseCrashlytics.instance.recordFlutterError;
  DocumentReference documentReference = FirebaseFirestore.instance.collection('control').doc('maintenance');
  var check=await documentReference.get();
  runZoned(() {
    runApp(App(maintenance: check.data()['maintenance'],));
  }, onError: FirebaseCrashlytics.instance.recordError);
}

// Future<bool> maintenance()async{
// return true;
// }

class App extends StatelessWidget {
  final bool maintenance;

  const App({Key key, this.maintenance}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Color.fromRGBO(240, 240, 240, 1),
      ),
    );

    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: ChangeNotifierProvider(
        create: (_) => UserProvider(),
        child: GetMaterialApp(
          title: LocalConfiguration.name,
          debugShowCheckedModeBanner: false,
          // Theme
          theme: ThemeData(
            fontFamily: 'Poppins',
            primarySwatch: Colors.indigo,
            primaryColor: Colors.white,
            accentColor: Colors.indigo,
            cursorColor: LocalConfiguration.dark,
            textSelectionHandleColor: LocalConfiguration.dark,
            textSelectionColor: LocalConfiguration.dark.withOpacity(24 / 100),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            scaffoldBackgroundColor: Colors.white,
          ),
          home: maintenance?ErrorScreen():StreamBuilder(
            // ignore: deprecated_member_use
            stream: FirebaseAuth.instance.onAuthStateChanged,
            builder: (ctx, userSnapshot) {
              if (userSnapshot.hasData) {
                snapshot = userSnapshot.data.phoneNumber;
                return HomePage();
              } else
                return LoginPage();
            },
          ),
          getPages: [
            // Register routes
            // Example
            // GetPage(name: '/', page: () => Widget()),
            GetPage(name: '/', page: () => SplashPage()),
            GetPage(
                name: '/login',
                page: () => LoginPage(),
                transition: Transition.fadeIn),
            GetPage(name: '/otp', page: () => OtpPage()),
            GetPage(name: '/profile', page: () => ProfilePage()),
            GetPage(name: '/homePage', page: () => HomePage()),
          ],
        ),
      ),
    );
  }
}
