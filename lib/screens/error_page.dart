import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 11, vertical: 100),
        color: Colors.white,
        child: Column(
          children: [
            Image.asset(
              'assets/images/img3.png',
            ),
            _buildMessage(context)
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      width: double.infinity,
      child: Center(
        child: Text(
          "App is currently under maintenance",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}