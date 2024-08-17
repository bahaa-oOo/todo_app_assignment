import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/model/todo_dm.dart';
import 'package:todo_app/model/user_dm.dart';
import 'package:todo_app/ui/utils/app_style.dart';
import 'package:todo_app/ui/utils/date_time_extension.dart';

class AddBottomSheet extends StatefulWidget {
  const AddBottomSheet({super.key});

  @override
  State<AddBottomSheet> createState() => _AddBottomSheetState();

  static Future show(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: const AddBottomSheet(),
          );
        });
  }
}

class _AddBottomSheetState extends State<AddBottomSheet> {
  DateTime selectedDate = DateTime.now();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .4,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Add new task",
            textAlign: TextAlign.center,
            style: AppStyle.bottomSheetTitle,
          ),
          TextField(
            decoration: InputDecoration(hintText: "Enter task title"),
            controller: titleController,
          ),
          const SizedBox(
            height: 12,
          ),
          TextField(
            decoration: InputDecoration(hintText: "Enter task description"),
            controller: descriptionController,
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            "Select date",
            style: AppStyle.bottomSheetTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(
            height: 12,
          ),
          InkWell(
              onTap: () {
                showMyDatePicker();
              },
              child: Text(
                selectedDate.toFormattedDate,
                style: AppStyle.normalGreyTextStyle,
                textAlign: TextAlign.center,
              )),
          const Spacer(),
          ElevatedButton(
              onPressed: () {
                addTodoToFireStore();
              },
              child: const Text("Add"))
        ],
      ),
    );
  }

  void addTodoToFireStore() {
    CollectionReference todosCollection = FirebaseFirestore.instance
        .collection(UserDM.collectionName)
        .doc(UserDM.currentUser!.id)
        .collection(TodoDM.collectionName);
    DocumentReference doc = todosCollection.doc();
    TodoDM todoDM = TodoDM(
        id: doc.id,
        title: titleController.text,
        date: selectedDate,
        description: descriptionController.text,
        isDone: false);
    doc.set(todoDM.toJson()).then((_) {
      ///This callback is called when future is completed
      Navigator.pop(context);
    }).onError((error, stackTrace) {
      /// This callback is called when the throws an exception
    }).timeout(const Duration(milliseconds: 500), onTimeout: () {
      /// This callback is called after duration you've in first argument
    });
  }

  void showMyDatePicker() async {
    selectedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365))) ??
        selectedDate;
    setState(() {});
  }
}
