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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildCalendar(),
        Expanded(
          flex: 75,
          child: StreamBuilder<QuerySnapshot>(
            stream: getTodosStreamFromFireStore(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('حدث خطأ أثناء تحميل البيانات'));
              }

              List<TodoDM> todosList = snapshot.data!.docs.map((doc) {
                Map<String, dynamic> json = doc.data() as Map<String, dynamic>;
                return TodoDM.fromJson(json);
              }).toList();

              // فلترة المهام بناءً على التاريخ المحدد
              todosList = todosList.where((todo) =>
              todo.date.year == selectedCalendarDate.year &&
                  todo.date.month == selectedCalendarDate.month &&
                  todo.date.day == selectedCalendarDate.day).toList();

              if (todosList.isEmpty) {
                return Center(child: Text('لا توجد مهام لهذا اليوم'));
              }

              return ListView.builder(
                itemCount: todosList.length,
                itemBuilder: (context, index) {
                  return Todo(
                    item: todosList[index],
                    onDelete: () {
                      deleteTodoFromFirestore(todosList[index].id);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // الحصول على Stream من Firestore
  Stream<QuerySnapshot> getTodosStreamFromFireStore() {
    return FirebaseFirestore.instance
        .collection(UserDM.collectionName)
        .doc(UserDM.currentUser!.id)
        .collection(TodoDM.collectionName)
        .snapshots();
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
                  setState(() {
                    selectedCalendarDate = date;
                  });
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
