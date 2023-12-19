class AccountModel {  // Singleton

  Map<String, dynamic> map = {
    "id": "",
    "phone": "",
    "fullname": "",
    "location":{
      "longitude": -1,
      "latitude": -1
    },
  };

  static final AccountModel _instance = AccountModel._internal();
  AccountModel._internal();

  factory AccountModel() {
    return _instance;
  }

  void clear() {
    map = {
    "id": "",
    "phone": "",
    "fullname": "",
    "location": {
        "longitude": -1,
        "latitude": -1
      },
    };
  }
}