import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notification/database/circular.dart';
import 'package:url_launcher/url_launcher.dart';

class PostPage extends StatefulWidget {
  final Circular circular;

  const PostPage({Key key, this.circular}) : super(key: key);

  // PostWidget({this.dataFromDatabase=false, this.circular});
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Post Details"
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(context),
                SizedBox(height: 12,),
                _buildImage(context),
                SizedBox(height: 12,),
                _buildTextBody(context),
                SizedBox(height: 12,),
                _buildLinkBody(context),
                SizedBox(height: 12,),
                buttonBuilder(),
              ]
          ),
        ),
      ),
    );
  }
  Widget buttonBuilder(){
    String channels="";
    widget.circular.channels.forEach((element) {
      channels+=(element+" ");
    });
    return Text(channels);
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(11),
                image: DecorationImage(image: CachedNetworkImageProvider(widget.circular.imgUrl)),
                border: Border.all(
                  width: 0.1,
                  color: Colors.black.withOpacity(0.5),
                )
            ),
          ),
          Expanded(
            child: Container(
              height: 45,
              padding: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top:3.0),
                    child: Text(
                      widget.circular.title.toString(),
                      style: GoogleFonts.rajdhani(textStyle: TextStyle(fontSize: 18,fontWeight: FontWeight.w600, height: 0.9)),
                    ),
                  ),
                  Text(
                    widget.circular.author.toString(),
                    style: GoogleFonts.rajdhani(textStyle: TextStyle(fontSize: 12,fontWeight: FontWeight.w500, height: 0.9)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:4),
                    child: Text(
                      widget.circular.date.toString(),
                      style: GoogleFonts.rajdhani(textStyle: TextStyle(fontSize: 12,fontWeight: FontWeight.w400, height: 0.8)),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            child: Row(
              children: [
              ],
            ),
          ),
        ],
      ),
    ) ;
  }

  Widget _buildImage(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color.fromRGBO(240, 240, 240, 1),
        borderRadius: BorderRadius.circular(13),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: CachedNetworkImage(
          imageUrl: widget.circular.imgUrl,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  Widget _buildLinkBody(BuildContext context){
    if(widget.circular.files==null)return Container();
    return Column(
      children: [
        ListView.separated(
            itemCount: widget.circular.files.length,
            shrinkWrap: true,
            separatorBuilder: (BuildContext context,int index){
              return SizedBox(height: 12,);
            },
            itemBuilder:(BuildContext context,int index){
              return GestureDetector(
                onTap: (){
                  launch(widget.circular.files[index]);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Linkify(
                      onOpen: (link) async {
                        if (await canLaunch(link.url)) {
                          await launch(link.url);
                        } else {
                          throw "Could not launch $link";
                        }
                      },
                      text: "File ${index+1} contents",
                      style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14,height: 1.25)),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.justify,
                      linkStyle: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                    Icon(Icons.download_outlined,color: Colors.lightBlueAccent,),
                  ],
                ),
              );
            }),
        SizedBox(height: 12,),
      ],
    );


  }
  Widget _buildTextBody(BuildContext context) {
    return Container(
        width: double.infinity,
        child: Linkify(
          onOpen: (link) async {
            if (await canLaunch(link.url)) {
              await launch(link.url);
            } else {
              throw "Could not launch $link";
            }
          },
          text: widget.circular.content.toString(),
          style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14,height: 1.25)),
          textAlign: TextAlign.justify,
          linkStyle: TextStyle(
            color: Colors.blue,
          ),
        )
    );
  }
}
