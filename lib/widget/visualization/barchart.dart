import 'package:ensemble/util/utils.dart';
import 'package:ensemble/widget/visualization/chart_defaults.dart';
import 'package:ensemble_ts_interpreter/invokables/invokable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BarChartProperties {
  final double minY, maxY;
  double barWidth = 14;
  BarChartProperties(this.minY,this.maxY);
}
class EnsembleBarChartController extends Controller {
  String? _title;
  String? get title => _title;
  set title (String? t) {
    _title = t;
    dispatchChanges(KeyValue('title',_title));
  }
  List<String> _labels = [];
  List<String> get labels => _labels;
  set labels (List<String> l) {
    _labels = l;
    dispatchChanges(KeyValue('labels',_labels));
  }
  List metaData = [];
  bool isDirty = false;
  double toDouble(dynamic d) {
    String str = (d==null || d == '')?'0':d.toString()+ '';
    return double.parse(str);
  }
  void setMetaData(List metaData) {
    this.metaData = metaData;
    isDirty = true;
  }
  List<BarChartGroupData> _data = [];
  List<BarChartGroupData> get data {
    if ( !isDirty ) {
      return _data;
    }
    List<BarChartGroupData> d = [];
    //of the shape [{"color":0xfffffff,"y":5},.....]
    for ( int i=0;i<metaData.length;i++ ) {
      Map m = metaData[i];
      d.add(BarChartGroupData(
        x:i,
        barsSpace: 2,
        barRods: [
          BarChartRodData(
            toY: toDouble(m['y']),
            color: Color(m['color']),
            width: Utils.getDouble(m['width'], fallback: properties.barWidth),
            borderRadius: BorderRadius.zero
          )
        ]
      ));
    }
    isDirty = false;
    data = d;
    return _data;
  }
  set data (List<BarChartGroupData> l) {
    _data = l;
    dispatchChanges(KeyValue('data',_data));
  }
  BarChartProperties _properties = BarChartProperties(1, 100);
  BarChartProperties get properties => _properties;
  set properties (BarChartProperties props) {
    _properties = props;
    isDirty = true;
    dispatchChanges(KeyValue('properties',_properties));
  }
}
class EnsembleBarChartState extends BaseWidgetState<EnsembleBarChart>  with ChartDefaults {
  final EnsembleBarChartController controller;

  EnsembleBarChartState(this.controller);

  @override
  Widget build(BuildContext context) {
    BarChart barChart = BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData(controller.labels),
        borderData: borderData,
        barGroups: controller.data,
        gridData: FlGridData(show: false),
        alignment: BarChartAlignment.spaceAround,
        minY: controller.properties.minY,
        maxY: controller.properties.maxY,
      ),
    );
    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: Colors.transparent,
        child: barChart,
      ),
    );
  }
  BarTouchData get barTouchData => BarTouchData(
    enabled: true,
    touchTooltipData: BarTouchTooltipData(
      tooltipBgColor: Colors.orangeAccent,
      tooltipPadding: const EdgeInsets.all(0),
      tooltipMargin: 8,
      getTooltipItem: (
          BarChartGroupData group,
          int groupIndex,
          BarChartRodData rod,
          int rodIndex,
          ) {
        return BarTooltipItem(
          controller.labels[group.x]+':'+rod.toY.round().toString(),
          const TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    ),
  );

}
class EnsembleBarChart extends StatefulWidget with Invokable, HasController<EnsembleBarChartController,EnsembleBarChartState> {
  static const type = 'BarChart';
  final EnsembleBarChartController _controller = EnsembleBarChartController();
  EnsembleBarChart({Key? key}) : super(key: key);
  @override
  EnsembleBarChartController get controller => _controller;


  @override
  EnsembleBarChartState createState() => EnsembleBarChartState(controller);

  @override
  Map<String, Function> getters() {
    return {};
  }

  @override
  Map<String, Function> methods() {
    return {};
  }

  @override
  Map<String, Function> setters() {
    return {
      "title": (Object t)=>controller.title = getString(t),
      "labels": (Object mLabels) {
        List? metaLabels = getList(mLabels);
        if ( metaLabels == null ) {
          throw Exception('LineChart.data must be a list but is not');
        }
        List<String> labels = [];
        for ( Object node in metaLabels ) {
          labels.add(getString(node)!);
        }
        controller.labels = labels;
      },
      "properties": (Object mProps) {
        Map? metaProps = getMap(mProps);
        if ( metaProps == null ) {
          throw Exception("Properties cannot be set ot null and must be set to a map");
        }
        if ( metaProps['minY'] == null || metaProps['maxY'] == null ) {
          throw Exception('both minY and maxY must be specified for lincharts');
        }
        BarChartProperties props = BarChartProperties(metaProps['minY'].toDouble(),metaProps['maxY'].toDouble());
        props.barWidth = Utils.getDouble(metaProps['barWidth'],fallback: props.barWidth);
        controller.properties = props;
      },
      "data": (Object data) {
        List? l = getList(data);
        if ( l == null ) {
          throw Exception('LineChart.data must be a list but is not');
        }
        controller.setMetaData(l);
      }
    };
  }

}