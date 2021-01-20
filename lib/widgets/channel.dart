import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:notification/global%20functions/updateUser.dart';
import 'package:notification/providers/user.dart';
import 'package:provider/provider.dart';

class ChannelWidget extends StatefulWidget {
  final bool private;
  final bool developer;
  final String name;
  final String description;
  final String img;

  ChannelWidget({
    this.img,
    @required this.name,
    @required this.description,
    this.private=false,
    this.developer=false,
  });

  @override
  _ChannelWidgetState createState() => _ChannelWidgetState();
}

class _ChannelWidgetState extends State<ChannelWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user=Provider.of<UserProvider>(context).user;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ]),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 10, left: 20, right: 20),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height / 15,
            width: MediaQuery.of(context).size.height / 15,
            child: FutureBuilder(
              future: _getImage(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    child: snapshot.data,
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    child: CircularProgressIndicator(),
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          widget.img,
                        ),
                        fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 10,
              margin: EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.name,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.description,
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.5), fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  (widget.developer==false)?Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(
                        child: (!user["subscriptions"].contains(widget.name))?Text('Subscribe'):Text('Unsubscribe'),
                        color: widget.private?Colors.grey[800]:Colors.red[800],
                        textColor: Colors.white,
                        onPressed: () {
                          if(!widget.private){
                            final fcm=FirebaseMessaging();
                            setState(() {
                              if(!user["subscriptions"].contains(widget.name)){
                                user["subscriptions"].add(widget.name);
                                fcm.subscribeToTopic(widget.name.replaceAll(" ","_"));
                              }
                              else{
                                user["subscriptions"].remove(widget.name);
                                fcm.unsubscribeFromTopic(widget.name.replaceAll(" ","_"));
                              }
                              updateUser(user);
                            });
                          }
                        },
                      )
                    ],
                  ):Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Widget> _getImage(BuildContext context) async {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            widget.img,
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
