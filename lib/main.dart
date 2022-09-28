import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/screens/root.dart';
import 'package:permission_handler/permission_handler.dart';
import 'constants/global_state.dart';
import 'firebase_options.dart';
import 'utils/nav_router.dart' as router;
import 'package:provider/provider.dart';

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

class HFApp extends StatelessWidget {
  const HFApp({Key? key}) : super(key: key);

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
        home: const RootPage(),
        theme: ThemeData(
          scaffoldBackgroundColor: HFColors().backgroundColor(),
          inputDecorationTheme: InputDecorationTheme(
            hintStyle: GoogleFonts.getFont(
              'Manrope',
              textStyle:
                  TextStyle(color: HFColors().primaryColor(opacity: 0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 1, color: HFColors().primaryColor()),
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
