import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../screens/AboutUs_Page.dart';
import '../screens/Contact_Page.dart';
import '../screens/Home_Page.dart';
import '../screens/Login_Page.dart';
import '../screens/Settings_Page.dart';
import '../services/auth_service.dart';

/// DrawerWidget, uygulamanın yan menüsünü (drawer) oluşturur.
/// Kullanıcı UID'si alır ve ilgili sayfalara yönlendirme yapar.
class DrawerWidget extends StatefulWidget {
  final String uid;

  const DrawerWidget({Key? key, required this.uid}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  String? logoUrl;      // Logo URL'si (API'den çekilecek)
  bool isLoading = true; // Yükleniyor durumu
  bool isError = false;  // Hata durumu

  // Drawer'ın genel renk ve stil sabitleri
  static const _drawerBgColor = Colors.white;
  static final _iconColor = Colors.blue.shade700;
  static final _textColor = Colors.blueAccent;

  @override
  void initState() {
    super.initState();
    _fetchLogo(); // Logo verisini API'den yükle
  }

  /// Logo URL'sini JSON'dan çekme işlemi
  Future<void> _fetchLogo() async {
    const url = "https://raw.githubusercontent.com/MohamedAbdullaElfaituri/midterm-logo/refs/heads/main/logo.json";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          logoUrl = data['logoUrl'] as String?;
          isLoading = false;
        });
      } else {
        _setError();
      }
    } catch (_) {
      _setError();
    }
  }

  /// Hata durumunu ayarlama fonksiyonu
  void _setError() => setState(() {
    isLoading = false;
    isError = true;
  });

  /// Tek tip liste elemanı (ListTile) oluşturan fonksiyon
  Widget _buildListTile(String title, Widget page, {IconData? icon}) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: _iconColor) : null,
      title: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: _textColor),
      ),
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _drawerBgColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Logo alanı: Yükleme veya hata durumu varsa ona göre gösterim
          SizedBox(
            height: 280,
            child: Center(child: _buildLogoWidget()),
          ),

          // Menü elemanları
          _buildListTile("Home", HomeScreen(uid: widget.uid), icon: Icons.home),
          _buildListTile("About Us", AboutUsPage(), icon: Icons.info_outline),
          _buildListTile("Contact", ContactPage(), icon: Icons.contact_mail),

          // Araya çizgi (divider) ekleyerek görsel ayrım
          const Divider(color: Colors.blueAccent),

          _buildListTile("Settings", SettingsPage(uid: widget.uid), icon: Icons.settings),

          // Başka bir çizgi ile logout'u ayırıyoruz
          const Divider(color: Colors.blueAccent),

          // Çıkış butonu
          ListTile(
            leading: Icon(Icons.logout, color: _iconColor),
            title: Text(
              'Logout',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: _textColor),
            ),
            onTap: () async {
              await AuthService().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Logo gösterim widget'ı
  /// Yükleniyorsa yükleme göstergesi, hata varsa hata mesajı, değilse resmi göster
  Widget _buildLogoWidget() {
    if (isLoading) {
      return const CircularProgressIndicator(color: Colors.blueAccent);
    }
    if (isError) {
      return const Text(
        "Failed to load logo",
        style: TextStyle(color: Colors.redAccent, fontSize: 16),
      );
    }
    return Image.network(
      logoUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
