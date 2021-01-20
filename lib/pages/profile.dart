import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:notification/global%20functions/internetConnectivity.dart';
import 'package:notification/global%20functions/updateUser.dart';
import 'package:notification/main.dart';
import 'package:notification/pages/NoInternet.dart';
import 'package:notification/providers/user.dart';
import 'package:notification/widgets/channel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String uid;
  User user;
  List<Widget> dataList = [];
  bool bio=false;
  bool internet=false;
  Map<String, dynamic> _user;
  TextEditingController ubio;
  getData(BuildContext context) async {
    print("Function called automatically !");
    user = await FirebaseAuth.instance.currentUser;
    uid = user.uid;
    final _userProvider = Provider.of<UserProvider>(context, listen: false);
    var box=Hive.box('myBox');
    var userData=box.get('userData');
    if(_userProvider.user["uid"]==""){
      _userProvider.setUser(userData);
    }
    list();
  }

  @override
  void initState() {
    check().then((value) {
      if (value != null && value) {
        // Internet Present Case
        getData(context);
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
    super.initState();
  }
  @override
  void dispose() {
    ubio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(appBar: _buildAppBar(context), body: internet?_buildBody(context):Internet()),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final _userProvider = Provider.of<UserProvider>(context);
    _user = _userProvider.user;
    ubio=TextEditingController(text: _user['bio'].toString());
    _user['pNo']=snapshot;
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.indigo,
      automaticallyImplyLeading: true,
      leading: IconButton(
        onPressed: () {
          // Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back_ios),
        color: Colors.white,
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.white,
            ),
            onPressed: () {
              updateUser(_user);
            },
          ),
        )
      ],
      centerTitle: true,
      title: Text(
        "Profile",
        style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      color: Colors.indigo,
      height: double.infinity,
      width: double.infinity,
      child: SingleChildScrollView(child: Column(
        children: [
          _buildStack(context),
        ],
      )),
    );
  }

  Widget _buildStack(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildColumnProfile(context),
        _buildAvatar(context),
      ],
    );
  }

  Widget _buildColumnProfile(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        _buildProfileInfo(context),
      ],
    );
  }

  Widget _buildProfileInfo(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 1.3;
    double imageHeight = MediaQuery.of(context).size.width / 3;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(46),
            topRight: Radius.circular(46),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.25), offset: Offset(0, -4))
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: imageHeight,
            width: double.infinity,
            color: Colors.transparent,
          ),
          _buildUserInfo(context),
          _buildUserBio(context),
          _buildChannelsList(context),
        ],
      ),
    );
  }

  Widget userName(){
    return InkWell(
      child: Text(
        _user["name"],
        style: GoogleFonts.ubuntu(fontSize: 20),
      ),
    );
  }

  Widget userBio(){
    if(bio) return Center(
      child: TextField(
        onSubmitted: (newValue){
          setState(() {
            _user["bio"]=newValue;
            bio=false;
          });
        },
        controller: ubio,
        autofocus: true,
      ),
    );
    return InkWell(
      onTap: (){
        setState(() {
          bio=true;
        });
      },
      child: Center(
        child: Linkify(
          onOpen: (link) async {
            if (await canLaunch(link.url)) {
              await launch(link.url);
            } else {
              throw "Could not launch $link";
            }
          },
          text: _user["bio"],
          style: GoogleFonts.ubuntu(
              fontSize: 15,
              height: 1.35,
              color: Colors.black.withOpacity(0.8)),
          textAlign: TextAlign.justify,
          linkStyle: TextStyle(
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
  Widget userRoll(){
    return InkWell(
      child: Text(
        _user["rNo"],
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
        ),
      ),
    );
  }
  Widget _buildUserInfo(BuildContext context) {
    final _userProvider = Provider.of<UserProvider>(context);
    Map<String, dynamic> _user = _userProvider.user;
    if (snapshot != null) {
      _user["pNo"] = snapshot;
    }
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.only(
        top: 10,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          userName(),
          Text('${_user["pNo"].toString()}'),
          userRoll(),
        ],
      ),
    );
  }

  Widget _buildUserBio(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
      child: userBio(),
    );
  }

  Widget _buildChannelsList(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Subscriptions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        dataList.length.toString(),
                        style: TextStyle(
                            color: Colors.indigo, fontWeight: FontWeight.w700),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 10),
                child: SingleChildScrollView(
                  child: Column(
                    children: dataList,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> list() async {
    List channels=_user["subscriptions"];
    CollectionReference reference=Firestore.instance.collection('channels');
    QuerySnapshot querySnapshot=await reference.getDocuments();

    channels.forEach((document) {
      querySnapshot.documents.forEach((element) {
        if(element['name'].toString().trim()==document.toString().trim()){
          setState(() {
            dataList.add(
              ChannelWidget(
                img: element['img'],
                name: element['name'],
                description: element["description"],
                private: element["mode"],
                developer: true,
              ),
            );
          });
        }
      });
    });
  }

  Widget _buildAvatar(BuildContext context) {
    double _imageHeight = MediaQuery.of(context).size.width / 2.9;
    double _imageWidth = MediaQuery.of(context).size.width / 2.9;
    double _leftOffset =
        MediaQuery.of(context).size.width / 2 - (_imageWidth) / 2;
    double _bottomOffset =
        MediaQuery.of(context).size.height / 1.3 - (_imageHeight);

    return Positioned(
      bottom: _bottomOffset,
      left: _leftOffset,
      child: Container(
        height: _imageHeight,
        width: _imageWidth,
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            image: DecorationImage(
                image: AssetImage('assets/avatars/avatar.jpg'),
                fit: BoxFit.cover),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(.55),
                  offset: Offset(0, -4),
                  blurRadius: 4),
            ]),
      ),
    );
  }
}
