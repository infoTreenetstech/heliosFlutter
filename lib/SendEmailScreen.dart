import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import 'ApiConstant.dart';

class EmailComposeScreen extends StatefulWidget {
  @override
  _EmailComposeScreenState createState() => _EmailComposeScreenState();
}

class _EmailComposeScreenState extends State<EmailComposeScreen> {
  List<String> customerEmails = [];
  String subject = "";
  String message = "";
  List<String> attachmentPaths = [];

  TextEditingController subjectController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  TextEditingController customerEmailsController = TextEditingController();

  List<String> emailAddresses = [
    "gogwalesunny58@gmail.com",
    "sunnygogwale0@gmail.com",
    "user3@example.com",
  ];

  List<String> selectedEmails = [];

  void handleCheckboxChange(String email, bool? value) {
    setState(() {
      if (value != null) {
        if (value) {
          selectedEmails.add(email);
        } else {
          selectedEmails.remove(email);
        }
      }
    });
  }

  void openRecipientDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Recipients"),
          content: SingleChildScrollView(
            child: Column(
              children: emailAddresses.map((email) {
                bool isSelected = selectedEmails.contains(email);
                return ListTile(
                  title: Text(email),
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      handleCheckboxChange(email, value);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                customerEmailsController.text +=
                    selectedEmails.join(", ") + " ";
                Navigator.pop(context);
              },
              child: Text("Add Recipients"),
            ),
          ],
        );
      },
    );
  }

  String? filePath;
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      final PlatformFile file = result.files.first;
      setState(() {
        filePath = file.path;
        if (filePath != null) {
          attachmentPaths.add(filePath!);
        }
      });
    }
  }

  Future<void> sendEmail() async {
    try {
      final selectedEmailsString = selectedEmails.join(", ");
      final emailData = {
        "recipients": selectedEmailsString,
        "subject": subjectController.text,
        "message": messageController.text,
        "attachmentPaths": attachmentPaths,
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}sendEmail'),
      );

      if (attachmentPaths.isNotEmpty) {
        for (String path in attachmentPaths) {
          final fileBytes = File(path);
          final fileStream = http.ByteStream(
            Stream.fromIterable([fileBytes.readAsBytesSync()]),
          );
          final fileLength = await fileBytes.length();

          request.files.add(http.MultipartFile(
            'file',
            fileStream,
            fileLength,
            filename: 'attachment.txt',
          ));
        }
      }

      request.fields['recipients'] = selectedEmailsString;
      request.fields['subject'] = subjectController.text;
      request.fields['message'] = messageController.text;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        _showResultDialog('Email sent successfully');
      } else {
        _showResultDialog('Email sending failed');
      }
    } catch (e) {
      _showResultDialog('Error sending email: $e');
    }
  }

  void _showResultDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Email Status"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    subjectController.dispose();
    messageController.dispose();
    customerEmailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Compose Email"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text("Customer Emails:"),
                SizedBox(width: 10),
                IconButton(
                  // "+" icon
                  icon: Icon(Icons.add),
                  onPressed: openRecipientDialog,
                ),
              ],
            ),
            TextField(
              controller: customerEmailsController,
              decoration: const InputDecoration(
                hintText: "Enter customer emails (comma-separated)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text("Subject:"),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                hintText: "Subject",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text("Message:"),
            TextField(
              controller: messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Message",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                pickFile();
              },
              child: Text("Attach File"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sendEmail();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                )),
              ),
              child: Text("Send Email"),
            ),
          ],
        ),
      ),
    );
  }
}
