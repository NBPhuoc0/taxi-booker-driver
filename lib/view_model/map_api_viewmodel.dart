import 'dart:convert';
import "dart:developer" as developer;
import "package:http/http.dart" as http;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '/general/constant.dart';
import '/model/map_api.dart';
import '/service/map_api_reader.dart';



class MapAPIViewmodel with ChangeNotifier {

  MapAPI mapAPI = MapAPI();
  List< Map<String, dynamic> > customerList = [];



  void updateDriverLatLng(LatLng value) {
    mapAPI.driverLatLng = value;
    notifyListeners();
  }

  void updateCustomerList(List< Map<String, dynamic> > value) {
    print(value);
    customerList = value;
    notifyListeners();
  }

  // Start to end = S2E
  Future<void> updateS2EPolyline() async {
    final result = await MapAPIReader().getPolyline(mapAPI.pickupLatLng, mapAPI.dropoffLatLng, Colors.orange.shade700);
    if (result["status"]) { mapAPI.s2ePolylines = result["polyline"]; }
    else { developer.log("Unable to find the path between pickup and dropoff locations."); }
    notifyListeners();
  }

  // Driver to start = D2S
  Future<void> updateD2SPolyline() async {
    final result = await MapAPIReader().getPolyline(mapAPI.driverLatLng, mapAPI.pickupLatLng, Colors.brown.shade700);
    if (result["status"]) { mapAPI.d2sPolylines = result["polyline"]; }
    else { developer.log("Unable to find the path between driver and pickup locations."); }
    notifyListeners();
  }

  Future<void> updateCurrentCustomer(int currCustomer) async {
    final jsonVal = customerList[currCustomer];

    mapAPI.tripId = jsonVal["id"];

    mapAPI.customerId = jsonVal["user"];
    mapAPI.customerPhonenumber = jsonVal["user"];
    mapAPI.pickupAddr  = jsonVal["source_address"];
    mapAPI.dropoffAddr = jsonVal["destination_address"]; 
    mapAPI.pickupLatLng  = LatLng(jsonVal["destination_location"]["lat"], jsonVal["destination_location"]["lng"]);
    mapAPI.dropoffLatLng = LatLng(jsonVal["source_location"]["lat"], jsonVal["source_location"]["lng"]);

    mapAPI.price = jsonVal["orderTotal"];
    mapAPI.distance = jsonVal["distance"];
    mapAPI.duration = jsonVal["duration"];
    
    await updateS2EPolyline();
    await updateD2SPolyline();
    notifyListeners();
  }



  Future<void> sendSMS() async {
    final result = await MapAPIReader().toggleFunction((String token) async {
      return http.post(
        Uri.parse(Driver.sendSMS),
        headers: { "Content-Type": "application/json; charset=UTF-8", "Authorization": "Bearer " + token },
        body: { "phone": mapAPI.customerPhonenumber }
      );
    }, "Send SMS");

    if (result["status"]) {
      developer.log("Successfully send SMS to ${mapAPI.customerPhonenumber}.");
    }
  }


  Future<void> sendNotification() async {
    final result = await MapAPIReader().toggleFunction((String token) async {
      return http.post(
        Uri.parse(Driver.sendSMS),
        headers: { "Content-Type": "application/json; charset=UTF-8", "Authorization": "Bearer " + token },
        body: { "phone": mapAPI.customerId }
      );
    }, "Send Notification");

    if (result["status"]) {
      developer.log("Successfully send notification to ${mapAPI.customerId}.");
    }
  }



  Future<void> listenBooking() async {

  }


  Future<bool> sendBookingAccept() async {
    final result = await MapAPIReader().toggleFunction((String token) async {
      return http.patch(
        Uri.parse(Driver.sendBookingAccept),
        headers: { "Content-Type": "application/json; charset=UTF-8", "Authorization": "Bearer " + token },
        body: json.encode({ "order": mapAPI.tripId })
      );
    }, "Send Booking Acceptance");

    if (result["status"]) {
      developer.log("Successfully send accepted booking acceptance.");
      return Future.value(true);
    } else {
      developer.log(result["body"]??"");
      return Future.value(false);
    }
  }

  Future<void> patchDriverLatLng() async {
    final result = await MapAPIReader().toggleFunction((String token) async {
      return http.patch(
        Uri.parse(Driver.setLatLong),
        headers: { "Content-Type": "application/json; charset=UTF-8", "Authorization": "Bearer " + token },
        body: json.encode({ "lat": mapAPI.driverLatLng.latitude, "long": mapAPI.driverLatLng.longitude })
      );
    }, "Patch Driver Location");

    if (result["status"]) {
      developer.log("Successfully update latitude and longitude.");
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }

  Future<bool> completeTrip() async {
    final result = await MapAPIReader().toggleFunction((String token) async {
      developer.log(mapAPI.tripId);
      return http.patch(
        Uri.parse(Driver.setCompleted),
        headers: { "Content-Type": "application/json; charset=UTF-8", "Authorization": "Bearer " + token },
        body: json.encode({ "order": mapAPI.tripId })
      );
    }, "Complete trip");

    if (result["status"]) {
      developer.log("Successfully complete the trip to carry the customer.");
      return Future.value(true);
    } else {
      developer.log(result["body"]??"");
      return Future.value(false);
    }
  }

  Future<void> saveTrip() async {
    await mapAPI.saveTrip();
  }

  Future<void> loadTrip() async {
    await mapAPI.loadTrip();
    await updateS2EPolyline();
    await updateD2SPolyline();
    notifyListeners();
  }

  Future<void> clearTrip() async {
    await mapAPI.clearData();
    await mapAPI.loadTrip();
    mapAPI.s2ePolylines = Polyline(points: <LatLng>[]);
    mapAPI.d2sPolylines = Polyline(points: <LatLng>[]);
    notifyListeners();
  }
  
}


