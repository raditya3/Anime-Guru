import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:anime_discovery/Exceptions/authorization_exception.dart';
import 'package:anime_discovery/Exceptions/invalid_token_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../Pages/login_or_home.dart';

class AuthService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final _storage = const FlutterSecureStorage();
  final String _clientId = dotenv.env["ClientId"] ?? '';
  final String _clientSecret = dotenv.env["ClientSecret"] ?? '';
  final String _scheme = kIsWeb ? 'http' : 'com.raditya3.animediscovery';
  final String _domain = kIsWeb ? 'localhost:8089/auth.html' : 'callback';
  late final String _redirectUri = '$_scheme://$_domain';
  late final WebViewWidget _webViewWidget = WebViewWidget(controller: _webViewController, );
  late Completer<void> _webViewAuthCompleted;
  late String _redirectedUri;

  late final WebViewController _webViewController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setUserAgent("random")
    ..setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onHttpError: (HttpResponseError error) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.contains(_redirectUri)) {
            _handleAuthRedirect(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );

  void _handleAuthRedirect(String url) {
    _redirectedUri = url;
    _webViewAuthCompleted.complete();
  }

  WebViewWidget getWebViewWidget(){
    return _webViewWidget;
  }

  AuthService._();

  static final AuthService _authService = AuthService._();

  static AuthService getAuthService() {
    return _authService;
  }

  String _generateRandomString(int length) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  Future<void> fetchAndStoreOauth2Token() async {
    _webViewAuthCompleted = Completer<void>();
    final String codeVerifier = _generateRandomString(64);
    final String codeChallenge = codeVerifier;
    final String oauthState = _generateRandomString(64);
    final Uri authorizeUri =
        Uri.https('myanimelist.net', '/v1/oauth2/authorize', {
      'response_type': 'code',
      'client_id': _clientId,
      'state': oauthState,
      'code_challenge': codeChallenge,
      'redirect_uri': _redirectUri,
    });

    try {
      _webViewController.loadRequest(authorizeUri);
      await _webViewAuthCompleted.future;

      final Uri resultUri = Uri.parse(_redirectedUri);
      final String? code = resultUri.queryParameters['code'];
      final String? state = resultUri.queryParameters['state'];
      if (code == null || state == null || state != oauthState) {
        throw AuthorizationException(cause: "request_canceled");
      }
      return _exchangeCodeForToken(code, codeVerifier);
    } catch (e) {
      FlutterError.reportError(FlutterErrorDetails(exception: e));
      throw AuthorizationException(cause: "request_canceled");
    }
  }

  Future<void> _exchangeCodeForToken(String code, String codeVerifier) async {
    final response = await http.post(
      Uri.parse('https://myanimelist.net/v1/oauth2/token'),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        'grant_type': 'authorization_code',
        'client_id': _clientId,
        'code': code,
        "client_secret": _clientSecret,
        'code_verifier': codeVerifier,
        'redirect_uri': _redirectUri,
      },
    );

    if (response.statusCode == 200) {
      return _saveTokensFromResponse(response);
    } else {
      throw AuthorizationException(cause: "no_access_token");
    }
  }

  Future<String> getAuthToken() async {
    String? authToken = await _storage.read(key: "authToken");
    if (authToken == null) {
      throw AuthorizationException(cause: "no_auth_token");
    }
    return authToken;
  }

  Future<void> refreshToken() async {
    String? refreshToken = await _storage.read(key: "refreshToken");
    if (refreshToken == null) {
      throw InvalidTokenException();
    }
    Uri refreshTokenUri = Uri.https("myanimelist.net", "/v1/oauth2/token", {
      "grant_type": "refresh_token",
      "refresh_token": refreshToken,
    });

    var response = await http.post(refreshTokenUri,
        headers: {"Content-Type": "application/x-www-form-urlencoded"});

    if (response.statusCode == 200) {
      return _saveTokensFromResponse(response);
    } else {
      throw AuthorizationException(cause: "invalid_refresh_token");
    }
  }

  Future<void> _saveTokensFromResponse(http.Response response) async {
    var decodedBody = jsonDecode(response.body);
    var accessToken = decodedBody["access_token"];
    var refreshToken = decodedBody["refresh_token"];
    await _storage.write(key: "authToken", value: accessToken);
    await _storage.write(key: "refreshToken", value: refreshToken);
  }

  Future<void> _removeAuthToken() {
    return _storage.delete(key: "authToken");
  }

  Future<void> logout() async {
    await _removeAuthToken();
    navigatorKey.currentState?.pushNamedAndRemoveUntil(LoginOrHome.routeName,  (Route<dynamic> route) => false);
  }

  Future<bool> isTokenValid() async {
    String accessToken;
    try {
      accessToken = await getAuthToken();
    } catch (e) {
      return false;
    }
    final response = await http.head(
      Uri.parse('https://api.myanimelist.net/v2/users/@me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
