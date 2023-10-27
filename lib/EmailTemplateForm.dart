import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

class EmailTemplateForm extends StatefulWidget {
  @override
  _EmailTemplateFormState createState() => _EmailTemplateFormState();
}

class _EmailTemplateFormState extends State<EmailTemplateForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _templateNameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  List<String> _attachmentPaths = [];

  void pickAttachment() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        _attachmentPaths = result.files.map((file) => file.path ?? "").toList();
      });
    }
  }

  Future<void> showConfirmationDialog() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Email Template'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Are you sure you want to create this email template?'),
              Text('Template Name: ${_templateNameController.text}'),
              Text('Subject: ${_subjectController.text}'),
              Text('Message: ${_messageController.text}'),
              Text('Attachments: ${_attachmentPaths.join(', ')}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      createEmailTemplate();
    }
  }

  void createEmailTemplate() async {
    const url =
        'http://localhost:8080/api/email-templates/create'; // Replace with your server's API URL
    final headers = {'Content-Type': 'application/json'};

    final templateData = {
      'templateName': _templateNameController.text,
      'subject': _subjectController.text,
      'message': _messageController.text,
      'attachmentPaths': _attachmentPaths, // Include the attachment paths
    };

    final jsonBody = json.encode(templateData);

    final response =
        await http.post(Uri.parse(url), headers: headers, body: jsonBody);

    if (response.statusCode == 200) {
      // Email template created successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email template created successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      // Clear form fields and attachment paths
      _templateNameController.clear();
      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _attachmentPaths.clear();
      });
    } else {
      // Handle the case where the creation of the email template fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create email template'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Email Template')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _templateNameController,
                decoration: InputDecoration(labelText: 'Template Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a template name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(labelText: 'Subject'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(labelText: 'Message'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: pickAttachment,
                child: Text('Select Attachments'),
              ),
              Text('Selected Attachments: ${_attachmentPaths.join(', ')}'),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _attachmentPaths.isNotEmpty) {
                    showConfirmationDialog();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Please select at least one attachment and fill in all required fields.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text('Create Template'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
