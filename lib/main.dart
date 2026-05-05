import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await GetStorage.init();
  var initialRoute = await Routes.initialRoute;
  runApp(Main(initialRoute));
}

class Main extends StatelessWidget {
  final String initialRoute;
  const Main(this.initialRoute, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // translations: Locales(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      getPages: Nav.routes,
    );
  }
}
