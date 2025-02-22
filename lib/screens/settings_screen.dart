import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: const Color(0xFF55883B),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("Enable Notifications"),
            subtitle: const Text("Receive important updates and alerts"),
            value: notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                notificationsEnabled = value;
              });
              _updateSetting('notificationsEnabled', value);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text("Privacy Policy"),
            leading: const Icon(Icons.privacy_tip, color: Colors.blue),
            onTap: () {
              Navigator.pushNamed(context, '/privacy_policy');
            },
          ),
          ListTile(
            title: const Text("Terms & Conditions"),
            leading: const Icon(Icons.article, color: Colors.orange),
            onTap: () {
              Navigator.pushNamed(context, '/terms_conditions');
            },
          ),
          ListTile(
            title: const Text("About Us"),
            leading: const Icon(Icons.info, color: Colors.green),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
        ],
      ),
    );
  }
}
