import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class History extends StatefulWidget {
  const History({super.key});

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory(); 
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    String? historyJson = prefs.getString('feedingHistory');
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      setState(() {
        history = List<Map<String, dynamic>>.from(decoded); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Feeding History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), // หัวข้อ
          SizedBox(height: 10),
          DataTable(
            columns: const [
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Time')),
              DataColumn(label: Text('Amount (g)')),
              DataColumn(label: Text('Status')),
            ],
            rows: history.map((record) => DataRow(cells: [
              DataCell(Text(record['date'] ?? '')),
              DataCell(Text(record['time'] ?? '')),
              DataCell(Text(record['amount'].toString())),
              DataCell(Text(record['status'] ?? '')),
            ])).toList(),
          ),
        ],
      ),
    );
  }
}



