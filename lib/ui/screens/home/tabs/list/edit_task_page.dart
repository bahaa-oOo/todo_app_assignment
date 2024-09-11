import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../model/todo_dm.dart';
import '../../../../../model/user_dm.dart';

class EditTaskPage extends StatefulWidget {
  final TodoDM item;

  const EditTaskPage({Key? key, required this.item}) : super(key: key);

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime selectedTime;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.item.title);
    descriptionController = TextEditingController(text: widget.item.description);
    selectedTime = widget.item.date; // استخدام الحقل الصحيح 'date'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Task"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: "Description"),
            ),
            SizedBox(height: 20),
            Text("Select time:"),
            TextButton(
              onPressed: _selectTime,
              child: Text(
                "${selectedTime.day}-${selectedTime.month}-${selectedTime.year}",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Spacer(),
            isLoading
                ? CircularProgressIndicator() // مؤشر تحميل عند الحفظ
                : ElevatedButton(
              onPressed: _saveChanges,
              child: Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _saveChanges() {
    setState(() {
      isLoading = true;
    });

    // تحديث البيانات في Firestore
    FirebaseFirestore.instance
        .collection(UserDM.collectionName)
        .doc(UserDM.currentUser!.id)
        .collection(TodoDM.collectionName)
        .doc(widget.item.id)
        .update({
      'title': titleController.text,
      'description': descriptionController.text,
      'date': Timestamp.fromDate(selectedTime), // تحويل DateTime إلى Timestamp
      'isDone': widget.item.isDone,
    }).then((_) {
      // تحديث الكائن محليًا بعد التحديث في Firestore
      setState(() {
        widget.item.title = titleController.text;
        widget.item.description = descriptionController.text;
        widget.item.date = selectedTime;
        isLoading = false;
      });

      Navigator.pop(context);
      print("Task updated in Firestore and locally.");
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      print("Error updating task: $error");
    });
  }
}
