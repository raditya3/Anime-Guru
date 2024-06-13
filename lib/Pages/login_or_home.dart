import 'package:anime_discovery/Pages/Home/home_page.dart';
import 'package:anime_discovery/Repositories/Implementations/mal_user_repo.dart';
import 'package:anime_discovery/Repositories/user_repo.dart';
import 'package:anime_discovery/Services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/user_provider.dart';
import 'login_page.dart';

class LoginOrHome extends StatefulWidget {

  static String routeName = "/root";

  const LoginOrHome({super.key});

  @override
  State<LoginOrHome> createState() => _LoginOrHomeState();
}

class _LoginOrHomeState extends State<LoginOrHome> {
  bool _isLoggedIn = false;
  bool _loginProgress = true;
  final AuthService _authService = AuthService.getAuthService();
  final UserRepo _userRepo = MalUserRepo();


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {


      try{
        _authService.isTokenValid().then((isValid) {

          setState(() {
            _loginProgress = false;
            _isLoggedIn = isValid;
          });
          if(isValid){
            _userRepo.getMyUserInfo().then((userEntity) {

              Provider.of<UserProvider>(context, listen: false).setUser(userEntity);
            });}
        });


      } catch (e){
        setState(() {
          _loginProgress = false;
          _isLoggedIn = false;
        });
      }
    });


  }

  @override
  Widget build(BuildContext context) {
    return  (_loginProgress? const Center(child: CircularProgressIndicator(color: Colors.white,),): (_isLoggedIn?const HomePage():LoginPage(onLogin: (){
      setState(() {
        _isLoggedIn = true;
      });
    },)));
  }
}
