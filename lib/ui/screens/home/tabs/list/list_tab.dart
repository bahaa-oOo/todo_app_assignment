import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/model/todo_dm.dart';
import 'package:todo_app/ui/screens/home/tabs/list/todo.dart';
import 'package:todo_app/ui/utils/app_colors.dart';
import 'package:todo_app/ui/utils/app_style.dart';
import 'package:todo_app/ui/utils/date_time_extension.dart';

import '../../../../../model/user_dm.dart';

class ListTab extends StatefulWidget {
  const ListTab({super.key});

  @override
  State<ListTab> createState() => ListTabState();
}

class ListTabState extends State<ListTab> {
  DateTime selectedCalendarDate = DateTime.now();
  List<TodoDM> todosList = [];

  @override
  void initState() {
    super.initState();
    getTodosListFromFireStore();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildCalendar(),
        Expanded(
          flex: 75,
          child: ListView.builder(
              itemCount: todosList.length,
              itemBuilder: (context, index) {
                return Todo(
                  item: todosList[index],
                  onDelete: () {
                    setState(() {
                      todosList.removeAt(index); // حذف العنصر من القائمة
                    });
                    // إذا كنت ترغب في حذف العنصر من Firestore أيضًا، يمكنك إضافة الكود هنا
                    deleteTodoFromFirestore(todosList[index].id);
                  },
                );
              }),
        ),
      ],
    );
  }

  void getTodosListFromFireStore() async {
    CollectionReference todoCollection = FirebaseFirestore.instance
        .collection(UserDM.collectionName)
        .doc(UserDM.currentUser!.id)
        .collection(TodoDM.collectionName);
    QuerySnapshot querySnapshot = await todoCollection.get();
    List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    todosList = documents.map((doc) {
      Map<String, dynamic> json = doc.data() as Map<String, dynamic>;
      return TodoDM.fromJson(json);
    }).toList();
    todosList = todosList
        .where((todo) =>
    todo.date.year == selectedCalendarDate.year &&
        todo.date.month == selectedCalendarDate.month &&
        todo.date.day == selectedCalendarDate.day)
        .toList();
    setState(() {});
  }

  buildCalendar() {
    return Expanded(
      flex: 25,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                  child: Container(
                    color: AppColors.primary,
                  )),
              Expanded(
                  child: Container(
                    color: AppColors.bgColor,
                  ))
            ],
          ),
          EasyInfiniteDateTimeLine(
            firstDate: DateTime.now().subtract(Duration(days: 365)),
            focusDate: selectedCalendarDate,
            lastDate: DateTime.now().add(Duration(days: 365)),
            itemBuilder: (context, date, isSelected, onDateTapped) {
              return InkWell(
                onTap: () {
                  selectedCalendarDate = date;
                  getTodosListFromFireStore();
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22)),
                  child: Column(
                    children: [
                      Spacer(),
                      Text(
                        date.dayName,
                        style: isSelected
                            ? AppStyle.selectedCalendarDayStyle
                            : AppStyle.unSelectedCalendarDayStyle,
                      ),
                      Spacer(),
                      Text(
                        date.day.toString(),
                        style: isSelected
                            ? AppStyle.selectedCalendarDayStyle
                            : AppStyle.unSelectedCalendarDayStyle,
                      ),
                      Spacer()
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void deleteTodoFromFirestore(String id) {
    CollectionReference todoCollection = FirebaseFirestore.instance
        .collection(UserDM.collectionName)
        .doc(UserDM.currentUser!.id)
        .collection(TodoDM.collectionName);

    todoCollection.doc(id).delete().then((_) {
      print('تم حذف المهمة من Firestore');
    }).catchError((error) {
      print('حدث خطأ أثناء حذف المهمة: $error');
    });
  }
}
