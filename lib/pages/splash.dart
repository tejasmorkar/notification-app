import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashPage extends StatelessWidget {

  final bool hasData ;

  SplashPage({this.hasData});

  void postFrameCallback(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mounted hook
    WidgetsBinding.instance
        .addPostFrameCallback((_) => postFrameCallback(context));

    return Scaffold(
      backgroundColor: Colors.indigo,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              width: double.infinity,
            ),

            Text(
              'Notifier',
              style: GoogleFonts.ubuntu(
                color: Colors.white,
                fontSize: 38,
              ),
            ),

            SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              width: double.infinity,
            ),

            // Progress
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 120.0,
                child: LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
