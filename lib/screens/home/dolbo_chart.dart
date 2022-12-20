import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:dolbo_app/sizes.dart';
import 'package:dolbo_app/const/data_type.dart';
import 'package:dolbo_app/utils/number_handler.dart';

class DolboChart extends StatefulWidget {
  final List<ChartData> chartData;
  final double dangerIndicator;
  final double warningIndicator;

  const DolboChart({
    Key? key,
    required this.chartData,
    required this.warningIndicator,
    required this.dangerIndicator,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DolboChart();
}

class _DolboChart extends State<DolboChart> {
  List<ChartData> _sourceData = [];
  List<ChartData> _warningData = [];
  List<ChartData> _dangerData = [];

  late ZoomPanBehavior _zoomPanBehavior;
  final _numberHandler = NumberHandler();

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(
        enablePinching: true, zoomMode: ZoomMode.x, enablePanning: true);
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _sourceData = [];
      _warningData = [];
      _dangerData = [];
    });
    widget.chartData.asMap().forEach((index, element) {
      setState(() {
        _sourceData.add(ChartData(
            time: element.time.length > 10
                ? _numberHandler.serverTimeToChartString(element.time)
                : element.time,
            value: element.value));
        _warningData.add(ChartData(
            time: element.time.length > 10
                ? _numberHandler.serverTimeToChartString(element.time)
                : element.time,
            value: widget.warningIndicator));
        _dangerData.add(ChartData(
            time: element.time.length > 10
                ? _numberHandler.serverTimeToChartString(element.time)
                : element.time,
            value: widget.dangerIndicator));
      });
    });

    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(context.pWidth * 0.01),
        child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(labelFormat: '{value}mm'),
            legend: Legend(position: LegendPosition.bottom, isVisible: true),
            series: <ChartSeries<ChartData, String>>[
              LineSeries<ChartData, String>(
                  name: '수위',
                  color: Colors.blue,
                  dataSource: _sourceData,
                  xValueMapper: (ChartData rtData, _) => rtData.time,
                  yValueMapper: (ChartData rtData, _) => rtData.value),
              LineSeries<ChartData, String>(
                name: '위험',
                color: Colors.orange,
                dataSource: _warningData,
                xValueMapper: (ChartData rtData, _) => rtData.time,
                yValueMapper: (ChartData rtData, _) => rtData.value,
              ),
              LineSeries<ChartData, String>(
                name: '범람',
                color: Colors.red,
                dataSource: _dangerData,
                xValueMapper: (ChartData rtData, _) => rtData.time,
                yValueMapper: (ChartData rtData, _) => rtData.value,
              ),
            ],
            tooltipBehavior:
                TooltipBehavior(enable: true, shared: true, opacity: 0.6),
            zoomPanBehavior:
                widget.chartData.isNotEmpty ? _zoomPanBehavior : null));
  }
}
