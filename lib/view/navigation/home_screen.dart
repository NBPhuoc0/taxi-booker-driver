import 'dart:async';
import "dart:developer" as developer;

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '/service/notification.dart';
import '/general/function.dart';
import '../../view_model/account_viewmodel.dart';
import '../../view_model/map_api_viewmodel.dart';
import '/view/decoration.dart';
import '/view/navigation/customer/customer_accepted_box.dart';
import '/view/navigation/customer/customer_info_box.dart';



enum DriverState { receiveState, tripState }



class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key, required this.accountViewmodel, required this.setLogoutAble }) : super(key: key);
  final AccountViewmodel accountViewmodel;
  final Function(bool) setLogoutAble;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {

  // Thông tin liên quan để hiển thị trên bản đồ
  bool allowedNavigation = false;
  Location location = Location();

  MapController mapController = MapController();

  bool driverPickingUp = false;

  final Noti noti = Noti();



  bool duringLoading = false;
  bool duringTrip = false;
  bool tracking = true;

  DriverState driverState = DriverState.receiveState;
  int customerLength = 0;
  int currCustomer = 0;

  late var listenLocation;

  // --------------------  Các hàm chính -------------------- 



  @override
  void initState() {
    super.initState();
    location.enableBackgroundMode(enable: true);
    noti.initialize();
  }


  @override
  void dispose() {
    super.dispose();
    postDriverTimer?.cancel();
    listenLocation.cancel();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.orange.shade100,

      body: ChangeNotifierProvider(

        create: (_) {
          MapAPIViewmodel mapAPIViewmodel = MapAPIViewmodel();

          // Lắng nghe định vị GPS
          listenLocation = location.onLocationChanged.listen((LocationData currLocation) {
            mapAPIViewmodel.updateDriverLatLng(LatLng(currLocation.latitude!, currLocation.longitude!));
            setState(() => allowedNavigation = true);
            if (tracking) setState(() => mapController.move(mapAPIViewmodel.mapAPI.driverLatLng, 16.5));
          });

          final ref = FirebaseDatabase.instance.ref();
          ref.child("bookingRequests").onValue.listen((event) {
            if (driverState == DriverState.receiveState) {
              Map<String, dynamic> result = { "status": false, "body": [] };
              Map mapCreated = Map.from(event.snapshot.value as Map<Object?, Object?>);
              int count = 0;
              for (String id in mapCreated.keys) {
                if (count >= 5) {
                  break;
                }
                if (mapCreated[id]["orderStatus"] == "PENDING") {
                  final oneResult = mapCreated[id].map((k, v) => MapEntry<String, dynamic>(k ?? "$k", v));
                  oneResult["id"] = id;
                  result["body"].add(oneResult.cast<String, dynamic>());
                  result["status"] = true;
                  count++;
                }
              }
              mapAPIViewmodel.updateCustomerList(result["body"].cast<Map<String, dynamic>>());
            }
          });

          return mapAPIViewmodel;
        },

        builder: (BuildContext context, Widget? child) => Stack(children: [
      
          // -------------------- Bản đồ --------------------
          Positioned(top: 0, bottom: 0, left: 0, right: 0, child: StreamBuilder(
      
            stream: _waitForServerObserver(context.read<MapAPIViewmodel>()),
          
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) => FlutterMap(
            mapController: mapController,
            options: MapOptions(center: context.watch<MapAPIViewmodel>().mapAPI.pickupLatLng, zoom: 16.5),
          
            nonRotatedChildren: [
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                  ),
                ],
              ),
            ],
          
      
            children: [
          
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
          
              PolylineLayer(
                polylines: [
                  context.watch<MapAPIViewmodel>().mapAPI.s2ePolylines,
                  if (!driverPickingUp) context.watch<MapAPIViewmodel>().mapAPI.d2sPolylines
                ],
              ),
          
              MarkerLayer(
                markers: [
                  if (allowedNavigation)
                    Marker( point: context.watch<MapAPIViewmodel>().mapAPI.driverLatLng, width: 20, height: 20, builder: (context) => const DriverPoint() ),
                  if ((driverState == DriverState.tripState) && !driverPickingUp)
                    Marker( point: context.watch<MapAPIViewmodel>().mapAPI.pickupLatLng, width: 20, height: 20, builder: (context) => const CustomerPoint() ),
                  if (driverState == DriverState.tripState)
                    Marker( point: context.watch<MapAPIViewmodel>().mapAPI.dropoffLatLng, width: 20, height: 20, builder: (context) => const DestiPoint() )
                ],
              )
          
            ],
          ),
          )),
      
      
      
      
          // -------------------- Tên người sử dụng --------------------
          Positioned(top: 15, left: 15, right: 15, child: Container(
            width: MediaQuery.of(context).size.width,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(9)),
              boxShadow: [BoxShadow(
                color: Colors.orange.shade300.withOpacity(0.5),
                spreadRadius: 0,
                blurRadius: 3,
                offset: const Offset(3, 3),
              )]
            ),

            child: Center(child: child)
          )),
      
          Positioned(top: 22, left: 30, child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Xin chào, ", style: TextStyle(fontSize: 20)),
              Text(widget.accountViewmodel.account.map["fullname"], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
            ]
          )),
      
          Positioned(top: 22, right: 30, child: Column(children: [
            const Text("Theo dõi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Switch(
              value: tracking,
              activeColor: Colors.amber.shade500,
              onChanged: (bool value) => setState(() => tracking = value),
            )
          ])),
      
      
      
          // -------------------- Thông tin khác --------------------

          if (driverState == DriverState.receiveState)
            Positioned(bottom: 15, left: 15, right: 15, child: 
            context.read<MapAPIViewmodel>().customerList.isEmpty ? Text("đang chờ") :
            CustomerInfos(
              mapAPIViewmodel: context.read<MapAPIViewmodel>(),
              currCustomer: currCustomer,
              onTapLeft: ()  { if (currCustomer > 0) setState(() => currCustomer--); },
              onTapRight: () { if (currCustomer < customerLength - 1) setState(() => currCustomer++); }, 
              onAccepted: () async {
                if (context.mounted) await context.read<MapAPIViewmodel>().updateCurrentCustomer(currCustomer);
                if (context.mounted) {
                  if (await context.read<MapAPIViewmodel>().sendBookingAccept()) {
                    if (context.mounted) await context.read<MapAPIViewmodel>().saveTrip();
                    await saveDuringTrip(true);
                    setState(() => driverState = DriverState.tripState);
                    widget.setLogoutAble(false);

                    if (context.mounted) {
                      if (context.read<MapAPIViewmodel>().mapAPI.customerId.isEmpty) {
                        context.read<MapAPIViewmodel>().sendSMS();
                      }
                      else {
                        context.read<MapAPIViewmodel>().sendNotification();
                      }
                    }
                  }
                }
              }
            ))
    
          else if (driverState == DriverState.tripState)
            Positioned(bottom: 15, left: 15, right: 15, child: CustomerInfosAccepted(
              mapAPIViewmodel: context.read<MapAPIViewmodel>(),
              onCancelled: () async => finishTrip(context.read<MapAPIViewmodel>())
            )),

          
          if (duringLoading) Positioned(top: 0, bottom: 0, left: 0, right: 0, child: Container(
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5))
          ))
        ]),
      )
    );
  }



  Future finishTrip(MapAPIViewmodel mapAPIViewmodel) async {
    setState(() { driverPickingUp = false;
                  driverState = DriverState.receiveState;
                  currCustomer = 0; });
    widget.setLogoutAble(true);
    noti.showBox("Chuyến đi thành công!", "Cảm ơn bạn đã chở khách hàng đến nơi.");
    await saveDuringTrip(false);
    mapAPIViewmodel.customerList.clear();
    await mapAPIViewmodel.clearTrip();
    await mapAPIViewmodel.completeTrip();
    setState(() => customerLength = mapAPIViewmodel.customerList.length);
  }



  Timer? postDriverTimer;
  bool loadPostDriverOnce = false;
  bool loadOnce = false;
  Stream<int> _waitForServerObserver(MapAPIViewmodel mapAPIViewmodel) async* {

    if (!loadOnce && widget.accountViewmodel.account.map["id"] != "") {

      loadOnce = true;
      setState(() => duringLoading = true);
      final currLocation = await location.getLocation();
      mapAPIViewmodel.updateDriverLatLng(LatLng(currLocation.latitude!, currLocation.longitude!));

      await loadDuringTrip();
      if (duringTrip) {
        await mapAPIViewmodel.loadTrip();
        setState(() { driverState = DriverState.tripState;
                      widget.setLogoutAble(false); });
      }
      else {
        setState(() => customerLength = mapAPIViewmodel.customerList.length);
      }
      setState(() => duringLoading = false);
    }



    if (!loadPostDriverOnce && allowedNavigation) {
      loadPostDriverOnce = true;
      postDriverTimer = Timer.periodic(const Duration(seconds: 10), (timerRunning) async {
        await mapAPIViewmodel.patchDriverLatLng();

        final currLocation = await location.getLocation();
        final newLocation = LatLng(currLocation.latitude!, currLocation.longitude!);
        double distance = getDescrateDistanceSquare(mapAPIViewmodel.mapAPI.driverLatLng, newLocation);
        if (distance > 10e-7) {
          // Cập nhật nếu đến đích
          if (driverPickingUp && (getDescrateDistanceSquare(mapAPIViewmodel.mapAPI.driverLatLng, mapAPIViewmodel.mapAPI.dropoffLatLng) < 20e-6)) {
            finishTrip(mapAPIViewmodel);
          }
        }
        if ((distance > 20e-6) && tracking) {
          setState(() => mapController.move(mapAPIViewmodel.mapAPI.driverLatLng, 16.5));
        }

        // Lắng nghe khách hàng
        if ((driverState == DriverState.tripState) && !driverPickingUp) {
          if (getDescrateDistanceSquare(mapAPIViewmodel.mapAPI.pickupLatLng, mapAPIViewmodel.mapAPI.driverLatLng) < 10e-7) {
            setState(() => driverPickingUp = true);
          }
        }
      });
    }
    
    
    yield 0;
  }



  Future<void> saveDuringTrip(bool value) async {
    developer.log("[Save during trip] Save $value");
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool("duringTrip", value);
    setState(() => duringTrip = value);
  }



  Future<void> loadDuringTrip() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool newDuringTrip = sp.getBool("duringTrip") ?? false;
    setState(() => duringTrip = newDuringTrip);
    developer.log("[Load during trip] Load $newDuringTrip");
  }

}


