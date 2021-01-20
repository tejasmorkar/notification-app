import 'dart:convert';

import 'package:async/async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:notification/global%20functions/internetConnectivity.dart';
import 'package:notification/models/developer.dart';
import 'package:notification/pages/NoInternet.dart';
import 'package:notification/widgets/channel.dart';


class AboutUsScreen extends StatefulWidget {
  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {

  String uid = '';
  bool internet=false;
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  Map data = {
    "name":"EMPTY"
  };
  List<Widget> dataList=[];
  var list=["abhishekove","ShreyaPillai","Ganesh0403","taha2218"];
  Future<Developer> fetchDeveloper(String string) async {
    final response=await http.get("https://api.github.com/users/$string");
    if(response.statusCode==200){
      return Developer.fromJson(jsonDecode(response.body));
    }
    else{
      Fluttertoast.showToast(msg: "The request limit is crossed.");
      return null;
    }
  }
  developers(){
    dataList.add(Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        child: Image(image: AssetImage('assets/images/DSC_Pimpri_Chinchwad_College_Of_Engineering_Light_Vertical-Logo.png')),
      ),
    ));
    list.forEach((element) {
      fetchDeveloper(element).then((value){
        if(value!=null && mounted){
          setState(() {
            dataList.add(
                ChannelWidget(
                  img: value.avatarUrl.toString(),
                  // uid: "okok",
                  developer: true,
                  name: value.login.toString(),
                  description: value.bio.toString(),
                )
            );
          });
        }
      });
    });
  }

  getUId() async {
    final user = await FirebaseAuth.instance.currentUser;
    uid = user.uid;
    print("UID ==========> "+uid);
  }

  addData() {
    Map<String,dynamic> demodata = {
      "name" : "Added Automatically !",
    };
    DocumentReference collectionReference = FirebaseFirestore.instance.collection('users').document(uid);
    collectionReference.get()
    .then((snapshot) => {
      if (snapshot.exists) {
        print("Exists Already")
      } else {
        collectionReference.set(demodata)
      }
    });

  }

  fetchData() {
    DocumentReference documentReference = FirebaseFirestore.instance.collection('users').document(uid);
    documentReference.snapshots().listen((snapshot) {
      if(mounted){
        setState(() {
          // ignore: deprecated_member_use
          data = snapshot.data();
        });
      }
    });
  }
  @override
  void initState() {
    super.initState();
    if(mounted){
      check().then((value) {
        if (value != null && value) {
          // Internet Present Case
          _memoizer.runOnce(() => developers());
          setState(() {
            internet=true;
          });
        }
        else{
          setState(() {
            internet=false;
          });
        }
        // No-Internet Case
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return internet?Container(
      padding: EdgeInsets.only(top: 10),
      child: SingleChildScrollView(
        child: Column(
          children: dataList,
        ),
      ),
    ):Internet();
  }
}