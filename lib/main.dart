import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

Socket socket;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isError=false;
  bool isConnected = false;
  bool green=false;
  bool red = false;

  void buttonPress(int choice) {
    switch (choice) {
      case 1:
        socket.write("r");
        break;
      case 2:
        socket.write("g");
        break;
      case 3:
        socket.write("1");
        break;
      case 4:
        socket.write("0");
        break;
    }
  }

  void connect() async {
    try {
      socket = await Socket.connect("192.168.13.60", 80);
            setState(() {
              isError = false;
              isConnected = true;
            });

    } on SocketException {
      setState(() {
        print("err");
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        child: Scaffold(
          appBar: AppBar(
            title: Text("ESP8266"),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                    color: Colors.blue,
                    child: Text((!isConnected)
                        ? "Connect"
                        : "DisConnect"),
                    onPressed: () =>{
                      if(isConnected){
                          setState(() {
                            socket.destroy();
                            isConnected=false;
                              })
                          }
                        else{
                          connect()
                      }
                    }
                ),
                  if (isError)
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        "Cannot connect try again",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  if (isConnected)
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        "Connected",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Red"),
                    SizedBox(
                      width: 10,
                    ),
                    Switch(
                        value: red,
                        onChanged: (val) {
                          setState(() {
                            red=val;
                          });
                          if (val) {
                            buttonPress(1);
                          } else {
                            buttonPress(4);
                          }
                        })
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Green"),
                    SizedBox(
                      width: 10,
                    ),
                    Switch(
                        value: green,
                        onChanged: (val) {
                          setState(() {
                            green=val;
                          });
                          if (val) {
                            buttonPress(2);
                          } else {
                            buttonPress(3);
                          }
                        })
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
