import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../drawer/custom_app_bar.dart';
import '../services/auth_service.dart';
import 'Home_Page.dart';

// Kullanıcı giriş işlemlerini yöneten ekran widget'ı
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form ve kimlik doğrulama için gerekli controller'lar
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // UI durumları
  bool _obscurePassword = true; // Şifrenin gizli/görünür durumu
  bool _isLoading = false; // Yükleme durumu
  late Future<String> _logoUrlFuture; // Logo URL'si için future

  @override
  void initState() {
    super.initState();
    _logoUrlFuture = _fetchLogoUrl(); // Uygulama başladığında logo URL'sini getir
  }

  @override
  void dispose() {
    // Controller'ları temizle
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Uzak sunucudan logo URL'sini getiren metod
  Future<String> _fetchLogoUrl() async {
    try {
      final response = await http.get(Uri.parse(
          'https://raw.githubusercontent.com/MohamedAbdullaElfaituri/midterm-logo/main/logo.json'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['logoUrl'] as String;
      }
      throw Exception('Failed to load logo');
    } catch (e) {
      debugPrint('Logo fetch error: $e');
      rethrow;
    }
  }

  // Email/şifre ile giriş işlemini yöneten metod
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return; // Form geçerli değilse çık

    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (user != null) {
        _navigateToHome(user.uid); // Başarılı girişte ana sayfaya yönlendir
      } else {
        _showErrorSnackbar('Login failed. Please check your credentials.');
      }
    } on AuthServiceException catch (e) {
      _showErrorSnackbar(e.message);
    } catch (e) {
      _showErrorSnackbar('An unexpected error occurred');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Google ile giriş işlemi
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _navigateToHome(user.uid);
      } else {
        _showErrorSnackbar('Google login failed.');
      }
    } on AuthServiceException catch (e) {
      _showErrorSnackbar(e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // GitHub ile giriş işlemi
  Future<void> _handleGitHubLogin() async {
    setState(() => _isLoading = true);
    try {
      await _authService.startGitHubSignIn();
    } catch (e) {
      _showErrorSnackbar('Failed to initiate GitHub login');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Ana sayfaya yönlendirme
  void _navigateToHome(String uid) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(uid: uid)),
    );
  }

  // Hata mesajını snackbar ile gösterme
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: 'Log In'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo alanı (future builder ile)
                      FutureBuilder<String>(
                        future: _logoUrlFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Icon(Icons.error, size: 64, color: theme.colorScheme.error);
                          }
                          return Image.network(
                            snapshot.data!,
                            height: 80,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 64),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Email giriş alanı
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                        value?.contains('@') ?? false ? null : 'Enter valid email',
                      ),
                      const SizedBox(height: 16),
                      // Şifre giriş alanı
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) =>
                        (value?.length ?? 0) >= 6 ? null : 'Minimum 6 characters',
                      ),
                      const SizedBox(height: 24),
                      _buildLoginButton(), // Giriş butonu
                      const SizedBox(height: 24),
                      _buildSocialLoginButtons(), // Sosyal giriş butonları
                      const SizedBox(height: 16),
                      _buildSignupRedirect(), // Kayıt sayfasına yönlendirme
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Giriş butonu widget'ı
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('LOG IN', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  // Sosyal giriş butonları widget'ı (Google ve GitHub)
  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Image.asset('assets/images/google.png', height: 24),
            label: const Text('Continue with Google'),
            onPressed: _isLoading ? null : _handleGoogleLogin,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.code),
            label: const Text('Continue with GitHub'),
            onPressed: _isLoading ? null : _handleGitHubLogin,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  // Kayıt sayfasına yönlendirme widget'ı
  Widget _buildSignupRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Don\'t have an account?'),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
          child: const Text('Sign Up'),
        ),
      ],
    );
  }
}
