import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:notification/database/circular.dart';
import 'package:notification/global%20functions/internetConnectivity.dart';
import 'package:notification/pages/NoInternet.dart';
import 'package:notification/widgets/post.dart';

class ChannelScreen extends StatefulWidget {
  final String docId, channelDescription;

  const ChannelScreen({Key key, this.docId, this.channelDescription})
      : super(key: key);

  @override
  _ChannelScreenState createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  Future public;
  bool internet = false;

  @override
  void initState() {
    super.initState();
    public = _getPublicSnapshots();
    check().then((value) {
      if (value != null && value) {
        // Internet Present Case
        setState(() {
          internet = true;
        });
      } else {
        setState(() {
          internet = false;
        });
      }
      // No-Internet Case
    });
  }

  _getPublicSnapshots() async {
    QuerySnapshot qn = await _firebaseFirestore
        .collection("public")
        .where("channels", arrayContainsAny: [widget.docId]).get();
    return qn.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.docId),
            Text(
              widget.channelDescription,
              style: GoogleFonts.rajdhani(
                  textStyle: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500, height: 0.8)),
              textAlign: TextAlign.justify,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: (internet == false)
          ? Internet()
          : Container(
              child: FutureBuilder(
                  future: public,
                  builder: (context, snapshot) {
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
                    var box = Hive.box('myBox');
                    for (var tasksData in taskListFromFirebase) {
                      var taskDetails = tasksData.data();
                      print(box.get(taskDetails['id'].toString().trim()));
                      dataList.add(
                        PostWidget(
                          circular: new Circular(
                            title: taskDetails['title'] ?? "",
                            content: taskDetails['content'] ?? "",
                            imgUrl: taskDetails['imgUrl'] ??
                                "https://picsum.photos/200",
                            author: taskDetails['author'] ?? "",
                            id: taskDetails['id'] ?? "",
                            files: taskDetails['files'] ?? [],
                            channels: taskDetails['channels'] ?? [],
                            dept: taskDetails['dept'] ?? [],
                            year: taskDetails['year'] ?? [],
                            division: taskDetails['division'] ?? [],
                            date: DateTime.fromMillisecondsSinceEpoch(
                                taskDetails['ts'] * 1000),
                          ),
                          dataFromDatabase:
                              box.get(taskDetails['id'].toString().trim()) ??
                                  false,
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
            ),
    );
  }
}
