import 'package:flutter/material.dart';
import 'package:stattrack/components/custom_app_bar.dart';
import 'package:stattrack/components/buttons/main_button.dart';
import 'package:stattrack/services/auth.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key, required this.auth}) : super(key: key);

  final AuthBase auth;

  void _signOut(BuildContext context) async {
    await auth.signOut();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        headerTitle: "Settings",
      ),
      body: Padding(
        padding: const EdgeInsets.all(31.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // TODO: Add more settings options here
            MainButton(
              callback: () => _signOut(context),
              label: "Log out",
            ),
          ],
        ),
      ),
    );
  }
}
