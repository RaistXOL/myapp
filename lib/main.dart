import 'dart:convert';
//import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:tcp_socket_connection/tcp_socket_connection.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'socket demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.title}) : super();
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Instantiating the class with the Ip and the PortNumber
  TcpSocketConnection socketConnection =
      TcpSocketConnection("app.farmaconsult.it", 1045);

  String message = "";
  bool lLogin = false;

  @override
  void initState() {
    super.initState();
  }

  String ExtractJSON(String input) {
    return message = message.substring(message.indexOf(":") + 2);
  }

  //receiving and sending back a custom message
  void messageReceived(String msg) {
    setState(() {
      message = msg;
    });

    if (message.contains("dns")) {
      message = ExtractJSON(message);

      final oPayload = jsonDecode(message) as List;

      final oDns = oPayload.where((element) => element.contains("dns"));

      String cDns = oDns.last[1];
      socketConnection.disconnect();

      socketConnection = TcpSocketConnection("app.farmaconsult.it", 1045);

      ConnectAndSendMessage("","login: [\'a\',\'aa\',\'Farmaconsult 1.9.7.0\',\'unknown\',\'EDA52\',\'Android 11\', \'218.01.16.0219\', \'null\']", socketConnection);
    }
    
    else if(message.contains("login")) {

    }

    //socketConnection.disconnect();
  }

  //starting the connection and listening to the socket asynchronously
  void ConnectAndSendMessage(String cHostname, String msg, TcpSocketConnection tcpSocket) async {
    tcpSocket.enableConsolePrint(
        true); //use this to see in the console what's happening
    if (await tcpSocket.canConnect(5000, attempts: 3)) {
      //check if it's possible to connect to the endpoint
      await tcpSocket.connect(5000, messageReceived, attempts: 3);
      tcpSocket.sendMessage(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Card(
          child: Column(
            children: [
              Text("output >> " + message),
              ElevatedButton(
                onPressed: () {
                  ConnectAndSendMessage("app.farmaconsult.it",
                      'dns: [\'0116699410\',\'iOS 17.5.1\',\'Farmacia 2.1.1.1\']',socketConnection); // Respond to button press
                },
                child: Text('dns'),
              ),
              ElevatedButton(
                onPressed: () {
                  ConnectAndSendMessage("","", socketConnection); // Respond to button press
                },
                child: Text('login'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
