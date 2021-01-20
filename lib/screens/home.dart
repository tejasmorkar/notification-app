import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:notification/database/circular.dart';
import 'package:notification/global%20functions/internetConnectivity.dart';
import 'package:notification/pages/NoInternet.dart';
import 'package:notification/providers/user.dart';
import 'package:notification/widgets/post.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  Future public;
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  bool internet=false;

  @override
  void initState() {
    super.initState();
    public = _memoizer.runOnce(() => _getPublicSnapshots());
    check().then((value) {
      if (value != null && value) {
        // Internet Present Case
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

  _getPublicSnapshots() async {
    var box=Hive.box('myBox');
    List channels=box.get('userData')["subscriptions"];
    if(!channels.contains("public"))channels.add("public");
    QuerySnapshot qn =
    await _firebaseFirestore.collection("public").where("channels",arrayContainsAny: channels).getDocuments();
    return qn.documents;
  }

  @override
  Widget build(BuildContext context) {
    return internet?Container(
      child: FutureBuilder(
          future: public,
          builder: (context, snapshot) {
            if(snapshot.hasError){
              return Center(
                child: Text("Hey, Calm Down. This code doesn't work in O(1) time complexity."),
              );
            }
            if (!snapshot.hasData) {
              return Center(
                child: Container(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text("Loading..."),
              );
            }
            final taskListFromFirebase = snapshot.data;
            List<PostWidget> dataList = [];
            var box=Hive.box('myBox');
            for (var tasksData in taskListFromFirebase) {
              var taskDetails = tasksData.data();
              print(box.get(taskDetails['id'].toString().trim()));
              dataList.add(
                PostWidget(
                  circular: new Circular(
                      title: taskDetails['title']??"",
                      content: taskDetails['content']??"",
                      imgUrl: taskDetails['imgUrl']??"https://picsum.photos/200",
                      author: taskDetails['author']??"",
                      id: taskDetails['id']??"",
                      files: taskDetails['files']??[],
                      channels: taskDetails['channels']??[],
                      dept: taskDetails['dept']??[],
                      year: taskDetails['year']??[],
                      division: taskDetails['division']??[],
                      date:DateTime.fromMillisecondsSinceEpoch(taskDetails['ts']*1000),
                  ),
                  dataFromDatabase: box.get(taskDetails['id'].toString().trim())??false,
                  // files: ,
                ),
              );
            }
            return ListView.separated(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                return dataList[index];
              },
              separatorBuilder: (context, index) {
                return Divider(
                  height: 2.0,
                );
              },
            );
          }),
    ):Internet();
  }
}
