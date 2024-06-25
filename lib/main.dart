import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'covid_data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covid-19 Data Chart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CovidChart(),
    );
  }
}

class CovidChart extends StatefulWidget {
  @override
  _CovidChartState createState() => _CovidChartState();
}

class _CovidChartState extends State<CovidChart> {
  late Future<List<CovidData>> futureCovidData;

  @override
  void initState() {
    super.initState();
    futureCovidData = fetchCovidData();
  }

  Future<List<CovidData>> fetchCovidData() async {
    final response = await http.get(
      Uri.parse('https://api.api-ninjas.com/v1/covid19?country=indonesia'),
      headers: {'X-Api-Key': 'fwQ0w+Snh8Owl4UKV51dhw==KPWsNTuWq4B8ooMR'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      Map<String, dynamic> cases = data[0]['cases'];
      return cases.entries
          .map((entry) => CovidData.fromJson(entry.key, entry.value))
          .toList();
    } else {
      throw Exception('Failed to load covid data');
    }
  }

  List<FlSpot> _createFlSpots(List<CovidData> data) {
    return data
        .map((item) => FlSpot(item.date.millisecondsSinceEpoch.toDouble(),
            item.totalCases.toDouble()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Covid-19 Data Chart'),
      ),
      body: Center(
        child: FutureBuilder<List<CovidData>>(
          future: futureCovidData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: EdgeInsets.all(16.0),
                child: LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.fromMillisecondsSinceEpoch(
                                value.toInt());
                            return Text('${date.day}/${date.month}');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: const Color(0xff37434d)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _createFlSpots(snapshot.data!),
                        isCurved: true,
                        barWidth: 2,
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
