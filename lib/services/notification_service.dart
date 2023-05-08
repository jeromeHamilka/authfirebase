import 'package:firebase_messaging/firebase_messaging.dart';
class NotificationService {

  static void initialize() {
    // for ios and web
    //FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen((event) {
      print('A new onMessage event was published!');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });
  }


  static Future<String?> getToken() async {
    return FirebaseMessaging.instance.getToken(vapidKey: "BF27ifrovWvvxFY1f_uGJe1_8UFkEev0t7wDF2_7usOCOJDi2wDNyBLxqckXvM7w2-ltSy6hS1pSEVSuagbpf00");
  }

}