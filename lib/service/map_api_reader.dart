import "dart:convert";
import "dart:developer" as developer;

import "package:flutter/material.dart";
// import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:http/http.dart" as http;

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import "/service/account_reader.dart";
import "/model/map_api.dart";
import '/general/constant.dart';
import "/general/function.dart";



class MapAPIReader extends AccountReader {

  // * -------------------- Tìm đường giữa điểm bắt đầu và kết thúc --------------------
  // *
  // * RETURN: {
  // *   status: true,
  // *   polyline: <Polyline>,
  // *   distance: <int>,
  // *   duration: <int>
  // * }
  // *
  Future< Map<String, dynamic> > getPolyline(LatLng origin, LatLng destination, Color color) async {
    developer.log("Call OpenRouteService API. Run `getPolyline()`. Data: start = $origin, end = $destination");

    Map<String, dynamic> result = { "status": true };

    final response = await http.get(Uri.parse(
      "$web/$directionsService?api_key=$key&start=${latlngReverseToString(origin)}&end=${latlngReverseToString(destination)}"));

    try {
      if (response.statusCode == 200) {
        final jsonVal = json.decode(utf8.decode(response.bodyBytes));
        final readingJson = jsonVal["features"][0]["geometry"]["coordinates"];
        final readingList = readingJson.map<LatLng>((e) => LatLng(e[1], e[0]))
                                        .toList();
        
        result["polyline"] = Polyline(points: readingList, color: color, strokeWidth: 3);
      }
      else {
        developer.log("Failed HTTP when reading map at getPolyline(): ${response.statusCode}");
        result["status"] = false;
      }
      return result;
    }
    catch (e) { throw Exception("Failed code when getting polylines, at map_api_reader.dart. Error type: ${e.toString()}"); }
  }



  // Future< Map<String, dynamic> > getCustomer() async {
  //   return <String, dynamic>{
  //     "status": true,
  //     "body": {
  //       "customer_id": 5,
  //       "phone": "0123456789",
  //       "booking_time": "2023-08-31 10:20:42.314493",
  //       "car_type": 3,
  //       "pickup_address": "Lý Thái Tổ, Phường 2, Quận 3, Thành phố Hồ Chí Minh, 72406, Việt Nam",
  //       "dropoff_address": "Landmark 81, Ho Chi Minh City, HC, Vietnam",
  //       "pickup_latitude": 10.7662717,
  //       "pickup_longitude": 106.67907,
  //       "dropoff_latitude": 10.794943,
  //       "dropoff_longitude": 106.722041,
  //       "price": 47935,
  //       "distance": 7263,
  //       "duration": 1100
  //     }
  //   };
  // }




  // * Gửi lên HTTPS
  Future postTrip(int userId, String phonenumber, int vehicleID, MapAPI mapAPI) async {

    Map<String, dynamic> result = {
      "customer_id": userId,
      "phone": phonenumber,
      "car_type": vehicleID,

      "pickup_address": mapAPI.pickupAddr,
      "dropoff_address": mapAPI.dropoffAddr,

      "pickup_latitude": mapAPI.pickupLatLng.latitude,
      "pickup_longitude": mapAPI.pickupLatLng.longitude,
      "dropoff_latitude": mapAPI.dropoffLatLng.latitude,
      "dropoff_longitude": mapAPI.dropoffLatLng.longitude,

      "price": mapAPI.price,
      "distance": mapAPI.distance,
      "duration": mapAPI.duration,

      "driver_id": null,
      "status": null
    };

    developer.log("Trying to sent data: $result");
  }


  Future postDriverLatLng(LatLng value) async {
    Map<String, dynamic> result = {
      "latitude": value.latitude,
      "longitude": value.longitude
    };
    developer.log("Trying to sent data: $result");
  }
}