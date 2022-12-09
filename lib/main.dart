import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/screens/notifications.dart';
import 'package:health_factory/screens/root.dart';
import 'package:permission_handler/permission_handler.dart';
import 'constants/global_state.dart';
import 'firebase_options.dart';
import 'utils/nav_router.dart' as router;
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HFGlobalState()),
      ],
      child: const HFApp(),
    ),
  );
}

class HFApp extends StatefulWidget {
  const HFApp({Key? key}) : super(key: key);

  @override
  State<HFApp> createState() => _HFAppState();
}

class _HFAppState extends State<HFApp> {
  checkForPermissions() async {
    var status = await Permission.photos.status;
    if (status.isDenied) {
      Permission.photos.request();
      Permission.notification.request();
    }

    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.notification,
    ].request();
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    var decodedData = jsonDecode(message.data['data']);

    handleNotificationTap(context, decodedData['type'], decodedData['data']);
  }

  @override
  void initState() {
    super.initState();

    setupInteractedMessage();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    checkForPermissions();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: MaterialApp(
        title: 'Coach 4 you',
        onGenerateRoute: router.genRoute,
        navigatorKey: navigatorKey,
        home: const RootPage(),
        theme: ThemeData(
          scaffoldBackgroundColor: HFColors().backgroundColor(),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: HFColors().secondaryLightColor(opacity: 0.5),
            filled: true,
            hintStyle: GoogleFonts.getFont(
              'Manrope',
              textStyle:
                  TextStyle(color: HFColors().primaryColor(opacity: 0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  width: 1, color: HFColors().primaryColor(opacity: 0.2)),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: HFColors().pinkColor()),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: HFColors().pinkColor()),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: HFColors().redColor()),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }
}

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();

//   print("Handling a background message: ${message.messageId}");
// }
