import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class BarChart extends StatelessWidget {
  final List<dynamic> data;

  const BarChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<charts.Series<dynamic, String>> series = [
      charts.Series(
          id: "poll",
          data: data,
          domainFn: (dynamic series, _) => series.choice,
          measureFn: (dynamic series, _) => series.votes,
          labelAccessorFn: (dynamic series, _) =>
              '${series.choice} - ${series.votes} votes',
          colorFn: (dynamic series, _) => series.barColor)
    ];

    return Expanded(
        child: charts.BarChart(
      series,
      animate: true,
      vertical: false,
      barRendererDecorator: charts.BarLabelDecorator<String>(),
      primaryMeasureAxis:
          const charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
      domainAxis: const charts.OrdinalAxisSpec(
          showAxisLine: true, renderSpec: charts.NoneRenderSpec()),
    ));
  }
}

class PieChart extends StatelessWidget {
  final List<dynamic> data;

  const PieChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<charts.Series<dynamic, String>> series = [
      charts.Series(
          id: "poll",
          data: data,
          domainFn: (dynamic series, _) => series.choice,
          measureFn: (dynamic series, _) => series.votes,
          labelAccessorFn: (dynamic series, _) =>
              '${series.choice} - ${series.votes} votes',
          colorFn: (dynamic series, _) => series.barColor)
    ];

    return Expanded(
        child: charts.PieChart<String>(
      series,
      animate: false,
      defaultRenderer: charts.ArcRendererConfig(arcRendererDecorators: [
        charts.ArcLabelDecorator(labelPosition: charts.ArcLabelPosition.auto)
      ]),
    ));
  }
}

class PollResults {
  final String choice;
  final int votes;
  final charts.Color barColor;

  PollResults(this.choice, this.votes, this.barColor);
}
