import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:helios_application/DataTableExample.dart';
import 'package:http/http.dart' as http;
import 'EmailTemplateForm.dart';
import 'MyHomePage.dart';
import 'SendEmailScreen.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const UserAccountsDrawerHeader(
            accountName: Text('John Doe'),
            accountEmail: Text('john@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  AssetImage('assets/avatar.jpg'), // Add your avatar image
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.person),
          //   title: const Text('Customer Master'),
          //   trailing: PopupMenuButton<int>(
          //     itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
          //       const PopupMenuItem<int>(
          //         value: 1,
          //         child: Text('All Customer'),
          //       ),
          //       const PopupMenuItem<int>(
          //         value: 2,
          //         child: Text('File Upload'),
          //       ),
          //       const PopupMenuItem<int>(
          //         value: 3,
          //         child: Text('Create Customer'),
          //       ),
          //     ],
          //     onSelected: (int selection) {
          //       switch (selection) {
          //         case 1:
          //           Navigator.of(context).push(
          //             MaterialPageRoute(
          //                 builder: (context) => DataTableExample()),
          //           );
          //           break;
          //         case 2:
          //           Navigator.of(context).push(
          //             MaterialPageRoute(
          //                 builder: (context) =>
          //                     _pickAndUploadExcelFile(context)),
          //           );
          //           break;
          //         case 3:
          //           // Handle "Create Customer" navigation here.
          //           break;
          //       }
          //     },
          //   ),
          // ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Email Sender'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => EmailComposeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('All Customer'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DataTableExample()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Template'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => EmailTemplateForm()),
              );
            },
          ),
        ],
      ),
    );
  }

  _pickAndUploadExcelFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'], // Specify allowed file extensions
    );

    if (result != null) {
      PlatformFile file = result.files.single;

      var request = http.MultipartRequest(
          'POST', Uri.parse("http://localhost:8080/api/excel/upload"));
      request.files.add(http.MultipartFile.fromBytes(
        'file', // Field name for the file (adjust as needed)
        file.bytes as List<int>,
        filename: file.name,
      ));

      var response = await request.send();
      if (response.statusCode == 200) {
        // Upload successful
        print('File uploaded successfully');
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: Text('File uploaded successfully.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Handle the error, e.g., display an error message
        print('Error uploading file: ${response.reasonPhrase}');
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Error uploading file: ${response.reasonPhrase}'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }
}
