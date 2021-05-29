import 'dart:async';

import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/home_screen.dart';
import 'package:flip_smyrdack/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class VerifyUserScreen extends StatefulWidget {
  @override
  _VerifyUserScreenState createState() => _VerifyUserScreenState();
}

class _VerifyUserScreenState extends State<VerifyUserScreen> {
  StreamController<ErrorAnimationType> errorController =
      StreamController<ErrorAnimationType>();
  TextEditingController textEditingController = TextEditingController();
  bool verifying = false, sentRequest = true;
  String currentText = "";
  String errorText = "";
  @override
  Widget build(BuildContext context) {
    sentRequest = Provider.of<UserData>(context, listen: false).isVerCodeSet!;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Weryfikacja konta'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 30.0),
          Container(
            width: double.infinity,
            child: Center(
              child: Text(
                "Tutaj wpisz kod otrzymany od administratora:",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: PinCodeTextField(
              hapticFeedbackTypes: HapticFeedbackTypes.heavy,
              length: 6,
              enabled: !verifying && sentRequest,

              obscureText: false,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10.0),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                disabledColor: Colors.black,
                inactiveColor: Colors.grey,
              ),
              animationDuration: Duration(milliseconds: 300),
              // backgroundColor: Colors.blue.shade50,
              enableActiveFill: true,
              errorAnimationController: errorController,
              controller: textEditingController,
              onCompleted: (value) {
                if (value.length == 6) {
                  setState(() {
                    verifying = true;
                  });
                  AuthService.verifyUser(
                          Provider.of<UserData>(context, listen: false)
                              .currentUserId!,
                          value)
                      .then((value) {
                    if (value)
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => HomeScreen()));
                  }).onError((error, stackTrace) {
                    setState(() {
                      errorText = error.toString();
                      verifying = false;
                    });
                  });
                }
              },
              onChanged: (value) {
                print(value);
                setState(() {
                  currentText = value;
                });
              },
              beforeTextPaste: (text) {
                print("Allowing to paste $text");
                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                //but you can show anything you want here, like your pop up saying wrong paste format or etc
                return true;
              },
              appContext: context,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                errorText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromRGBO(249, 101, 116, 1),
                ),
              ),
            ),
          ),
          sentRequest
              ? SizedBox()
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Wyślij prośbę o kod",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
          FlatButton.icon(
            onPressed: verifying || sentRequest
                ? null
                : () async {
                    setState(() {
                      sentRequest = true;
                    });
                    await AuthService.sendVerificationRequest(
                            Provider.of<UserData>(context, listen: false)
                                .currentUserId!,
                            Provider.of<UserData>(context, listen: false).name!)
                        .then((value) {
                      if (value)
                        setState(() {
                          errorText = "";
                          sentRequest = true;
                        });
                      Provider.of<UserData>(context, listen: false)
                          .isVerCodeSet = true;
                    }).onError((error, stackTrace) {
                      setState(() {
                        errorText = error.toString();
                        sentRequest = false;
                      });
                    });
                  },
            label: sentRequest
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Wysłano prośbę o kod, oczekuj\nkontaktu w wiadomości prywatnej',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  )
                : Text('Wyślij prośbę o kod'),
            icon: sentRequest
                ? Icon(Icons.done_rounded,
                    color: Color.fromRGBO(132, 207, 150, 1))
                : Icon(Icons.send, color: Color.fromRGBO(132, 207, 150, 1)),
          )
        ],
      ),
    );
  }
}
