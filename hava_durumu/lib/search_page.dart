import 'dart:convert';

import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var myController = TextEditingController();

  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("HATA..!"),
            content: Text("Yanlış Şehir İsmi Girdiniz.!"),
            actions: [
              FlatButton(
                child: Text("Kapat"),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/search.jpg'),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            children: <Widget>[
              TextField(
                controller: myController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Şehir Giriniz",
                ),
                style: TextStyle(fontSize: 30),
                textAlign: TextAlign.center,
              ),
              FlatButton(
                  onPressed: () async {
                    var response = await http.get(
                        "https://www.metaweather.com/api/location/search/?query=${myController.text}");
                    jsonDecode(response.body).isEmpty
                        ? _showDialog() //print("null")
                        : Navigator.pop(context, myController.text);
                    //print(myController.text);
                  },
                  child: Text("Şehri Seçiniz!"))
            ],
          ),
        ),
      ),
    );
  }
}
