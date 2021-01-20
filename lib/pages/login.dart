import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notification/main.dart';
import 'package:notification/pages/otp.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String phoneNumber, smsSent, verificationId;
  String status = "";

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      print("number is $phoneNumber");
      verifyPhone();
    } else
      print("Invalid");
  }

  Future<void> verifyPhone() async {
    var firebaseAuth = await FirebaseAuth.instance;
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      print("==========> Sent <==========");
      Get.offAndToNamed('/otp', arguments: verificationId);
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verId) {
      this.verificationId = verId;
      print("Time Out!");
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException error) {
      print(error.message);
    };

    final PhoneVerificationCompleted verifiedSuccess = (PhoneAuthCredential auth) async {
      print("Success !");
      print(auth.toString());
      await firebaseAuth.signInWithCredential(auth).then((value) => onClick(context));
      // onClick(auth);
      // await auth.si
    };


    firebaseAuth.verifyPhoneNumber(
      phoneNumber: '+' + phoneNumber,
      timeout: Duration(seconds: 6),
      verificationCompleted: verifiedSuccess,
      verificationFailed: verificationFailed,
      codeSent: smsCodeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.indigo,
      child: Column(
        children: <Widget>[
          _buildHeader(context),
          Form(key: _formKey, child: _buildFooter(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Flexible(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.35),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(.35),
              spreadRadius: 2,
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 2,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Text(
                    "Log In",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 5,
              child: Container(
                height: double.infinity,
                width: double.infinity,
                padding: EdgeInsets.all(11),
                child: Image.asset(
                  'assets/images/login.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                child: null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Flexible(
      flex: 1,
      child: Container(
        padding: EdgeInsets.all(28),
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildNumberInput(context),
            SizedBox(
              height: 30,
            ),
            isLoading
                ? _buildLoadingIndicator(context)
                : _buildSendOtpButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInput(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.9,
      child: TextFormField(
        key: ValueKey('number'),
        onFieldSubmitted: (String pNo) {
          setState(() {
            this.phoneNumber = '+91' + pNo;
            snapshot = this.phoneNumber;
          });
        },
        onChanged: (String pNo) {
          this.phoneNumber = '+91' + pNo;
          snapshot = this.phoneNumber;
        },
        validator: (value) {
          if (value.length != 10 || value.isEmpty) {
            return "Enter a valid phone number !";
          } else {
            return null;
          }
        },
        autofocus: false,
        showCursor: false,
        keyboardType: TextInputType.number,
        keyboardAppearance: Brightness.light,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
            hintText: "Mobile Number",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            errorStyle: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
                letterSpacing: 1),
            border: UnderlineInputBorder(
                borderSide: BorderSide(
              color: Colors.white,
            )),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
              color: Colors.white,
              width: 1.4,
            ))),
      ),
    );
  }

  Widget _buildSendOtpButton(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
          splashColor: Colors.grey.withOpacity(0.5),
          onTap: () {
            print(phoneNumber);
            setState(() {
              isLoading = true;
            });
            _trySubmit();
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(6)),
            width: MediaQuery.of(context).size.width / 1.9,
            height: 45,
            child: Center(
              child: Text(
                'Send OTP',
                style: TextStyle(color: Colors.indigo, fontSize: 15),
              ),
            ),
          )),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 2),
      width: MediaQuery.of(context).size.width / 1.9,
      child: Column(
        children: [
          LinearProgressIndicator(
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(
            height: 18,
          ),
          Text(
            "Sending OTP",
            style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w300),
          )
        ],
      ),
    );
  }
}
