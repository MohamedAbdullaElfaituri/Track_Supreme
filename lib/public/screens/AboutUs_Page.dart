import 'package:flutter/material.dart';
import '../drawer/Drawer_Widget.dart';
import '../drawer/custom_app_bar.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  // Renk sabitleri
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color whiteColor = Colors.white;
  static const Color cardBlue = Color(0xFFE3F2FD);
  static const Color textBlue = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: CustomAppBar(
        title: 'About Us',
        showMenuButton: true,
      ),
      drawer: const DrawerWidget(uid: 'uid'), // UID sabit olarak geçildi
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroCard(),
            const SizedBox(height: 30),
            _buildSectionTitle('Why Choose Track Supreme?'),
            const SizedBox(height: 16),
            _buildFeatureList(),
            const SizedBox(height: 30),
            _buildSectionTitle('Data Security & Privacy'),
            const SizedBox(height: 16),
            _buildSecurityCard(),
          ],
        ),
      ),
    );
  }

  // Tanıtım kartı widget'ı
  Widget _buildIntroCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: cardBlue,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.track_changes, size: 80, color: primaryBlue),
            const SizedBox(height: 16),
            Text(
              'Track Supreme',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Track Supreme is a modern and user-friendly app that simplifies customer tracking. '
                  'It helps businesses securely store and manage customer information with an intuitive interface. '
                  'Designed with comprehensive features and strong security measures, it\'s an indispensable tool '
                  'for successful business management.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey.shade900,
                height: 1.4,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  // Özellik listesi widget'ı
  Widget _buildFeatureList() {
    return Column(
      children: [
        _buildFeature("User-friendly interface"),
        _buildFeature("Fast customer management"),
        _buildFeature("Modern design"),
        _buildFeature("Advanced security"),
        _buildFeature("Real-time updates"),
      ],
    );
  }

  // Güvenlik kartı widget'ı
  Widget _buildSecurityCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: cardBlue,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'We use industry-standard encryption to protect your data. '
              'All information is securely stored and only accessible to authorized users.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.blueGrey.shade900,
            height: 1.4,
          ),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }

  // Bölüm başlığı widget'ı
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryBlue,
      ),
    );
  }

  // Özellik satırı widget'ı
  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: primaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}