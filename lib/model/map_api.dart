import "dart:developer" as developer;

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';



class MapAPI {

  String tripId = "";

  String pickupAddr = "";
  LatLng pickupLatLng = const LatLng(10.0, 100.0);

  String dropoffAddr = "";
  LatLng dropoffLatLng = const LatLng(10.0, 100.0);

  LatLng driverLatLng = const LatLng(10.0, 100.0);

  int price = 0;      // Đơn vị: VNĐ
  int distance = 0;   // Đơn vị: mét
  int duration = 0;   // Đơn vị: giây

  Polyline s2ePolylines = Polyline(points: []);
  Polyline d2sPolylines = Polyline(points: []);

  String customerId = "";
  String customerName = "";
  String customerPhonenumber = "";



  Future saveTrip() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    try {
      await sp.setString("map_API_tripId", tripId);

      await sp.setString("map_API_pickupAddress",  pickupAddr);
      await sp.setDouble("map_API_pickupLat",      pickupLatLng.latitude);
      await sp.setDouble("map_API_pickupLng",      pickupLatLng.longitude);
      await sp.setString("map_API_dropoffAddress", dropoffAddr);
      await sp.setDouble("map_API_dropoffLat",     dropoffLatLng.latitude);
      await sp.setDouble("map_API_dropoffLng",     dropoffLatLng.longitude);

      await sp.setInt("map_API_price", price);
      await sp.setInt("map_API_distance", distance);
      await sp.setInt("map_API_duration", duration);

      await sp.setString("map_API_customerId",          customerId);
      await sp.setString("map_API_customerName",        customerName);
      await sp.setString("map_API_customerPhonenumber", customerPhonenumber);
    }
    catch (e) { developer.log("Map error `saveDriver()`:\nException: $e"); }
  }



  // * Lấy dữ liệu
  Future loadTrip() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    try {
      tripId        = sp.getString("map_API_tripId")!;
      pickupAddr    = sp.getString("map_API_pickupAddress")!;
      pickupLatLng  = LatLng(sp.getDouble("map_API_pickupLat")!, sp.getDouble("map_API_pickupLng")!);
      dropoffAddr   = sp.getString("map_API_dropoffAddress")!;
      dropoffLatLng = LatLng(sp.getDouble("map_API_dropoffLat")!, sp.getDouble("map_API_dropoffLng")!);
      
      price    = sp.getInt("map_API_price")!;
      distance = sp.getInt("map_API_distance")!;
      duration = sp.getInt("map_API_duration")!;

      customerId = sp.getString("map_API_customerId")!;
      customerName = sp.getString("map_API_customerName")!;
      customerPhonenumber = sp.getString("map_API_customerPhonenumber")!;
    }
    catch (e) { developer.log("Throw error `loadCustomer()`. Exception: $e"); }
  }




  // * Xoá
  Future<bool> clearData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    try {
      await sp.setString("map_API_tripId", "");

      await sp.setString("map_API_pickupAddress",  "");
      await sp.setDouble("map_API_pickupLat",      0.0);
      await sp.setDouble("map_API_pickupLng",      0.0);
      await sp.setString("map_API_dropoffAddress", "");
      await sp.setDouble("map_API_dropoffLat",     0.0);
      await sp.setDouble("map_API_dropoffLng",     0.0);

      await sp.setInt("map_API_price", 0);
      await sp.setInt("map_API_distance", 0);
      await sp.setInt("map_API_duration", 0);

      await sp.setString("map_API_customerId",          "");
      await sp.setString("map_API_customerName",        "");
      await sp.setString("map_API_customerPhonenumber", "");
      return Future.value(true);
    }
    catch (e) {
      developer.log("Map error `saveData()`:\nException: $e");
      return Future.value(false);
    }
  }

}


