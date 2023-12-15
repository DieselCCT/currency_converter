import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request =
    "http://data.fixer.io/api/latest?access_key=4e7ce8422a9997ea5e2e88ef31101a9d";

void main() async {
  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          hintStyle: TextStyle(color: Colors.white),
        ),
      )));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();
  final poundController = TextEditingController();

  double real, dollar, pound;

  void _clearAll() {
    realController.text = "";
    dollarController.text = "";
    euroController.text = "";
    poundController.text = "";
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    dollarController.text = (euro / dollar).toStringAsFixed(2);
    realController.text = (euro * real).toStringAsFixed(2);
    poundController.text = (euro / pound).toStringAsFixed(2);
  }

  void _dollarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dollar = double.parse(text);
    euroController.text = (dollar * this.dollar).toStringAsFixed(2);
    realController.text = ((dollar * this.dollar) * real).toStringAsFixed(2);
    poundController.text = ((dollar * this.dollar) / pound).toStringAsFixed(2);
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    euroController.text = (real / this.real).toStringAsFixed(2);
    dollarController.text = ((real / this.real) * dollar).toStringAsFixed(2);
    poundController.text = ((real / this.real) * pound).toStringAsFixed(2);
  }

  void _poundChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double pound = double.parse(text);
    euroController.text = (pound * this.pound).toStringAsFixed(2);
    realController.text = ((pound * this.pound) * real).toStringAsFixed(2);
    dollarController.text = ((pound * this.pound) / dollar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Currency Converter"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: Text(
                "Processing data",
                style: TextStyle(color: Colors.amber, fontSize: 25.0),
                textAlign: TextAlign.center,
              ));
            default:
              if (snapshot.hasError) {
                return Center(
                    child: Text(
                  "Error on processing data..",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ));
              } else {
                dollar = snapshot.data["rates"]["USD"];
                real = snapshot.data["rates"]["BRL"];
                pound = snapshot.data["rates"]["GBP"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Divider(),
                        Icon(
                          Icons.monetization_on,
                          size: 100.0,
                          color: Colors.amber,
                        ),
                        Divider(),
                        buildTextField(
                            "Reais", "R\$ ", realController, _realChanged),
                        Divider(),
                        buildTextField(
                            "Euros", "€ ", euroController, _euroChanged),
                        Divider(),
                        buildTextField(
                            "Dollars", "\$ ", dollarController, _dollarChanged),
                        Divider(),
                        buildTextField(
                            "Pounds", "£ ", poundController, _poundChanged),
                      ]),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function function) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
      color: Colors.white,
      fontSize: 25.0,
    ),
    onChanged: function,
    keyboardType: TextInputType.number,
  );
}
