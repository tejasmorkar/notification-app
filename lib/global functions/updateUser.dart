import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';

void updateUser(Map user){
  var _firebaseFirestore=FirebaseFirestore.instance;
  var box=Hive.box('myBox');
  box.put('userData', user);
  _firebaseFirestore.collection("users").doc(user['uid']).set(user).whenComplete(() {
    Fluttertoast.showToast(msg: "Successfully updated your data");
  });
}