import 'package:flutter/material.dart';

import '/view/decoration.dart';
import '../../view_model/account_viewmodel.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({
    Key? key,
    required this.onLogIn,
    required this.switchToRegister,
    required this.accountViewmodel
  }) : super(key: key);
  final VoidCallback onLogIn;
  final VoidCallback switchToRegister;
  final AccountViewmodel accountViewmodel;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}



class _LoginScreenState extends State<LoginScreen> {

  TextEditingController phonenumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool hasPhoneNumber = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.amber.shade700,

      body: SafeArea( child: Stack( children: [

         // --------------------- Trang trí ---------------------
        Positioned(top: -120, left: 120, right: 120, child: circle(Colors.amber.shade600, 120)),
        Positioned(top: 30, left: 90, right: 90, child: Text(
          "Đăng nhập tài khoản", textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, color: Colors.brown.shade900, fontWeight: FontWeight.bold)
        )),

        Positioned(top: 150, left: -45, right: -30, child: Container(
          width: 710, height: 760,
          decoration: BoxDecoration(
            color: Colors.yellow.shade600,
            borderRadius: const BorderRadius.all(Radius.circular(180))
          ),
        )),

        Positioned(top: 160, left: -35, right: -20, child: Container(
          width: 700, height: 600,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(180))
          ),
        )),

        // --------------------- Trường nhập ---------------------
        Positioned(top: 180, left: 15, right: 60, child: Column( children: [
          RegularTextField(controller: phonenumberController, labelText: "Số điện thoại", obscureText: false),
          RegularTextField(controller: passwordController,    labelText: "Mật khẩu",      obscureText: true),
        ])),
        
        // --------------------- Nút đăng nhập ---------------------
        Positioned(top: 540, left: 90, right: 120, child: BigButton(
          bold: true,
          label: "Đăng nhập ngay!",
          onPressed: () async => logIn()
        )),
      ]))
    );

  }



  Future logIn() async {
    final status = await widget.accountViewmodel.updateLogIn(phonenumberController.text, passwordController.text);
    if (status) {
      widget.onLogIn();
    }
    else {
      if (context.mounted) {
        warningModal(context, "Email hoặc mật khẩu không hợp lệ.");
      }
    }
  }
}



