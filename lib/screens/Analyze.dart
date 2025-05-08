import 'package:flutter/material.dart';
import 'package:invoiceapp/services/database_service.dart';

class FinancialAnalysisPage extends StatefulWidget {
  const FinancialAnalysisPage({Key? key}) : super(key: key);

  @override
  State<FinancialAnalysisPage> createState() => _FinancialAnalysisPageState();
}

class _FinancialAnalysisPageState extends State<FinancialAnalysisPage> {
  double totalIncome = 0.0;
  double totalCost = 0.0;
  double profit = 0.0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _calculateFinancials();
  }

  Future<void> _calculateFinancials() async {
    final db = await DatabaseService.instance.getdatabase();

    // Calculate Total Income
    final incomeResult = await db
        .rawQuery('SELECT SUM(total_price) as total_income FROM invoice');
    totalIncome =
        (incomeResult.first['total_income'] as num?)?.toDouble() ?? 0.0;

    // Calculate Total Cost
    final costResult = await db.rawQuery('''
      SELECT SUM(ii.quantity * i.cost) as total_cost
      FROM invoice_items ii
      JOIN item i ON ii.item_id = i.id
    ''');
    totalCost = (costResult.first['total_cost'] as num?)?.toDouble() ?? 0.0;

    // Calculate Profit
    profit = totalIncome - totalCost;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Analysis')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildCard('Total Income', totalIncome, Colors.green),
                  const SizedBox(height: 12),
                  _buildCard('Total Cost', totalCost, Colors.orange),
                  const SizedBox(height: 12),
                  _buildCard('Profit', profit, Colors.blue),
                ],
              ),
            ),
    );
  }

  Widget _buildCard(String title, double value, Color color) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(Icons.monetization_on, color: color),
        title: Text(title),
        trailing: Text(
          'LKR ${value.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
