import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:together_version_2/pages/auth_pages/login_page.dart';
import 'package:together_version_2/pages/bottom_nav_bar.dart';

class Authenticate extends StatelessWidget {
  const Authenticate({super.key});

  @override
  Widget build(BuildContext context) {
    final fireAuth = FirebaseAuth.instance;
    return fireAuth.currentUser != null
        ? const BottomNavBar()
        : const LogInPage();
  }
}
