import 'package:flutter/material.dart';

import '/general/function.dart';
import '/view/decoration.dart';
import '../../../view_model/map_api_viewmodel.dart';



class CustomerInfosAccepted extends StatelessWidget {

  const CustomerInfosAccepted({
    Key? key,
    required this.mapAPIViewmodel,
    required this.onCancelled
  }) : super(key: key);

  final MapAPIViewmodel mapAPIViewmodel;
  final VoidCallback onCancelled;


  @override
  Widget build(BuildContext context) {
    return Container(

      width: 60,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(9)),
        color: Colors.amber.shade300,
        boxShadow: [BoxShadow(
          color: Colors.orange.shade300.withOpacity(0.5),
          spreadRadius: 0,
          blurRadius: 3,
          offset: const Offset(3, 3), // changes position of shadow
        )]
      ),

      child: Column(children: [

        const SizedBox(height: 10),

        Text(mapAPIViewmodel.mapAPI.customerPhonenumber, style: const TextStyle(fontSize: 20)),

        const SizedBox(height: 10),

        PositionBox(
          icon: Icon(Icons.add_circle, color: Colors.deepOrange.shade900),
          height: 45,
          position: mapAPIViewmodel.mapAPI.pickupAddr
        ),

        PositionBox(
          icon: Icon(Icons.place, color: Colors.deepOrange.shade900),
          height: 45,
          position: mapAPIViewmodel.mapAPI.dropoffAddr
        ),

        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Expanded(child: PriceButton(text:"${mapAPIViewmodel.mapAPI.price} VNĐ")),
          Expanded(child: PriceButton(text: distanceToString(mapAPIViewmodel.mapAPI.distance))),
          Expanded(child: PriceButton(text: durationToString(mapAPIViewmodel.mapAPI.duration)))
        ]),

        BigButton(label: "Xong", onPressed: onCancelled, bold: true)

      ])
        
    );
  }
}