import 'package:cloud_firestore/cloud_firestore.dart';

class TodoDM {
  static const String collectionName = "todo";
  late String id;
  late String title;
  late DateTime date;
  late String description;
  late bool isDone;

  TodoDM(
      {required this.id,
      required this.title,
      required this.date,
      required this.description,
      required this.isDone});

  TodoDM.fromJson(Map<String, dynamic> json){
    id = json["id"];
    title = json["title"];
    description = json["description"];
    Timestamp timestamp = json["date"];
    date = timestamp.toDate();
    isDone = json["isDone"];
  }


  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "date": date,
    "isDone": isDone
  };
}
