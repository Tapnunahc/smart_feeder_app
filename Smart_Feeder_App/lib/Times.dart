import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; //json

class Times extends StatefulWidget {
  const Times({super.key});

  @override
  _TimesState createState() => _TimesState();
}

class _TimesState extends State<Times> {
  // data
  List<Map<String, dynamic>> savedRecipes = [];
  Map<String, dynamic>? selectedRecipe;
  List<TimeOfDay> tempFeedingTimes = [];
  List<double> tempFoodAmountsPerMeal = [];
  String? savedRecipeName;
  List<String> savedMealTimes = [];

  @override
  void initState() {
    super.initState();
    loadRecipes(); // โหลดสูตรอาหาร
    loadFeedingSchedule(); // โหลดเวลาให้อาหาร
  }

  // โหลดสูตร
  Future<void> loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    String? recipesJson = prefs.getString('savedRecipes');
    if (recipesJson != null) {
      setState(() {
        savedRecipes = List<Map<String, dynamic>>.from(jsonDecode(recipesJson));
      });
    }
  }

  // โหลดตารางให้อาหารที่เซฟไว้
  Future<void> loadFeedingSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    String? feedingScheduleJson = prefs.getString('feedingSchedule');
    if (feedingScheduleJson != null) {
      Map<String, dynamic> feedingSchedule = jsonDecode(feedingScheduleJson);
      setState(() {
        savedRecipeName = feedingSchedule['recipeName'];
        savedMealTimes = List<String>.from(feedingSchedule['feedingTimes']);
        if (feedingSchedule.containsKey('foodAmounts')) {
          tempFoodAmountsPerMeal = List<double>.from(feedingSchedule['foodAmounts']);
        }
      });
    }
  }

  //เลือกเวลา
  Future<void> _selectTime(BuildContext context) async {
    if (selectedRecipe == null) return;

    if (tempFeedingTimes.length >= selectedRecipe!['meals']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("คุณได้เลือกเวลาครบ ${selectedRecipe!['meals']} มื้อแล้ว")),
      );
      return;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        tempFeedingTimes.add(picked);

        // เรียงเวลา
        tempFeedingTimes.sort((a, b) {
          final aMinutes = a.hour * 60 + a.minute;
          final bMinutes = b.hour * 60 + b.minute;
          return aMinutes.compareTo(bMinutes);
        });

        // คำนวณอาหารต่อมื้อ
        tempFoodAmountsPerMeal = List.generate(
          tempFeedingTimes.length,
          (_) => selectedRecipe!['foodAmount'] / selectedRecipe!['meals'],
        );
      });
    }
  }

  // บันทึกเวลาให้อาหาร
  void saveFeedingSchedule() async {
    if (selectedRecipe == null || tempFeedingTimes.length != selectedRecipe!['meals']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("กรุณาเลือกเวลาให้ครบ ${selectedRecipe!['meals']} มื้อ")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> feedingSchedule = {
      'recipeName': selectedRecipe!['name'],
      'feedingTimes': tempFeedingTimes.map((time) => time.format(context)).toList(),
      'foodAmounts': tempFoodAmountsPerMeal,
    };

    await prefs.setString('feedingSchedule', jsonEncode(feedingSchedule));
    setState(() {
      savedRecipeName = selectedRecipe!['name'];
      savedMealTimes = feedingSchedule['feedingTimes'];
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("บันทึกเวลาให้อาหารเรียบร้อยแล้ว")));
  }

  // UI 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ตั้งเวลาให้อาหาร"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("รายการสูตรอาหารที่บันทึกไว้:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: savedRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = savedRecipes[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(recipe['name']),
                      subtitle: Text("จำนวนมื้อ: ${recipe['meals']}, ปริมาณอาหาร: ${recipe['foodAmount']} กรัม/วัน"),
                      onTap: () {
                        setState(() {
                          selectedRecipe = recipe;
                          tempFeedingTimes.clear();
                          tempFoodAmountsPerMeal.clear();
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedRecipe != null ? () => _selectTime(context) : null,
              child: Text("เลือกเวลาให้อาหาร"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tempFeedingTimes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('มื้อที่ ${index + 1}: ${tempFeedingTimes[index].format(context)} (${tempFoodAmountsPerMeal[index].toStringAsFixed(1)} กรัม)'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          tempFeedingTimes.removeAt(index);
                          tempFoodAmountsPerMeal.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: saveFeedingSchedule,
              child: Text("บันทึกเวลา"),
            ),
            SizedBox(height: 20),
            if (savedRecipeName != null) ...[
              Text("สูตรอาหารที่บันทึกไว้: $savedRecipeName",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("มื้ออาหารและปริมาณที่บันทึกไว้:"),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: savedMealTimes.length,
                itemBuilder: (context, index) {
                  final time = savedMealTimes[index];
                  final amount = (index < tempFoodAmountsPerMeal.length)
                      ? tempFoodAmountsPerMeal[index].toStringAsFixed(1)
                      : "-";
                  return Text("มื้อที่ ${index + 1}: $time, ${amount} กรัม");
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}



