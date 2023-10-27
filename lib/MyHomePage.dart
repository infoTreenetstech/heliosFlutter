import 'package:flutter/material.dart';
import 'package:helios_application/MyDrawer.dart';

class MyHomePage extends StatelessWidget {
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
      appBar: AppBar(
        title: Text('HELIOS'),
      ),
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
