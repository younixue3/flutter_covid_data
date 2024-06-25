class CovidData {
  final DateTime date;
  final int totalCases;

  CovidData({required this.date, required this.totalCases});

  factory CovidData.fromJson(String date, Map<String, dynamic> json) {
    return CovidData(
      date: DateTime.parse(date),
      totalCases: json['total'],
    );
  }
}
