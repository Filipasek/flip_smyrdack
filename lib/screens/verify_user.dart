import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/home_screen.dart';
import 'package:flip_smyrdack/services/auth_service.dart';
import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
// import 'package:flip_smyrdack/ad_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

class VerifyUserScreen extends StatefulWidget {
  @override
  _VerifyUserScreenState createState() => _VerifyUserScreenState();
}

class _VerifyUserScreenState extends State<VerifyUserScreen> {
  // late BannerAd _ad;
  String get bannerAdUnitId {
    if (kDebugMode)
      return MobileAds.bannerAdTestUnitId;
    else
      return 'ca-app-pub-9537370157330943/6785314634';
  }

  bool _isAdLoaded = false;
  StreamController<ErrorAnimationType> errorController =
      StreamController<ErrorAnimationType>();
  StreamController<ErrorAnimationType> errorController1 =
      StreamController<ErrorAnimationType>();
  StreamController<ErrorAnimationType> errorController2 =
      StreamController<ErrorAnimationType>();
  TextEditingController textEditingController = TextEditingController();
  TextEditingController textEditingController1 = TextEditingController();
  TextEditingController textEditingController2 = TextEditingController();
  bool verifying = false,
      sentRequest = true,
      phoneVerified = true,
      sent = false;
  String status = '';
  String? _verId;
  String currentText = "";
  String errorText = "";
  String? _phoneNumber, _smsCode;

  @override
  void initState() {
    super.initState();

    // _ad = BannerAd(
    //   adUnitId: AdHelper.bannerAdUnitId,
    //   size: AdSize.banner,
    //   request: AdRequest(),
    //   listener: BannerAdListener(
    //     onAdLoaded: (_) {
    //       setState(() {
    //         _isAdLoaded = true;
    //       });
    //     },
    //     onAdFailedToLoad: (ad, error) {
    //       // Releases an ad resource when it fails to load
    //       ad.dispose();

    //       print('Ad load failed (code=${error.code} message=${error.message})');
    //     },
    //   ),
    // );

    // // TODO: Load an ad
    // _ad.load();
  }

  @override
  void dispose() {
    // _ad.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sentRequest = Provider.of<UserData>(context, listen: false).isVerCodeSet!;
    // phoneVerified =
    //     Provider.of<UserData>(context, listen: false).isPhoneVerified!;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Weryfikacja konta'),
      ),
      body: phoneVerified
          ? Column(
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
                    keyboardType: TextInputType.visiblePassword,
                    hapticFeedbackTypes: HapticFeedbackTypes.heavy,
                    length: 6,
                    enabled: !verifying && sentRequest,
                    dialogConfig: DialogConfig(
                      dialogTitle: 'Wklej kod',
                      dialogContent: 'Czy chcesz wkleić tekst: ',
                      affirmativeText: 'Wklej',
                      negativeText: 'Anuluj',
                    ),
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
                      value = value.toUpperCase();
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
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => HomeScreen()));
                        }).onError((error, stackTrace) async {
                          await FirebaseCrashlytics.instance.recordError(
                              error, stackTrace,
                              reason: 'Verifying user', fatal: true);
                          setState(() {
                            errorText = error.toString();
                            verifying = false;
                          });
                        });
                      }
                    },
                    onChanged: (value) {
                      value = value.toUpperCase();
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
                Expanded(child: SizedBox()),
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
                SizedBox(height: 30.0),
                sentRequest
                    ? SizedBox()
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            "Kliknij poniżej, aby wysłać powiadomienie do adminów o chęci potwierdzenia swojego konta. Administrator skontaktuje się z Tobą w wiadomości prywatnej tak szybko, jak tylko zweryfikuje Twoją tożsamość. Możesz przyśpieszyć ten proces informując któregoś z nich o swoim zgłoszeniu.",
                            textAlign: TextAlign.justify,
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
                                  Provider.of<UserData>(context, listen: false)
                                      .name!)
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
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.headline5!.color,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        )
                      : Text(
                          'Wyślij prośbę o kod',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline5!.color,
                          ),
                        ),
                  icon: sentRequest
                      ? Icon(Icons.done_rounded,
                          color: Color.fromRGBO(132, 207, 150, 1))
                      : Icon(Icons.send,
                          color: Color.fromRGBO(132, 207, 150, 1)),
                ),
                // Container(
                //   child: AdWidget(ad: _ad),
                //   width: _ad.size.width.toDouble(),
                //   height: 72.0,
                //   alignment: Alignment.center,
                // ),
                Provider.of<UserData>(context, listen: false).showAds!
                    ? BannerAd(
                        unitId: bannerAdUnitId,
                        size: BannerSize.ADAPTIVE,
                        loading: Center(child: Text('Ładowanie reklamy')),
                        error: Center(
                            child: Text('Brak reklamy. Na nasz koszt :)')),
                      )
                    : SizedBox(),
              ],
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      "Tutaj podaj swój numer telefonu:",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: PinCodeTextField(
                    hapticFeedbackTypes: HapticFeedbackTypes.heavy,
                    length: 9,
                    enabled: !verifying && !sent,
                    dialogConfig: DialogConfig(
                      dialogTitle: 'Wklej numer',
                      dialogContent: 'Czy chcesz wkleić tekst: ',
                      affirmativeText: 'Wklej',
                      negativeText: 'Anuluj',
                    ),
                    obscureText: false,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10.0),
                      fieldHeight: 40,
                      fieldWidth: 30,
                      activeFillColor: Colors.white,
                      inactiveFillColor: Colors.white,
                      disabledColor: Colors.black,
                      inactiveColor: Colors.grey,
                    ),
                    keyboardType: TextInputType.number,
                    animationDuration: Duration(milliseconds: 300),
                    // backgroundColor: Colors.blue.shade50,
                    enableActiveFill: true,
                    errorAnimationController: errorController1,
                    controller: textEditingController1,
                    onCompleted: (value) async {
                      if (value.length == 9) {
                        setState(() {
                          // verifying = true;
                          _phoneNumber = value.trim();
                        });
                        await sendCodeToPhoneNumber('+48$value');
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
                SizedBox(height: 50.0),
                sent
                    ? Container(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            "Tutaj wpisz kod otrzymany SMS-em:",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : SizedBox(),
                SizedBox(height: 10.0),
                sent
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: PinCodeTextField(
                          hapticFeedbackTypes: HapticFeedbackTypes.heavy,
                          length: 6,
                          enabled: !verifying && sent,
                          dialogConfig: DialogConfig(
                            dialogTitle: 'Wklej kod',
                            dialogContent: 'Czy chcesz wkleić tekst: ',
                            affirmativeText: 'Wklej',
                            negativeText: 'Anuluj',
                          ),
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
                          keyboardType: TextInputType.number,
                          animationDuration: Duration(milliseconds: 300),
                          // backgroundColor: Colors.blue.shade50,
                          enableActiveFill: true,
                          errorAnimationController: errorController2,
                          controller: textEditingController2,
                          onCompleted: (value) async {
                            value = value.toUpperCase();
                            if (value.length == 6) {
                              setState(() {
                                sent = false;
                                _smsCode = value.trim();
                              });
                              await AuthService.signInWithPhoneNumber(
                                  value.trim(), _verId, _phoneNumber);
                              // await sendCodeToPhoneNumber('+48$value');
                            }
                          },

                          onChanged: (value) {
                            value = value.toUpperCase();
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
                      )
                    : SizedBox(),
                sent
                    ? Center(
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
                      )
                    : SizedBox(),
              ],
            ),
    );
  }

  Future<void> sendCodeToPhoneNumber(_phoneNumber) async {
    // String output;
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      setState(() {
        verifying = false;
      });
      print(
          'Inside _sendCodeToPhoneNumber: signInWithPhoneNumber auto succeeded: $phoneAuthCredential');
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      // setState(() {
      print(
          'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
      // });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      _verId = verificationId;
      setState(() {
        verifying = false;
        sent = true;
        // print('Code sent to $phone');
        status = "\nEnter the code sent to " + _phoneNumber;
      });
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      // phoneVerificationId = verificationId;
      print("time out");
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneNumber,
      timeout: const Duration(seconds: 10),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
    // if (phoneVerificationId != null) {
    //   _signInWithPhoneNumber("222222", phoneVerificationId);
    // }
  }
}
