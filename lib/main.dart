import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:productivity_monster/UI/task_app_scrap/theme.dart';
import 'package:productivity_monster/db/db_helper.dart';
import 'package:productivity_monster/provider/chat_provider.dart';
import 'package:productivity_monster/provider/google_sign_in.dart';
import 'package:productivity_monster/provider/home_provider.dart';
import 'package:productivity_monster/provider/setting_provider.dart';
import 'package:productivity_monster/services/theme_services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'UI/home_page.dart';
import 'auth/auth_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:productivity_monster/allConstants/app_constants.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await GetStorage.init();
  await DBHelper.initDB();
  FlutterNativeSplash.remove();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  MyApp({Key? key, required this.prefs}) : super(key: key);

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<GoogleSignInProvider>(
              create: (_) => GoogleSignInProvider(
                  firebaseAuth: FirebaseAuth.instance,
                  firebaseFirestore: this.firebaseFirestore,
                  prefs: this.prefs,
                  googleSignIn: GoogleSignIn())
          ),
          Provider<SettingProvider>(
            create: (_) => SettingProvider(
                prefs: this.prefs,
                firebaseFirestore: this.firebaseFirestore,
                firebaseStorage: this.firebaseStorage
            ),
          ),
          Provider<ChatHomeProvider>(
              create: (_) => ChatHomeProvider(firebaseFirestore: this.firebaseFirestore)
          ),
          Provider<ChatProvider>(
              create: (_) => ChatProvider(
                  prefs: this.prefs,
                  firebaseFirestore: this.firebaseFirestore,
                  firebaseStorage: this.firebaseStorage)
          )
        ],
        child: (
            GetMaterialApp(
            navigatorKey: navigatorKey,
            title: AppConstants.appTitle,
            debugShowCheckedModeBanner: false,
            theme: Themes.light,
            darkTheme: Themes.dark,
            builder: EasyLoading.init(),
            themeMode: ThemeService().theme,
            home: const MainPage())),
      );
}


class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _errorPage();
            } else if (snapshot.hasData) {
              return const HomePage();
            } else {
              return const AuthPage();
            }
          }));

  _errorPage() {
    return Center(
      child: Container(
        height: 400,
        width: 300,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Get.isDarkMode ? Colors.white : Colors.grey[400]),
        child: Center(
          child: Text(
            "SOMETHING WENT WRONG",
            style: TextStyle(
                color: Get.isDarkMode ? Colors.black : Colors.white,
                fontSize: 30),
          ),
        ),
      ),
    );
  }
}
