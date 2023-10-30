import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

import 'ApiConstant.dart';

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
        _attachmentPaths.addAll(result.files.map((file) => file.path ?? ""));
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
    const url = '${ApiConstants.baseUrl}email-templates/create';
    final headers = {'Content-Type': 'application/json'};

    final templateData = {
      'templateName': _templateNameController.text,
      'subject': _subjectController.text,
      'message': _messageController.text,
      'attachmentPaths': _attachmentPaths,
    };

    final jsonBody = json.encode(templateData);

    final response =
        await http.post(Uri.parse(url), headers: headers, body: jsonBody);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email template created successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      _templateNameController.clear();
      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _attachmentPaths.clear();
      });
    } else {
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _templateNameController,
                decoration: InputDecoration(
                  labelText: 'Template Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a template name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              ElevatedButton(
                onPressed: pickAttachment,
                child: Text('Select Attachments'),
              ),

              // Display Selected Attachments
              Container(
                height: 100, // Adjust the height according to your needs
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _attachmentPaths.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          Text(
                            _attachmentPaths[index].split('/').last,
                          ),
                          IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _attachmentPaths.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
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
