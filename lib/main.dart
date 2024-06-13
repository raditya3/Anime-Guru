import 'dart:async';

import 'package:anime_discovery/Exceptions/authorization_exception.dart';
import 'package:anime_discovery/Pages/Anime_details_page/anime_details_page.dart';
import 'package:anime_discovery/Pages/search_page.dart';
import 'package:anime_discovery/Pages/settings_page.dart';
import 'package:anime_discovery/Providers/theme_provider.dart';
import 'package:anime_discovery/Services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Pages/login_or_home.dart';
import 'Providers/user_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    await dotenv.load(fileName: ".env");
    runApp(const MainApp());
  }, (error, stackTrace) {
    AuthService authService = AuthService.getAuthService();

    if (error is AuthorizationException) {
      authService.logout();
    } else {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    }
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ThemeProvider()),
        ChangeNotifierProvider.value(value: UserProvider())
      ],
      builder: (context, child) {
        return MaterialApp(
            navigatorKey: AuthService.navigatorKey,
            debugShowCheckedModeBanner: false,
            onGenerateRoute: (settings) {
              if (settings.name == AnimeDetailsPage.routeName) {
                final int id =
                    (settings.arguments as Map<String, int>)["id"] as int;
                return MaterialPageRoute(
                  builder: (context) {
                    return AnimeDetailsPage(id: id);
                  },
                );
              } else if (settings.name == LoginOrHome.routeName) {
                return MaterialPageRoute(
                  builder: (context) {
                    return const LoginOrHome();
                  },
                );
              } else if (settings.name == SettingsPage.routeName) {
                return MaterialPageRoute(
                  builder: (context) {
                    return SettingsPage();
                  },
                );
              } else if (settings.name == SearchPage.routeName) {
                return MaterialPageRoute(
                  builder: (context) {
                    return const SearchPage();
                  },
                );
              }
              return null;
            },
            home: const LoginOrHome(),
            theme: Provider.of<ThemeProvider>(context).themeData);
      },
    );
  }
}
