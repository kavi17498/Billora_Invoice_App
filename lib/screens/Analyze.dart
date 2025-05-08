import 'package:flutter/material.dart';
import 'package:invoiceapp/services/database_service.dart';
import 'package:fl_chart/fl_chart.dart';

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

  List<Map<String, dynamic>> monthlyIncome = [];

  @override
  void initState() {
    super.initState();
    _calculateFinancials();
  }

  Future<void> _calculateFinancials() async {
    final db = await DatabaseService.instance.getdatabase();

    final incomeResult = await db
        .rawQuery('SELECT SUM(total_price) as total_income FROM invoice');
    totalIncome =
        (incomeResult.first['total_income'] as num?)?.toDouble() ?? 0.0;

    final costResult = await db.rawQuery('''
      SELECT SUM(ii.quantity * i.cost) as total_cost
      FROM invoice_items ii
      JOIN item i ON ii.item_id = i.id
    ''');
    totalCost = (costResult.first['total_cost'] as num?)?.toDouble() ?? 0.0;

    profit = totalIncome - totalCost;

    final monthResult = await db.rawQuery('''
      SELECT strftime('%Y-%m', created_at) as month, SUM(total_price) as income
      FROM invoice
      GROUP BY month
      ORDER BY month ASC
    ''');

    monthlyIncome = monthResult.map((row) {
      return {
        'month': row['month'],
        'income': (row['income'] as num).toDouble(),
      };
    }).toList();

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildCard('Total Income', totalIncome, Colors.green),
                  const SizedBox(height: 12),
                  _buildCard('Total Cost', totalCost, Colors.orange),
                  const SizedBox(height: 12),
                  _buildCard('Profit', profit, Colors.blue),
                  const SizedBox(height: 24),
                  const Text('Income/Cost/Profit Ratio',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 200, child: _PieChartWidget()),
                  const Text('Monthly Income Trend',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 200, child: _MonthlyIncomeChart()),
                  const SizedBox(height: 24),
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

class _MonthlyIncomeChart extends StatelessWidget {
  const _MonthlyIncomeChart();

  @override
  Widget build(BuildContext context) {
    final state =
        context.findAncestorStateOfType<_FinancialAnalysisPageState>();
    final data = state?.monthlyIncome ?? [];

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('Month'),
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                if (value < data.length) {
                  return Text(data[value.toInt()]['month']
                      .toString()
                      .substring(5)); // MM
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              final i = entry.key;
              final val = entry.value['income'] as double;
              return FlSpot(i.toDouble(), val);
            }).toList(),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class _PieChartWidget extends StatelessWidget {
  const _PieChartWidget();

  @override
  Widget build(BuildContext context) {
    final state =
        context.findAncestorStateOfType<_FinancialAnalysisPageState>();

    if (state == null) return const SizedBox.shrink();

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: state.totalIncome,
            color: Colors.green,
            title: 'Income',
          ),
          PieChartSectionData(
            value: state.totalCost,
            color: Colors.orange,
            title: 'Cost',
          ),
          PieChartSectionData(
            value: state.profit,
            color: Colors.blue,
            title: 'Profit',
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 30,
      ),
    );
  }
}
