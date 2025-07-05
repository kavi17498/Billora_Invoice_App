import 'package:flutter/material.dart';
import 'package:invoiceapp/services/database_service.dart';
import 'package:invoiceapp/services/currency_service.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';
import 'package:invoiceapp/components/AppLoading.dart';
import 'package:fl_chart/fl_chart.dart';

class FinancialAnalysisPage extends StatefulWidget {
  const FinancialAnalysisPage({super.key});

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
      backgroundColor: AppColors.background,
      body: loading
          ? const AppLoading()
          : RefreshIndicator(
              onRefresh: _calculateFinancials,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: AppTextStyles.h5.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildMetricsGrid(),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Financial Distribution',
                      style: AppTextStyles.h5.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildPieChartCard(),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Monthly Income Trend',
                      style: AppTextStyles.h5.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildLineChartCard(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Income',
                totalIncome,
                Icons.trending_up,
                AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildMetricCard(
                'Total Cost',
                totalCost,
                Icons.trending_down,
                AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildMetricCard(
          'Net Profit',
          profit,
          Icons.account_balance_wallet,
          profit >= 0 ? AppColors.success : AppColors.error,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    double value,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizing.radiusMD),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              if (isFullWidth)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizing.radiusSM),
                  ),
                  child: Text(
                    profit >= 0
                        ? '+${profit.toStringAsFixed(2)}'
                        : profit.toStringAsFixed(2),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FutureBuilder<String>(
            future: CurrencyService.formatAmountWithCurrentCurrency(value),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? 'LKR ${value.toStringAsFixed(2)}',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: _PieChartWidget(
              totalIncome: totalIncome,
              totalCost: totalCost,
              profit: profit,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Income', AppColors.success),
        _buildLegendItem('Cost', AppColors.warning),
        _buildLegendItem('Profit', AppColors.primary),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLineChartCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (monthlyIncome.isEmpty)
            Container(
              height: 250,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 48,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No income data available',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 250,
              child: _MonthlyIncomeChart(monthlyIncome: monthlyIncome),
            ),
        ],
      ),
    );
  }
}

class _MonthlyIncomeChart extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyIncome;

  const _MonthlyIncomeChart({required this.monthlyIncome});

  @override
  Widget build(BuildContext context) {
    if (monthlyIncome.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.border,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: AppColors.border,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < monthlyIncome.length) {
                    final month =
                        monthlyIncome[value.toInt()]['month'].toString();
                    return Text(
                      month.substring(5), // Show MM
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: AppColors.border),
          ),
          minX: 0,
          maxX: monthlyIncome.length.toDouble() - 1,
          minY: 0,
          maxY: monthlyIncome.isEmpty
              ? 0
              : monthlyIncome
                  .map((e) => e['income'] as double)
                  .reduce((a, b) => a > b ? a : b),
          lineBarsData: [
            LineChartBarData(
              spots: monthlyIncome.asMap().entries.map((entry) {
                final i = entry.key;
                final val = entry.value['income'] as double;
                return FlSpot(i.toDouble(), val);
              }).toList(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.8),
                  AppColors.success,
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.success,
                    strokeWidth: 2,
                    strokeColor: AppColors.surface,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.success.withValues(alpha: 0.1),
                    AppColors.success.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PieChartWidget extends StatelessWidget {
  final double totalIncome;
  final double totalCost;
  final double profit;

  const _PieChartWidget({
    required this.totalIncome,
    required this.totalCost,
    required this.profit,
  });

  @override
  Widget build(BuildContext context) {
    if (totalIncome == 0 && totalCost == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No financial data available',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    }

    final total = totalIncome + totalCost + profit.abs();

    return PieChart(
      PieChartData(
        sections: [
          if (totalIncome > 0)
            PieChartSectionData(
              value: totalIncome,
              color: AppColors.success,
              title: '${((totalIncome / total) * 100).toStringAsFixed(1)}%',
              radius: 80,
              titleStyle: AppTextStyles.labelMedium.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (totalCost > 0)
            PieChartSectionData(
              value: totalCost,
              color: AppColors.warning,
              title: '${((totalCost / total) * 100).toStringAsFixed(1)}%',
              radius: 80,
              titleStyle: AppTextStyles.labelMedium.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (profit > 0)
            PieChartSectionData(
              value: profit,
              color: AppColors.primary,
              title: '${((profit / total) * 100).toStringAsFixed(1)}%',
              radius: 80,
              titleStyle: AppTextStyles.labelMedium.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
        sectionsSpace: 3,
        centerSpaceRadius: 50,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Handle touch events if needed
          },
        ),
      ),
    );
  }
}
