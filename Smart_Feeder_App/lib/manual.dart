/*import 'package:flutter/material.dart';

class Manual extends StatefulWidget {
  const Manual({super.key});

  @override
  State<Manual> createState() => _ManualState();
}

class _ManualState extends State<Manual> {
  double manualGrams = 0;

  void feedNow() {
    if (manualGrams <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("กรุณาใส่จำนวนกรัมที่ต้องการให้อาหาร")),
      );
      return;
    }

    // 👉 ตรงนี้คือจุดที่สามารถเชื่อมกับคำสั่งไปยัง Arduino หรือ ESP8266 ได้
     // print("ให้อาหารจำนวน $manualGrams กรัม");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("ให้อาหารจำนวน $manualGrams กรัมเรียบร้อย")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // จัดกลางแนวตั้ง
          crossAxisAlignment: CrossAxisAlignment.center, // จัดกลางแนวนอน
          children: [
            SizedBox(
              width: 250,
              child: TextField(
                decoration: InputDecoration(
                  labelText: "จำนวนกรัมที่ต้องการให้",
                  border: OutlineInputBorder(),
                  suffixText: "กรัม",
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  setState(() {
                    manualGrams = double.tryParse(val) ?? 0;
                  });
                },
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: feedNow,
              icon: Icon(Icons.warning_amber_rounded),
              label: Text("ให้อาหารตอนนี้"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/