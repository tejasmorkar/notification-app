import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:notification/providers/user.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';


class OtpPage extends StatefulWidget {

  final String verid = Get.arguments;

  OtpPage();

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String smsCode;
  bool isLoading = false;
  bool isEnable = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  "OTP",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  "Verification",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 60,
                ),
                PinCodeTextField(
                  textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700
                  ),
                  keyboardType: TextInputType.number,
                  errorTextSpace: 40,
                  length: 6,
                  backgroundColor: Colors.indigo,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  pinTheme: PinTheme(
                    inactiveColor: Colors.white.withOpacity(0.5),
                    activeColor: Colors.white.withOpacity(1),
                    fieldWidth: 35,
                    borderWidth: 1,
                    selectedColor: Colors.white,
                  ),
                  onChanged: (pin) {
                    smsCode = pin;
                    if (pin.length != 6) {
                      setState(() {
                        isEnable = false;
                      });
                    }
                  },
                  onCompleted: (pin){
                    setState(() {
                      isEnable = true;
                    });
                  },
                  appContext: null,
                ),
                InkWell(
                  onTap: () {
                    print("verid ===> ${widget.verid} \npinid ===> $smsCode");
                  },
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Text(
                    "Didn't recieve the OTP? \n Resend OTP?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(
                  height: 265,
                ),
                isLoading
                    ? Container(
                  height: 60,
                  child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.indigo,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
                    : Container()
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: (isEnable && !isLoading)
          ? _buildverifyButton(context)
          : _buildDisabledButton(context),
    );
  }

  Widget _buildverifyButton(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () async {
          print("Verifying OTP !");
          setState(() {
            isLoading = true;
          });

          FirebaseAuth auth = FirebaseAuth.instance;
          AuthCredential _credential = await PhoneAuthProvider.getCredential(verificationId: widget.verid, smsCode: smsCode);
          print("Credential ==> $_credential");
          auth.signInWithCredential(_credential)
              .then((value) {
                onClick(context);
          })
              .catchError((error){print("Error");});

        },
        splashColor: Colors.grey.withOpacity(0.5),
        child: Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12)
          ),
          child: Center(
            child: Text(
              "Verify OTP",
              style: TextStyle(
                color: Colors.indigo,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildDisabledButton(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          "Verify OTP",
          style: TextStyle(
            color: Colors.indigo.withOpacity(0.6),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

}
void onClick(BuildContext context){
  print("Successfully verified");
  final user = FirebaseAuth.instance.currentUser;
  String uid = user.uid;
  DocumentReference documentReference = FirebaseFirestore.instance.collection('users').document(uid);
  documentReference.get()
      .then((snapshot)  {
    if (snapshot.exists) {
      List postList=[];
      var box=Hive.box('myBox');
      print(snapshot.data());
      box.put('userData', snapshot.data());
      box.put('postList', postList);
      Get.offAndToNamed("/homePage");
    } else {
     remove();
    }
  });
}
void remove(){
  FirebaseAuth auth=FirebaseAuth.instance;
  auth.signOut();
  Fluttertoast.showToast(msg: "Your data is not present in database. Please contact DSC PCCOE");
  Get.offAndToNamed("/login");
}