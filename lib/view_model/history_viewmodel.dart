import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

import "/general/constant.dart";
import "/service/map_api_reader.dart";



class HistoryViewmodel with ChangeNotifier {

  List<dynamic> historyList = [];

  
  Future<void> load() async {
    final result = await MapAPIReader().toggleFunction((String token) async {
      return http.get(
        Uri.parse(Driver.getHistory),
        headers: { "Content-Type": "application/json; charset=UTF-8", "Authorization": "Bearer " + token }
      );
    }, "Get History of driver.");

    if (result["status"]) {
      historyList = result["body"];
    }
    notifyListeners();
  }
}






