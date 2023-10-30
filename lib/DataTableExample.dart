import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:helios_application/ApiConstant.dart';
import 'package:http/http.dart' as http;

class DataTableExample extends StatefulWidget {
  @override
  _DataTableExampleState createState() => _DataTableExampleState();
}

class _DataTableExampleState extends State<DataTableExample> {
  List<Map<String, dynamic>> data = [];
  Set<int> selectedRows = Set<int>();

  @override
  void initState() {
    super.initState();
    loadTableData();
  }

  void loadTableData() async {
    try {
      final fetchedData = await fetchData();
      if (fetchedData != null) {
        setState(() {
          data = fetchedData;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    final response = await http.get(
      Uri.parse(
          '${ApiConstants.baseUrl}excel/alldata'), // Replace with your API endpoint
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      List<Map<String, dynamic>> data = jsonData.cast<Map<String, dynamic>>();
      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _searchData(String query) {
    if (query.isNotEmpty) {
      final lowerCaseQuery = query.toLowerCase();
      final filteredData = data.where((row) {
        final idString = row['id'].toString().toLowerCase();
        final incomeString = row['income'].toString().toLowerCase();
        final email = row['email'].toString().toLowerCase();

        return idString.contains(lowerCaseQuery) ||
            incomeString.contains(lowerCaseQuery) ||
            email.contains(lowerCaseQuery);
      }).toList();

      setState(() {
        data = filteredData;
      });
    } else {
      loadTableData();
    }
  }

  Future<void> _deleteRow(int id) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this record?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      try {
        final response = await http.delete(
          Uri.parse('${ApiConstants.baseUrl}excel/delete/$id'),
        );

        if (response.statusCode == 200) {
          loadTableData();
        } else {
          // Handle error message
        }
      } catch (e) {
        // Handle any network or request errors.
      }
    }
  }

  Future<void> _deleteSelectedRows() async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete selected records?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      List<int> selectedIds = selectedRows.toList();
      for (int id in selectedIds) {
        try {
          final response = await http.delete(
            Uri.parse('${ApiConstants.baseUrl}excel/delete/$id'),
          );

          if (response.statusCode == 200) {
            selectedRows.remove(id);
          } else {
            // Handle error message
          }
        } catch (e) {
          // Handle any network or request errors.
        }
      }

      loadTableData();
    }
  }

  Future<void> _showEditDialog(int id, Map<String, dynamic> rowData) async {
    TextEditingController nameController =
        TextEditingController(text: rowData['name']);
    TextEditingController emailController =
        TextEditingController(text: rowData['email']);
    TextEditingController incomeController =
        TextEditingController(text: rowData['income']);

    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: incomeController,
                decoration: InputDecoration(labelText: 'Income'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      Map<String, dynamic> updatedData = {
        'id': id,
        'name': nameController.text,
        'email': emailController.text,
        'income': incomeController.text,
      };
      _updateRow(id, updatedData);
    }
  }

  Future<void> _updateRow(int id, Map<String, dynamic> newData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}excel/update/$id'),
        body: jsonEncode(newData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        loadTableData();
      } else {
        // Handle update error
      }
    } catch (e) {
      // Handle any network or request errors.
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSelectAllChecked =
        data.isNotEmpty && selectedRows.length == data.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('All Customer'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              onChanged: _searchData,
              decoration: InputDecoration(labelText: 'Search'),
            ),
          ),
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height - 200,
              child: ListView(
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Row(
                            children: [
                              Checkbox(
                                value: isSelectAllChecked,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      isSelectAllChecked = value;
                                      selectedRows.clear();
                                      if (value) {
                                        selectedRows.addAll(data
                                            .map((row) => row['id'] as int));
                                      }
                                    });
                                  }
                                },
                              ),
                              Text('Select'),
                            ],
                          ),
                        ),
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Income')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: data.map((row) {
                        bool isSelected = selectedRows.contains(row['id']);

                        return DataRow(
                          cells: [
                            DataCell(
                              Checkbox(
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value != null) {
                                      if (value) {
                                        selectedRows.add(row['id'] as int);
                                      } else {
                                        selectedRows.remove(row['id'] as int);
                                      }
                                    }
                                  });
                                },
                              ),
                            ),
                            DataCell(Text(row['id'].toString())),
                            DataCell(Text(row['name'].toString())),
                            DataCell(Text(row['email'].toString())),
                            DataCell(Text(row['income'].toString())),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditDialog(row['id'] as int, row);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteRow(row['id'] as int);
                                  },
                                ),
                              ],
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _deleteSelectedRows,
            child: Text('Delete Selected Records'),
          ),
        ],
      ),
    );
  }
}
