import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:notification/global%20functions/internetConnectivity.dart';
import 'package:notification/pages/NoInternet.dart';
import 'package:notification/pages/channelScreen.dart';
import 'package:notification/widgets/channel.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChannelsScreen extends StatefulWidget {
  @override
  _ChannelsScreenState createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  List<Widget> dataList=[];
  bool internet=false;
  @override
  void initState() {
    super.initState();
    check().then((value) {
      if (value != null && value) {
        // Internet Present Case
        list();
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
  Future<void> list() async {
    CollectionReference reference=Firestore.instance.collection('channels');
    QuerySnapshot querySnapshot=await reference.getDocuments();

    var box=Hive.box('myBox');
    Map val=box.get('userData');
    List sub=val["subscriptions"];
    querySnapshot.documents.forEach((element) {
      if(element['name'].toString().toLowerCase().contains(val['dept'].toString().toLowerCase()) || element['name'].toString().toLowerCase().contains(val['year'].toString().toLowerCase()))setState(() {
        dataList.add(
          GestureDetector(
            onTap: (){
              if(element['mode']==false || sub.contains(element['name']))Navigator.push(context, MaterialPageRoute(builder: (context)=>ChannelScreen(docId: element['name'],channelDescription: element["description"],)));
              else Fluttertoast.showToast(msg: "Access Denied.");
            },
            child: ChannelWidget(
              img: element['img'],
              name: element['name'],
              description: element["description"],
              private: element["mode"],
            ),
          ),
        );
      });
    });
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

class FireStorageService extends ChangeNotifier {
  FireStorageService();
  static Future<dynamic> loadImage(BuildContext context, String image) async {
    var url = await FirebaseStorage.instance
        .ref()
        .child("channels_images/" + image)
        .getDownloadURL();
    print(url);
    return url;
  }
}