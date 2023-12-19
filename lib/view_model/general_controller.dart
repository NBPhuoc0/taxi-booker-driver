import "dart:developer" as developer;

import 'package:shared_preferences/shared_preferences.dart';




class DuringTrip {

  bool value = false;

  Future save(bool newValue) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.setBool("duringTrip", newValue);
    }
    catch (e) { developer.log("Unable to save during trip by Shared Preferences."); }
  }

  Future load() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    try {
      value = sp.getBool("duringTrip")!;
      return value;
    }
    catch (e) {
      developer.log("Unable to load during trip by Shared Preferences.");
      return null;
    }
  }
}



enum BookState {
  beforeSearch,         // Chưa đặt địa chỉ cần đến: Yêu cầu sệt
  afterSearch,          // Hiện thông tin đường đi giữa điểm bắt đầu và điểm kết thúc, giá tiền, quãng đường và thời gian
  beforeTaxiArrival,    // Chờ tài xế phản hồi
  duringTaxiArrival,    // Chờ tài xế trước và sau khi chở mình đi đến nơi cần đến
  afterTaxiArrival,     // Kết thúc
  scheduleTaxiArrival,  // Dành cho khách hàng VIP: đặt cuộc hẹn
  error
}


class BookStateController {
  
  BookState value = BookState.beforeSearch;

  Future save() async {
    developer.log("Save state ${getStateName()}");
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.setInt("bookState", value.index);
    }
    catch (e) { developer.log("Unable to save book state by Shared Preferences."); }
  }

  Future load() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    try {
      value = BookState.values[sp.getInt("bookState")!];
      return value;
    }
    catch (e) {
      developer.log("Unable to load book state by Shared Preferences.");
      return BookState.error;
    }
  }

  String getStateName() {
    switch (value) {
      case BookState.beforeSearch:        return "Before searching";
      case BookState.afterSearch:         return "After searching";
      case BookState.beforeTaxiArrival:   return "Before taxi arrival";
      case BookState.duringTaxiArrival:   return "During taxi arrival";
      case BookState.afterTaxiArrival:    return "After taxi arrival";
      case BookState.scheduleTaxiArrival: return "Scheduled taxi arrival";
      case BookState.error: return "[Error]";
      default: return "[???]";
    }
  }

}
