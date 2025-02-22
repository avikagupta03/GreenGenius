import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
        centerTitle: true,
        backgroundColor: const Color(0xFF55883B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle("About This Project"),
            _buildSectionText(
              "This project is an initiative to create an interactive and engaging platform for developers and users to collaborate on environmental challenges. "
                  "It provides a seamless way to participate in sustainability-focused activities and track contributions towards a greener future. "
                  "The project integrates Firebase for real-time data handling, user authentication, and interactive challenge participation.",
            ),
            _buildSectionTitle("About the Developer"),
            _buildSectionText(
              "This application was developed by an enthusiastic developer passionate about technology and sustainability. "
                  "With a background in software development and experience in building scalable applications, the goal was to create a meaningful impact through this platform.",
            ),
            _buildSectionTitle("Created for Hackathon"),
            _buildSectionText(
              "This project was created as part of a hackathon event, aiming to showcase innovative solutions to environmental issues. "
                  "It was designed to inspire collaboration, learning, and real-world impact among developers and participants.",
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to create section titles.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87, // Better contrast
        ),
      ),
    );
  }

  /// Helper method to create section text.
  Widget _buildSectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5, // Improves readability
          color: Colors.black54,
        ),
      ),
    );
  }
}
