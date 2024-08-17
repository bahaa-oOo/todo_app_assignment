import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/model/todo_dm.dart';
import 'package:todo_app/ui/utils/app_colors.dart';
import 'package:todo_app/ui/utils/app_style.dart';
import 'package:todo_app/model/user_dm.dart';

class Todo extends StatefulWidget {
  final TodoDM item;
  final VoidCallback onDelete;

  const Todo({super.key, required this.item, required this.onDelete});

  @override
  _TodoState createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  late bool isDone;
  double _dragExtent = 0.0;
  bool _isDragged = false;

  @override
  void initState() {
    super.initState();
    isDone = widget.item.isDone;
  }

  @override
  Widget build(BuildContext context) {
    double maxDrag = MediaQuery.of(context).size.width * 0.25;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragExtent = (_dragExtent + details.primaryDelta!).clamp(0.0, maxDrag);
        });
      },
      onHorizontalDragEnd: (details) {
        setState(() {
          if (_dragExtent >= maxDrag) {
            _isDragged = true;
          } else {
            _dragExtent = 0.0;
            _isDragged = false;
          }
        });
      },
      child: Stack(
        children: [
          // زر الحذف الذي يظهر عند السحب
          Positioned.fill(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 22, horizontal: 26),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 30.0),
                  child: InkWell(
                    onTap: _performDelete, // تأكد من استدعاء الدالة عند الضغط
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Container الخاص بالمهمة الذي يتم سحبه لليمين
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform: Matrix4.translationValues(
                _isDragged ? maxDrag : _dragExtent, 0, 0),
            child: Container(
              width: MediaQuery.of(context).size.width - 52,
              height: MediaQuery.of(context).size.height * .13,
              decoration: BoxDecoration(
                color: isDone ? Colors.green.shade100 : Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              margin: EdgeInsets.symmetric(vertical: 22, horizontal: 26),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Row(
                children: [
                  buildVerticalLine(context),
                  SizedBox(width: 25),
                  buildTodoInfo(),
                  buildTodoState(),
                ],
              ),
            ),
          ),
        ],
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
        Spacer(),
        Text(
          widget.item.title,
          maxLines: 1,
          style: AppStyle.bottomSheetTitle.copyWith(
              color: isDone ? Colors.green : AppColors.primary),
        ),
        Spacer(),
        Text(
          widget.item.description,
          style: AppStyle.bodyTextStyle,
        ),
        Spacer(),
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
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: isDone
          ? Icon(Icons.done, color: Colors.green, size: 35)
          : Icon(Icons.done, color: Colors.white, size: 35),
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
}
