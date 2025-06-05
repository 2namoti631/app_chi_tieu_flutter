import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryExpense {
  final String category;
  final double totalAmount;

  CategoryExpense({required this.category, required this.totalAmount});
}

class CategoryBarChart extends StatefulWidget {
  final List<CategoryExpense> data;

  const CategoryBarChart({Key? key, required this.data}) : super(key: key);

  @override
  State<CategoryBarChart> createState() => _CategoryBarChartState();
}

class _CategoryBarChartState extends State<CategoryBarChart> {
  int touchedIndex = -1;

  final List<Color> barColors = [
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
    Colors.brown,
  ];

  @override
  Widget build(BuildContext context) {
    double maxY = 0;
    for (var item in widget.data) {
      if (item.totalAmount > maxY) maxY = item.totalAmount;
    }
    if (maxY == 0) maxY = 10; // tránh maxY = 0 gây lỗi
    maxY *= 1.2;

    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            maxY: maxY,
            barTouchData: BarTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final category = widget.data[group.x.toInt()].category;
                  return BarTooltipItem(
                    '$category\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      backgroundColor: Colors.black87,  // *chỉ background text, không toàn bộ tooltip
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: rod.toY.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),

              touchCallback: (event, response) {
                if (response == null || response.spot == null) {
                  setState(() {
                    touchedIndex = -1;
                  });
                  return;
                }
                setState(() {
                  touchedIndex = response.spot!.touchedBarGroupIndex;
                });
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= widget.data.length) return Container();
                    final category = widget.data[value.toInt()].category;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        category.length > 10
                            ? '${category.substring(0, 9)}…'
                            : category,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: maxY / 5,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade400, width: 1.5),
                left: BorderSide(color: Colors.grey.shade400, width: 1.5),
                top: BorderSide(color: Colors.transparent),
                right: BorderSide(color: Colors.transparent),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              horizontalInterval: maxY / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                  dashArray: [5, 3],
                );
              },
              drawVerticalLine: false,
            ),
            barGroups: List.generate(widget.data.length, (index) {
              final isTouched = index == touchedIndex;
              final color = barColors[index % barColors.length];
              final double height = widget.data[index].totalAmount;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: height,
                    width: 20,
                    borderRadius: BorderRadius.circular(6),
                    fromY: 0,
                    color: isTouched ? Colors.yellow.shade700 : color,
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: Colors.grey[300],
                    ),
                    gradient: isTouched
                        ? LinearGradient(
                      colors: [
                        Colors.yellow.shade400,
                        Colors.yellow.shade700,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    )
                        : null,
                  ),
                ],
                showingTooltipIndicators: isTouched ? [0] : [],
              );
            }),
          ),
        ),
      ),
    );
  }
}
