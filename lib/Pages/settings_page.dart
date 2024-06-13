import 'package:anime_discovery/Services/auth_service.dart';
import 'package:flutter/material.dart';

import '../Components/custom_button.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  static const routeName = "/settings";
  final AuthService authService = AuthService.getAuthService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(iconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.secondary,)
      ),

      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: ListView(
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 100),
              child: CustomButton(
                onTap: authService.logout,
                text: "Logout",
              ),
            )
          ],
        ),
      ),
    );
  }
}
