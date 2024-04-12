import 'package:flutter/material.dart';
import 'package:projectdraft/pages/loginpage.dart';

import 'registerpage.dart';

class LoginOrSign extends StatefulWidget {
  const LoginOrSign({super.key});

  @override
  State<LoginOrSign> createState() => _LoginOrSignState();
}

class _LoginOrSignState extends State<LoginOrSign> {
  bool showLoginPage = true;

  void seepages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: seepages,
      );
    } else {
      return RegisterPage(
        onTap: seepages,
      );
    }
  }
}
