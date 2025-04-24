import 'package:flutter/material.dart';
import 'package:flutter_application_1/Home.dart';
import 'package:flutter_application_1/times.dart';
import 'package:flutter_application_1/Calc.dart';
import 'package:flutter_application_1/History.dart';
//import 'package:flutter_application_1/manual.dart';

void main() => runApp(SmartFeeder());

class SmartFeeder extends StatelessWidget {
  const SmartFeeder({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF3F5AA6),
      ),
      home: DefaultTabController(
        length: 4,  // แท็บ
        //length: 5,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF3F5AA6),
            title: Text("Smart App", style: TextStyle(fontFamily: 'comicsans', fontSize: 24)),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          bottomNavigationBar: menu(),
          body: TabBarView(
            children: [
              Home(), // Home screen
              Calc(), // Calc screen
              Times(), // Times screen
              //Manual(), // Manual screen
              History(), // History screen
            ],
          ),
        ),
      ),
    );
  }

  Widget menu() {
    return Container(
      color: Color(0xFF3F5AA6),
      child: TabBar(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.all(5.0),
        indicatorColor: Colors.yellowAccent,
        tabs: [
          Tab(
            text: "Home",
            icon: Icon(Icons.house_rounded),
          ),
          Tab(
            text: "Calc",
            icon: Icon(Icons.calculate_rounded),
          ),
          Tab(
            text: "Time",
            icon: Icon(Icons.access_alarms_outlined),
          ),
          /*Tab(
            text: "Manual",
            icon: Icon(Icons.edit_note),
          ),*/
          Tab(
            text: "History",
            icon: Icon(Icons.history),
          ),
        ],
      ),
    );
  }
}
