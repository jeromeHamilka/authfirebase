import 'package:authfirebase/models/user.dart';
import 'package:authfirebase/screens/splashscreen_wapper.dart';
import 'package:authfirebase/services/authentication.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/chat_params.dart';
import 'screens/chat/chat_screen.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// If you're going to use other Firebase services in the background, such as Firestore,
// make sure you call `initializeApp` before using other Firebase services.
// await Firebase.initializeApp();
  print('Background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<AppUser?>.value(
      value: AuthenticationService().user,
      initialData: null,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: (settings) => RouteGenerator.generateRoute(settings),
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      ),
    );
  }
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/' :
        return MaterialPageRoute(builder: (context) => const SplashScreenWrapper());
      case '/chat':
        var arguments = settings.arguments;
        if (arguments != null) {
          return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ChatScreen(chatParams : arguments as ChatParams),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                animation = CurvedAnimation(curve: Curves.ease, parent: animation);
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              }
          );
        } else {
          return pageNotFound();
        }
      default:
        return pageNotFound();
    }
  }

  static MaterialPageRoute pageNotFound() {
    return MaterialPageRoute(
        builder: (context) =>
            Scaffold(
                appBar: AppBar(title: const Text("Error"), centerTitle: true),
                body: const Center(
                  child: Text("Page not found"),
                )
            )
    );
  }
}


