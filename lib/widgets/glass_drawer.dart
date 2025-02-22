import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:blurrycontainer/blurrycontainer.dart';

class GlassDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          SizedBox(height: 40), // ✅ Space for top padding

          // Profile Section with Blurry Effect
          ClipOval(
            child: Image.asset(
              'assets/istockphoto-625389694-612x612.jpg', // ✅ Ensure correct path
              width: 80,
              height: 80,
              fit: BoxFit.fill,
            ),
          ),

          SizedBox(height: 10), // ✅ Balanced spacing

          // Welcome Text
          Text(
            'Welcome, User!',
            style: GoogleFonts.poppins(
              color: Colors.black.withOpacity(0.8), // ✅ Darker text for contrast
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 20), // ✅ Space before menu items

          // Menu Items Wrapped in Blurry Effect
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  text: 'Home',
                  onTap: () => Navigator.pushNamed(context, '/home'),
                ),
                _buildDrawerItem(
                  icon: Icons.notifications,
                  text: 'Notifications',
                  onTap: () => Navigator.pushNamed(context, '/notifications'),
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  text: 'Settings',
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
                Divider(color: Colors.black.withOpacity(0.4), thickness: 1, indent: 50, endIndent: 50),
                _buildDrawerItem(
                  icon: Icons.exit_to_app,
                  text: 'Logout',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 20), // ✅ Space before logo

          // Bottom Logo with Blurry Effect
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Image.asset(
              'assets/4856b83f-2f60-4126-82a8-fd778d09cfc5.jpg', // ✅ Ensure correct path
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // ✅ Proper spacing
      child: ListTile(
        leading: Icon(icon, color: Colors.black.withOpacity(0.8), size: 28), // ✅ Darker icons
        title: Text(
          text,
          style: GoogleFonts.poppins(color: Colors.black.withOpacity(0.8), fontSize: 16), // ✅ Darker text
          textAlign: TextAlign.center,
        ),
        onTap: onTap,
      ),
    );
  }
}
