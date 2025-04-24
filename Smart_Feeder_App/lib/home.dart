import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState(); // สร้าง State ของหน้า Home
}

class _HomeState extends State<Home> {
  // ข้อความตอบกลับจาก ESP8266
  String _responseFromESP = 'Waiting for response...';

  // สถานะการเชื่อมต่อกับ ESP8266
  String _connectionStatus = 'Connecting...';

  // ประวัติให้อาหาร
  List<Map<String, dynamic>> history = [];
  
  // สูตรอาหาร ตารางเวลา
  String? recipeName;
  List<String>? feedingTimes;
  List<double>? foodAmounts;

  // ip esp เช็ค IP ก่อนรัน
  final String espIp = '192.168.43.139';

  @override
  void initState() {
    super.initState();
    testConnection(); // ทดสอบเชื่อม board
    _loadFeedingSchedule(); // โหลดตารางอาหารจากเครื่อง
  }

  // โหลดตารางอาหาร
  Future<void> _loadFeedingSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    String? feedingScheduleJson = prefs.getString('feedingSchedule');
    if (feedingScheduleJson != null) {
      Map<String, dynamic> feedingSchedule = jsonDecode(feedingScheduleJson);
      setState(() {
        recipeName = feedingSchedule['recipeName'];
        feedingTimes = List<String>.from(feedingSchedule['feedingTimes']);
        if (feedingSchedule.containsKey('foodAmounts')) {
          foodAmounts = List<double>.from(feedingSchedule['foodAmounts']);
        }
      });
    }
  }

  // ฟังก์ชันทดสอบการเชื่อมต่อกับ ESP
  Future<void> testConnection() async {
    final url = Uri.parse('http://$espIp/');

    try {
      final response = await http.get(url).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        setState(() {
          _connectionStatus = 'Connected';
        });
      } else {
        setState(() {
          _connectionStatus = 'HTTP ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _connectionStatus = 'Connecting';
      });
    }
  }

  // ส่งตารางไป board
  Future<void> sendFeedingScheduleToESP() async {
    if (recipeName == null || feedingTimes == null || foodAmounts == null) {
      setState(() {
        _responseFromESP = 'No feeding schedule available.';       });
      return;
    }

    Map<String, dynamic> feedingData = {
      "recipeName": recipeName,
      "feedingTimes": feedingTimes,
      "foodAmounts": foodAmounts,
    };

    String jsonData = jsonEncode(feedingData);
    final url = Uri.parse('http://$espIp/feed');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonData,
      );

      setState(() {
        if (response.statusCode == 200) {
          _responseFromESP = 'Feeding schedule sent successfully';
        } else {
          _responseFromESP = 'Error: ${response.statusCode}';
        }
      });
    } catch (e) {
      setState(() {
        _responseFromESP = 'Requesting';
      });
    }
  }

  // เอาประวัติจาก board
  Future<void> getFeedingHistory() async {
    final url = Uri.parse('http://$espIp/history');

    try {
      final response = await http.get(url).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> fetchedHistory = jsonDecode(response.body);
        final List<Map<String, dynamic>> newHistory =
            fetchedHistory.map((entry) => Map<String, dynamic>.from(entry)).toList();

        final prefs = await SharedPreferences.getInstance();
        String? savedHistoryJson = prefs.getString('feedingHistory');
        List<Map<String, dynamic>> existingHistory = [];

        if (savedHistoryJson != null) {
          final decoded = jsonDecode(savedHistoryJson);
          existingHistory = List<Map<String, dynamic>>.from(decoded);
        }

        // ตรวจให้ไม่ซ้ำ 
        for (var record in newHistory) {
          bool isDuplicate = existingHistory.any((item) =>
              item['time'] == record['time'] && item['date'] == record['date']);
          if (!isDuplicate) {
            existingHistory.add(record);
          }
        }

        // เซฟประวัติที่อัพเดทแล้ว
        await prefs.setString('feedingHistory', jsonEncode(existingHistory));

        setState(() {
          history = existingHistory;
          _responseFromESP = 'Feeding history updated and saved';
        });
      } else {
        setState(() {
          _responseFromESP = 'Error retrieving history: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _responseFromESP = 'Request failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feeding Schedule Sender & History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Connection Status: $_connectionStatus'), // แสดงสถานะการเชื่อมต่อ
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendFeedingScheduleToESP,
              child: Text('Send Feeding Schedule'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getFeedingHistory,
              child: Text('Get Feeding History'),
            ),
            SizedBox(height: 20),
            Text('Response from ESP8266:', style: Theme.of(context).textTheme.titleLarge),            SizedBox(height: 10),
            Text(_responseFromESP),
            SizedBox(height: 20),
            Text('Feeding History:', style: Theme.of(context).textTheme.titleLarge),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final record = history[index];
                  return Card(
                    child: ListTile(
                      title: Text('${record['feederName']}'),
                      subtitle: Text('Time: ${record['time']}, Amount: ${record['amount']}g, Status: ${record['status']}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



