import 'package:flutter/material.dart';
import '../utils/auth_preferences.dart';
import 'recipe_page.dart';
// import 'help_page.dart';
// import 'about_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _loggedInUsername;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final username = await AuthPreferences.getUsername();
    setState(() {
      _loggedInUsername = username;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _loggedInUsername != null
              ? 'Hai, $_loggedInUsername 👋'
              : 'Selamat Datang',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () async {
            await AuthPreferences.logout();
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temukan resep favoritmu dan mulai memasak!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildMenuButton(
                    context,
                    icon: Icons.restaurant_menu,
                    label: 'Resep',
                    routeName: '/recipes',
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context,
                    icon: Icons.help_outline,
                    label: 'Bantuan',
                    routeName: '/help',
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context,
                    icon: Icons.info_outline,
                    label: 'Tentang Aplikasi',
                    routeName: '/about',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required IconData icon, required String label, required String routeName}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Text(label, style: const TextStyle(fontSize: 18)),
      ),
      onPressed: () => Navigator.pushNamed(context, routeName),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(60),
      ),
    );
  }
}
