import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:helios_application/ApiConstant.dart';
import 'package:helios_application/MyDrawer.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  Future<void> _pickAndUploadExcelFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'], // Specify allowed file extensions
    );

    if (result != null) {
      PlatformFile file = result.files.single;

      var request = http.MultipartRequest(
          'POST', Uri.parse("${ApiConstants.baseUrl}excel/upload"));
      request.files.add(http.MultipartFile.fromBytes(
        'file', // Field name for the file (adjust as needed)
        file.bytes as List<int>,
        filename: file.name,
      ));

      var response = await request.send();
      if (response.statusCode == 200) {
        // Upload successful
        print('File uploaded successfully');
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

  @override
  Widget build(BuildContext context) {
    // Simulated data for finance companies
    List<String> financeCompanies = [
      "Company A",
      "Company B",
      "Company C",
      "Company D"
    ];

    return Scaffold(
      appBar: AppBar(title: Text('HELIOS'), actions: <Widget>[
        IconButton(
          icon: Icon(Icons.file_upload),
          onPressed: () {
            _pickAndUploadExcelFile(context).then((_) {
              // This block will be executed when the Future completes.
            });
          },
        ),
      ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to your app!'),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                ),
                itemCount: financeCompanies.length,
                itemBuilder: (context, index) {
                  return FinanceCompanyCard(financeCompanies[index]);
                },
              ),
            ),
          ],
        ),
      ),
      drawer: MyDrawer(),
    );
  }
}

class FinanceCompanyCard extends StatelessWidget {
  final String companyName;

  FinanceCompanyCard(this.companyName);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Text(
            companyName,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
