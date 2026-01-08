import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/job_application_model.dart';
import '../dashboard_data_processor.dart';
import '../dashboard_utils.dart';

/// Dashboard performance chart widget
class DashboardPerformanceChart extends StatelessWidget {
  final List<JobApplicationModel> applications;

  const DashboardPerformanceChart({super.key, required this.applications});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DashboardUtils.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'ประสิทธิภาพการประกาศงาน',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // TextButton(
              //   onPressed: () {
              //     DashboardUtils.showDetailedAnalytics(context);
              //   },
              //   child: const Text('ดูรายละเอียด'),
              // ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 200, child: _buildJobsChart()),
        ],
      ),
    );
  }

  Widget _buildJobsChart() {
    final chartData = DashboardDataProcessor.getApplicationsChartData(
      applications,
    );

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = [
                  'ม.ค.',
                  'ก.พ.',
                  'มี.ค.',
                  'เม.ย.',
                  'พ.ค.',
                  'มิ.ย.',
                  'ก.ค.',
                  'ส.ค.',
                  'ก.ย.',
                  'ต.ค.',
                  'พ.ย.',
                  'ธ.ค.',
                ];
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Text(months[value.toInt()]);
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: chartData.map((point) => FlSpot(point.x, point.y)).toList(),
            isCurved: true,
            color: const Color(0xFF2196F3),
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF2196F3).withValues(alpha: 0.1),
            ),
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
