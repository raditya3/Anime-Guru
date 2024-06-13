import 'package:anime_discovery/Components/custom_button.dart';
import 'package:anime_discovery/Entities/user_entity.dart';
import 'package:anime_discovery/Exceptions/authorization_exception.dart';
import 'package:anime_discovery/Providers/user_provider.dart';
import 'package:anime_discovery/Repositories/Implementations/mal_user_repo.dart';
import 'package:anime_discovery/Repositories/user_repo.dart';
import 'package:anime_discovery/Services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required void Function() onLogin})
      : _onLogin = onLogin;
  final VoidCallback _onLogin;
  static const String routeName = "/login";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService.getAuthService();
  final UserRepo _userRepo = MalUserRepo();
  bool _isWebViewVisible = false;

  void triggerAuthFlow(BuildContext context) async {
    setState(() {
      _isWebViewVisible = true;
    });
    try {
      await _authService.fetchAndStoreOauth2Token();
      UserEntity userEntity = await _userRepo.getMyUserInfo();
      // ignore: use_build_context_synchronously
      Provider.of<UserProvider>(context, listen: false).setUser(userEntity);
    } on AuthorizationException {
      debugPrint("I am  getting this error somehow");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Something went wrong"),
      ));
    }

    setState(() {
      _isWebViewVisible = false;
    });
    widget._onLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: _isWebViewVisible
          ? _authService.getWebViewWidget()
          : (SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome to",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      "Anime Discovery",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 50),
                    CustomButton(
                        onTap: () {
                          triggerAuthFlow(context);
                        },
                        text: "Sign In")
                  ],
                ),
              ),
            )),
    );
  }
}
