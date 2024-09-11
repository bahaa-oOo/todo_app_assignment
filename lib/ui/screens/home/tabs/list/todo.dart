import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_app/model/todo_dm.dart';
import 'package:todo_app/ui/utils/app_colors.dart';
import 'package:todo_app/ui/utils/app_style.dart';
import 'package:todo_app/model/user_dm.dart';


import 'edit_task_page.dart'; // تأكد من الاستيراد الصحيح

class Todo extends StatefulWidget {
  final TodoDM item;
  final VoidCallback onDelete;

  const Todo({super.key, required this.item, required this.onDelete});

  @override
  _TodoState createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  late bool isDone;

  @override
  void initState() {
    super.initState();
    isDone = widget.item.isDone;
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(widget.item.id),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25, // غطاء مساحة أقل للمسح
        children: [
          SlidableAction(
            onPressed: (context) => _performDelete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'delete',
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25, // غطاء مساحة أقل للمسح
        children: [
          SlidableAction(
            onPressed: (context) => _navigateToEditTaskPage(),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
        ],
      ),
      child: Container(
        width: MediaQuery.of(context).size.width - 40, // تباعد من الحواف
        height: 140,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isDone ? Colors.green.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          children: [
            buildVerticalLine(context),
            const SizedBox(width: 25),
            buildTodoInfo(),
            buildTodoState(),
          ],
        ),
      ),
    );
  }

  void _performDelete() async {
    try {
      await FirebaseFirestore.instance
          .collection(UserDM.collectionName)
          .doc(UserDM.currentUser!.id)
          .collection(TodoDM.collectionName)
          .doc(widget.item.id)
          .delete();

      widget.onDelete();

      print('Task deleted from Firestore');
    } catch (error) {
      print('Error deleting task: $error');
    }
  }

  buildVerticalLine(BuildContext context) => Container(
    height: MediaQuery.of(context).size.height * .07,
    width: 4,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: isDone ? Colors.green : AppColors.primary,
    ),
  );

  buildTodoInfo() => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text(
          widget.item.title,
          maxLines: 1,
          style: AppStyle.bottomSheetTitle.copyWith(
              color: isDone ? Colors.green : AppColors.primary),
        ),
        const Spacer(),
        Text(
          widget.item.description,
          style: AppStyle.bodyTextStyle,
        ),
        const Spacer(),
      ],
    ),
  );

  buildTodoState() => GestureDetector(
    onTap: () {
      setState(() {
        isDone = !isDone;
      });
      updateTodoStateInFirestore(isDone);
    },
    child: Container(
      decoration: BoxDecoration(
        color: isDone ? Colors.transparent : AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: isDone
          ? const Icon(Icons.done, color: Colors.green, size: 35)
          : const Icon(Icons.done, color: Colors.white, size: 35),
    ),
  );

  void updateTodoStateInFirestore(bool isDone) {
    CollectionReference todoCollection = FirebaseFirestore.instance
        .collection(UserDM.collectionName)
        .doc(UserDM.currentUser!.id)
        .collection(TodoDM.collectionName);

    todoCollection.doc(widget.item.id).update({'isDone': isDone}).then((_) {
      print('Task state updated in Firestore');
    }).catchError((error) {
      print('Error updating task state: $error');
    });
  }

  void _navigateToEditTaskPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskPage(item: widget.item),
      ),
    );
  }
}
