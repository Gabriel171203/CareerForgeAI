import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SkillRadarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const SkillRadarChart({
    super.key,
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AspectRatio(
      aspectRatio: 1.3,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          dataSets: [
            RadarDataSet(
              fillColor: colorScheme.primary.withOpacity(0.2),
              borderColor: colorScheme.primary,
              entryRadius: 3,
              dataEntries: values.map((e) => RadarEntry(value: e)).toList(),
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          radarBorderData: BorderSide(color: colorScheme.outlineVariant, width: 2),
          tickBorderData: const BorderSide(color: Colors.transparent),
          gridBorderData: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5), width: 1),
          ticksTextStyle: const TextStyle(color: Colors.transparent),
          getTitle: (index, angle) {
            return RadarChartTitle(
              text: labels[index],
              angle: angle,
            );
          },
          tickCount: 5,
        ),
      ),
    );
  }
}
