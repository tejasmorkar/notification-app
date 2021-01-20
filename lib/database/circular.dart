import 'package:hive/hive.dart';

part 'circular.g.dart';

@HiveType(typeId: 1)
class Circular {
  @HiveField(0)
  String title;
  @HiveField(1)
  String content;
  @HiveField(2)
  String imgUrl;
  @HiveField(3)
  String author;
  @HiveField(4)
  String id;
  @HiveField(5)
  List files;
  @HiveField(6)
  List channels;
  @HiveField(7)
  List dept;
  @HiveField(8)
  List year;
  @HiveField(9)
  List division;
  @HiveField(10)
  DateTime date;

  Circular(
      {this.title,
        this.content,
        this.imgUrl,
        this.author,
        this.id,
        this.files,
        this.channels,
        this.dept,
        this.year,
        this.division,
        this.date});
}