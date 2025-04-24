import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Calc extends StatefulWidget {
  const Calc({super.key});

  @override
  _CalcState createState() => _CalcState();
}
class _CalcState extends State<Calc> {
  // สัตว์ที่เลือก
  String selectedAnimal = 'ไก่';
  String selectedAgeRange = '1-2 เดือน';

  // input อาหาร
  List<Map<String, dynamic>> foodTypes = [];

  // saved สูตร
  List<Map<String, dynamic>> savedRecipes = [];

  // จำนวน
  int animalCount = 1;

  // ข้อมูลสัตว์
  final Map<String, Map<String, dynamic>> animalFeedingData = {
    'ไก่': {
      '1-2 เดือน': {'meals': 4, 'kcal': 800},
      '3-5 เดือน': {'meals': 3, 'kcal': 1000},
      '6 เดือนขึ้นไป': {'meals': 2, 'kcal': 1200},
    },
    'เป็ด': {
      '1-2 เดือน': {'meals': 4, 'kcal': 850},
      '3-5 เดือน': {'meals': 3, 'kcal': 1100},
      '6 เดือนขึ้นไป': {'meals': 2, 'kcal': 1300},
    },
  };

  // call สูตร
  @override
  void initState() {
    super.initState();
    loadRecipes();
  }

  // add อาหาร
  void addFoodType() {
    setState(() {
      foodTypes.add({'name': '', 'kcalPerGram': 0.0});
    });
  }

  // ลบอาหาร
  void removeFoodType(int index) {
    setState(() {
      foodTypes.removeAt(index);
    });
  }

  // บันทึกสูตร
  Future<void> saveRecipe(
    String recipeName,
    double foodAmount,
    int meals,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> newRecipe = {
      'name': recipeName,
      'animal': selectedAnimal,
      'ageRange': selectedAgeRange,
      'animalCount': animalCount, 
      'foodAmount': foodAmount,
      'meals': meals,
      'foodTypes': foodTypes,
    };
    savedRecipes.add(newRecipe);
    await prefs.setString('savedRecipes', jsonEncode(savedRecipes));
    setState(() {});
  }

  // โหลดสูตรจากที่บันทึก
  Future<void> loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    String? recipesJson = prefs.getString('savedRecipes');
    if (recipesJson != null) {
      savedRecipes = List<Map<String, dynamic>>.from(jsonDecode(recipesJson));
      setState(() {});
    }
  }

  // ลบสูตร
  Future<void> deleteRecipe(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedRecipes.removeAt(index);
    });
    await prefs.setString('savedRecipes', jsonEncode(savedRecipes));
  }


  // ฟังก์ชันคำนวณอาหาร 
  void calculateFoodRequirement() {
    var data = animalFeedingData[selectedAnimal]?[selectedAgeRange];
    if (data == null || foodTypes.isEmpty) return;

    // รวมพลังงานต่อกรัม (ใช้ fold รวม kcal ของ foodtype )
    double totalKcalPerGram = foodTypes.fold(0.0, (sum, item) => sum + item['kcalPerGram']);

    // คำนวณอาหารที่ต้องให้ต่อวัน 
   double foodAmount = totalKcalPerGram > 0 ? (data['kcal'] * animalCount) / totalKcalPerGram : 0;

    TextEditingController nameController = TextEditingController();

    // show dialog สำหรับบันทึกสูตร
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("บันทึกสูตรอาหาร"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "ชื่อสูตรอาหาร"),
              ),
              SizedBox(height: 10),
              Text(
                "ปริมาณอาหารที่ต้องให้: ${foodAmount.toStringAsFixed(2)} กรัม/วัน",
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await saveRecipe(
                    nameController.text,
                    foodAmount,
                    data['meals'],
                  );
                  Navigator.pop(context);
                }
              },
              child: Text("บันทึก"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("ปิด"),
            ),
          ],
        );
      },
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("คำนวณปริมาณอาหาร")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ประเภท
              DropdownButton<String>(
                value: selectedAnimal,
                items: ['ไก่', 'เป็ด']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => selectedAnimal = value!),
              ),
              // อายุ
              DropdownButton<String>(
                value: selectedAgeRange,
                items: animalFeedingData[selectedAnimal]!.keys
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => selectedAgeRange = value!),
              ),
              SizedBox(height: 20),
              // จำนวน
              TextField(
                decoration: InputDecoration(
                  labelText: "จำนวนสัตว์ (ตัว)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  setState(() {
                    animalCount = int.tryParse(val) ?? 1;
                  });
                },
              ),
              SizedBox(height: 20),
              Text(
                "ประเภทอาหาร:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // ประเภทอาหาร
              Column(
                children: foodTypes.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> food = entry.value;
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: TextField(
                        decoration: InputDecoration(labelText: "ชื่ออาหาร"),
                        onChanged: (val) =>
                            setState(() => food['name'] = val),
                      ),
                      subtitle: TextField(
                        decoration: InputDecoration(
                          labelText: "แคลอรี่ต่อกรัม",
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => setState(
                          () => food['kcalPerGram'] =
                              double.tryParse(val) ?? 0.0,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeFoodType(index),
                      ),
                    ),
                  );
                }).toList(),
              ),
              // เพิ่มประเภทอาหาร
              ElevatedButton(
                onPressed: addFoodType,
                child: Text("เพิ่มประเภทอาหาร"),
              ),
              SizedBox(height: 20),
              // ปุ่มคำนวณอาหาร
              ElevatedButton(
                onPressed: calculateFoodRequirement,
                child: Text("คำนวณ"),
              ),
              SizedBox(height: 20),
              // แสดงสูตรอาหารที่บันทึก
              Text(
                "\uD83D\uDCCC สูตรอาหารที่บันทึกไว้",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Column(
                children: savedRecipes.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> recipe = entry.value;
                  return ListTile(
                    title: Text(recipe['name']),
                    subtitle: Text(
                      "${recipe['animal']} - ${recipe['ageRange']}\n"
                      "จำนวนสัตว์: ${recipe['animalCount']} ตัว\n"
                      "มื้ออาหารต่อวัน: ${recipe['meals']}\n"
                      "${recipe['foodAmount']} กรัม/วัน",
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteRecipe(index),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



