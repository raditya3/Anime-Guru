import 'package:anime_discovery/Pages/settings_page.dart';
import 'package:anime_discovery/Providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrawerLayout extends StatelessWidget {
  const DrawerLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(

      child: ListView(
        children: [
          DrawerHeader(decoration: const BoxDecoration(
            color: Colors.blue,
          ),
            child: Text(
              Provider.of<UserProvider>(context).user?.name ?? 'Unknown',
              style: Theme.of(context).textTheme.titleLarge,
            ),),
          ListTile(
            leading:  Icon(Icons.settings, color: Theme.of(context).colorScheme.secondary,),
            title:  Text('Settings', style: Theme.of(context).textTheme.headlineLarge,),
            onTap: () {
              Navigator.pushNamed(
                context,
                SettingsPage.routeName,
              );
            },
          ),
        ],
      ),
    );
  }
}
