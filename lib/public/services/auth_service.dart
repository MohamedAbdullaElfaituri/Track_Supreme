import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_profile.dart';

/// Kimlik doğrulama işlemlerini yöneten servis sınıfı
class AuthService {
  // Platform kontrolüyle FirebaseAuth örneği
  final FirebaseAuth? _auth = (kIsWeb || Platform.isAndroid || Platform.isIOS)
      ? FirebaseAuth.instance
      : null;

  // GitHub OAuth bilgileri
  final String _githubClientId = 'Ov23liJAcjoZBfMiXJn4';
  final String _githubClientSecret = 'c7f6fa9cc0483ce82a8240dd6f2e8bba72299ae1';
  final String _githubRedirectUrl = 'https://your-app.firebaseapp.com/__/auth/handler';

  /// UniLinks başlatma (sadece mobil/web)
  void initUniLinks() {
    if (!(kIsWeb || Platform.isAndroid || Platform.isIOS)) {
      debugPrint('UniLinks desteklenmiyor bu platformda.');
      return;
    }
    uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.queryParameters['code'] != null) {
        _handleGitHubCallback(uri.queryParameters['code']!);
      }
    });
  }

  /// GitHub callback işleme
  Future<void> _handleGitHubCallback(String code) async {
    final token = await exchangeGitHubCodeForToken(code);
    if (token != null) {
      await signInWithGitHubToken(token);
    }
  }

  /// Email/Şifre ile giriş
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    _checkAuthAvailability();
    try {
      final userCredential = await _auth!.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(e.message ?? 'Giriş başarısız');
    }
  }

  /// Email/Şifre ile kayıt
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    _checkAuthAvailability();
    try {
      final userCredential = await _auth!.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(e.message ?? 'Kayıt başarısız');
    }
  }

  /// Google ile giriş
  Future<User?> signInWithGoogle() async {
    _checkAuthAvailability();
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth!.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      throw AuthServiceException('Google ile giriş başarısız: $e');
    }
  }
  /// GitHub OAuth başlatma
  Future<void> startGitHubSignIn() async {
    final encodedRedirectUri = Uri.encodeComponent(_githubRedirectUrl);
    final authUrl = Uri.parse(
      'https://github.com/login/oauth/authorize'
          '?client_id=$_githubClientId'
          '&redirect_uri=$encodedRedirectUri'
          '&scope=user:email',
    );

    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);
    } else {
      throw AuthServiceException('GitHub giriş sayfası açılamadı');
    }
  }

  /// GitHub kodu -> Token dönüşümü
  Future<String?> exchangeGitHubCodeForToken(String code) async {
    try {
      final response = await http.post(
        Uri.parse('https://github.com/login/oauth/access_token'),
        headers: {'Accept': 'application/json'},
        body: {
          'client_id': _githubClientId,
          'client_secret': _githubClientSecret,
          'code': code,
          'redirect_uri': _githubRedirectUrl,
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['access_token'];
      } else {
        debugPrint('GitHub token alma başarısız, status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Token dönüşüm hatası: $e');
      return null;
    }
  }

  /// GitHub token ile Firebase giriş
  Future<User?> signInWithGitHubToken(String token) async {
    _checkAuthAvailability(); // Auth servisinin hazır olduğundan emin ol
    try {
      final credential = GithubAuthProvider.credential(token);
      final userCredential = await _auth!.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      throw AuthServiceException('GitHub ile giriş başarısız: ${e.toString()}');
    }
  }


  /// Platform kontrolü
  void _checkAuthAvailability() {
    if (_auth == null) {
      throw AuthServiceException('Bu platformda kimlik doğrulama desteklenmiyor');
    }
  }

  // Mevcut kullanıcı
  User? get currentUser => _auth?.currentUser;

  // Kullanıcı ID'si
  String? get currentUID => _auth?.currentUser?.uid;

  /// Çıkış yap
  Future<void> signOut() async {
    if (_auth != null) {
      await _auth!.signOut();
      await GoogleSignIn().signOut();
    }
  }
}

/// Özel auth istisna sınıfı
class AuthServiceException implements Exception {
  final String message;
  AuthServiceException(this.message);

  @override
  String toString() => 'AuthServiceException: $message';
}

/// Uygulama kullanıcı modeli
class AppUser {
  final String uid;
  final UserProfile userProfile;

  AppUser({required this.uid, required this.userProfile});
}