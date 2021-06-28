import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/add_trip.dart';
import 'package:flip_smyrdack/screens/eagers_screen.dart';
import 'package:flip_smyrdack/screens/fullscreen_image_screen.dart';
import 'package:flip_smyrdack/screens/main_screen.dart';
import 'package:flip_smyrdack/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'dart:io';
import 'package:intl/intl.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
// import 'package:flip_smyrdack/ad_helper.dart';

import 'package:native_admob_flutter/native_admob_flutter.dart';

class DetailsScreen extends StatefulWidget {
  String name, startTime, endTime, difficulty, description;
  Timestamp date;
  int index,
      transportCost,
      otherCosts,
      elevation,
      elevDifferences,
      tripLength,
      _id;
  List eagers;
  List<String> imageUrl; //TODO: list

  DetailsScreen(
    this.index,
    this.name,
    this.date,
    this.difficulty,
    this.transportCost,
    this.imageUrl,
    this.description,
    this.endTime,
    this.otherCosts,
    this.startTime,
    this.elevDifferences,
    this.elevation,
    this.tripLength,
    this.eagers,
    this._id,
  );

  // String name;
  // int index;
  // String difficulty;
  // int cost;
  // Timestamp date;
  // String imageUrl;
  // DetailsScreen(this.name, this.index, this.date, this.difficulty, this.cost,
  //     this.imageUrl);
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  // late BannerAd _ad;
  String get bannerAdUnitId {
    if (kDebugMode)
      return MobileAds.bannerAdTestUnitId;
    else
      return 'ca-app-pub-9537370157330943/9208297999';
  }

  // TODO: Add _isAdLoaded
  bool _isAdLoaded = false;
  Future<bool> _onWillPop() async {
    if (amJustAdded || amJustRemoved) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return MainScreen();
          },
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
    return false;
  }

  // String addUserToTrip = 'Potwierd'
  int? numberOfPeople;
  bool amJustAdded = false;
  bool amJustRemoved = false;
  bool loading = false;
  @override
  void initState() {
    super.initState();

    // TODO: Create a BannerAd instance
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
    // TODO: Dispose a BannerAd object
    // _ad.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb)
      FirebaseCrashlytics.instance
          .setCustomKey("screen name", 'Details Screen');

    numberOfPeople = amJustAdded
        ? widget.eagers.length + 1
        : amJustRemoved
            ? widget.eagers.length - 1
            : widget.eagers.length;
    int indexx = 0;
    List<String> imgList = widget.imageUrl;
    final List<Widget> imageSliders = imgList.map(
      (item) {
        indexx++;
        return Container(
          child: Container(
            margin: EdgeInsets.all(5.0),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                            return FullscreenImageScreen(item);
                          },
                        ),
                      ),
                      child: Hero(
                        tag: item,
                        child: Image.network(item,
                            fit: BoxFit.cover, width: 1200.0, height: 600.0),
                      ),
                    ),
                    // Positioned( //TODO: dodać opis miejsca na zdjęciu
                    //   bottom: 0.0,
                    //   left: 0.0,
                    //   right: 0.0,
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       gradient: LinearGradient(
                    //         colors: [
                    //           Color.fromARGB(200, 0, 0, 0),
                    //           Color.fromARGB(0, 0, 0, 0)
                    //         ],
                    //         begin: Alignment.bottomCenter,
                    //         end: Alignment.topCenter,
                    //       ),
                    //     ),
                    //     padding: EdgeInsets.symmetric(
                    //         vertical: 10.0, horizontal: 20.0),
                    //     child: Text(
                    //       'Widok ze szczytu',
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 20.0,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                )),
          ),
        );
      },
    ).toList();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          // leading: IconButton(
          //   icon: Icon(Icons.arrow_back_rounded),
          //   onPressed: amJustAdded
          //       ? () => Navigator.of(context).pushReplacement(
          //             MaterialPageRoute<void>(
          //               builder: (BuildContext context) {
          //                 return MainScreen();
          //               },
          //             ),
          //           )
          //       : () => Navigator.of(context).pop(),
          // ),
          elevation: 0.0,
          title: Text(widget.name),
        ),
        floatingActionButton: !kIsWeb &&
                (Provider.of<UserData>(context, listen: false).isAdmin ?? false)
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddTripScreen(
                        name: widget.name,
                        difficulty: widget.difficulty,
                        transportCost: widget.transportCost,
                        tripLength: widget.tripLength,
                        elevation: widget.elevation,
                        elevDifferences: widget.elevDifferences,
                        tripId: widget._id.toString(),
                        otherCosts: widget.otherCosts,
                        description: widget.description,
                        date: widget.date.toDate(),
                        image: widget.imageUrl,
                        startTime: stringToTimeOfDay(widget.startTime),
                        endTime: stringToTimeOfDay(widget.endTime),
                      ),
                    ),
                  );
                },
                child: Icon(Icons.mode_edit_rounded),
              )
            // ? Container(
            //     padding: EdgeInsets.all(5.0),
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.circular(100.0),
            //       child: PopupMenuButton(
            //         enableFeedback: true,
            //         tooltip: 'Opcje',
            //         color: Theme.of(context).primaryColor,
            //         itemBuilder: (context) {
            //           List<PopupMenuEntry> list = [
            //             PopupMenuItem(
            //               child: Text(
            //                 "Ukryj wyprawę dla wszystkich",
            //                 style: TextStyle(
            //                   color:
            //                       Theme.of(context).textTheme.headline5!.color,
            //                 ),
            //               ),
            //               value: 3,
            //               enabled: true,
            //             ),
            //           ];
            //           return list;
            //         },
            //         onSelected: (value) async {
            //           switch (value) {
            //             case 0:
            //               break;
            //             default:
            //           }
            //         },
            //         child: Container(
            //           height: 60.0,
            //           width: 60.0,
            //           color: Theme.of(context).accentColor,
            //           child: Icon(
            //             Icons.settings_rounded,
            //             color: Colors.white,
            //           ),
            //         ),
            //       ),
            //     ),
            //   )
            : null,
        body: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 700.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Container(
                  //   child: Hero(
                  //     tag: 'image${widget.index}',
                  //     child: ClipRRect(
                  //       borderRadius:
                  //           BorderRadius.vertical(bottom: Radius.circular(15.0)),
                  //       child: Image(
                  //         image: NetworkImage(widget.imageUrl),
                  //         // height: 300.0,
                  //         width: double.infinity,
                  //         fit: BoxFit.fitWidth,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  CarouselSlider(
                    options: CarouselOptions(
                      aspectRatio: 2.0,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      initialPage: 0,
                      autoPlay: true,
                      height: 220.0,
                      // reverse: true,
                      viewportFraction: 0.99,
                    ),
                    items: imageSliders,
                  ),
                  widget.eagers.contains(
                          Provider.of<UserData>(context, listen: false)
                              .currentUserId)
                      ? FlatButton.icon(
                          onPressed: loading || amJustRemoved
                              ? null
                              : () async {
                                  setState(() {
                                    loading = true;
                                  });
                                  await AuthService.removeUserFromTrip(
                                          widget._id.toString(),
                                          Provider.of<UserData>(context,
                                                  listen: false)
                                              .currentUserId!)
                                      .then((value) {
                                    if (value) {
                                      setState(() {
                                        amJustRemoved = true;
                                        loading = false;
                                      });
                                    }
                                  }).onError((error, stackTrace) {
                                    setState(() {
                                      loading = false;
                                    });
                                  });
                                },
                          label: amJustRemoved
                              ? Text(
                                  'Zrezygnowano z udziału',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .color,
                                  ),
                                )
                              : Text(
                                  'Zrezygnuj z udziału',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .color,
                                  ),
                                ),
                          icon: amJustRemoved
                              ? Icon(Icons.close,
                                  color: Color.fromRGBO(249, 101, 116, 1))
                              : Icon(Icons.remove_done_rounded,
                                  color: Color.fromRGBO(249, 101, 116, 1)),
                        )
                      : FlatButton.icon(
                          onPressed: loading || amJustAdded
                              ? null
                              : () async {
                                  setState(() {
                                    loading = true;
                                  });
                                  await AuthService.addUserToTrip(
                                          widget._id.toString(),
                                          Provider.of<UserData>(context,
                                                  listen: false)
                                              .currentUserId!)
                                      .then((value) {
                                    if (value) {
                                      setState(() {
                                        amJustAdded = true;
                                        loading = false;
                                      });
                                    }
                                  }).onError((error, stackTrace) {
                                    setState(() {
                                      loading = false;
                                    });
                                  });
                                },
                          label: amJustAdded
                              ? Text(
                                  'Potwierdzono udział',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .color,
                                  ),
                                )
                              : Text(
                                  'Potwiedź udział',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .color,
                                  ),
                                ),
                          icon: amJustAdded
                              ? Icon(Icons.done_rounded,
                                  color: Color.fromRGBO(132, 207, 150, 1))
                              : Icon(Icons.add_task_rounded,
                                  color: Color.fromRGBO(132, 207, 150, 1)),
                        ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: SingleInfoTextBold('Informacje podstawowe:'),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.width > 700
                        ? 500
                        : ((((MediaQuery.of(context).size.width) / 6) * 4) +
                            4),
                    child: GridView.count(
                      childAspectRatio: 2,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      primary: true,
                      mainAxisSpacing: 0.0,
                      children: [
                        CreateColumnOfInfo('Trudność', widget.difficulty,
                            'Szacowana trudność wycieczki'),
                        CreateColumnOfInfo(
                            "Kiedy",
                            "${DateFormat('dd MMM', 'pl_PL').format(widget.date.toDate().toLocal())}",
                            'Data dzienna rozpoczęcia wycieczki'),
                        Provider.of<UserData>(context, listen: false)
                                    .isVerified ??
                                false
                            ? FlatButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EagersListScreen(
                                        widget.eagers,
                                        widget._id.toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: CreateColumnOfInfo(
                                    'Chętnych',
                                    numOfPersonToString(numberOfPeople!),
                                    'Ilość osób, które potwierdziły swój udział w aplikacji'),
                              )
                            : CreateColumnOfInfo(
                                'Chętnych',
                                numOfPersonToString(numberOfPeople!),
                                'Ilość osób, które potwierdziły swój udział w aplikacji'),
                        CreateColumnOfInfo('Wyjście', widget.startTime,
                            'Planowany czas startu (na miejscu)'),
                        CreateColumnOfInfo(
                            'Czas', 'trochę', 'Szacowany czas chodzenia'),
                        CreateColumnOfInfo('Zejście', widget.endTime,
                            'Planowany czas końca trasy'),
                        CreateColumnOfInfo(
                            'Przewyższeń',
                            convertBigToSmall(widget.elevDifferences),
                            // '${widget.elev_differences.toString()} m',
                            'Ilość przewyższeń według map wyrażona w metrach'),
                        CreateColumnOfInfo(
                            'Wysokosć',
                            convertBigToSmall(widget.elevation),
                            // '${widget.elevation.toString()} m',
                            'Wysokość miejsca docelowego wyrażona w metrach'),
                        CreateColumnOfInfo(
                            'Długość',
                            convertBigToSmall(widget.tripLength),
                            // '${widget.trip_length.toString()} m',
                            'Długość trasy według map wyrażona w metrach'),
                        CreateColumnOfInfo(
                            'Transport',
                            '${widget.transportCost} zł',
                            'Koszty transportu samochodem lub innymi środkami transportu'),
                        SizedBox(),
                        CreateColumnOfInfo('Inne', '${widget.otherCosts} zł',
                            'Inne koszty typu wstęp do parku'),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: SingleInfoTextBold('Opis:'),
                  ),
                  // Container(
                  //   child: AdWidget(ad: _ad),
                  //   width: _ad.size.width.toDouble(),
                  //   height: 72.0,
                  //   alignment: Alignment.center,
                  // ),
                  !kIsWeb &&
                          (Provider.of<UserData>(context, listen: false)
                                  .showAds ??
                              false)
                      ? BannerAd(
                          unitId: bannerAdUnitId,
                          size: BannerSize.ADAPTIVE,
                          loading: Center(child: Text('Ładowanie reklamy')),
                          // loading: LinearProgressIndicator(),
                          error: Center(
                              child: Text('Brak reklamy. Na nasz koszt :)')),
                        )
                      : SizedBox(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 40.0),
                    child: Text(
                      widget.description,
                      // maxLines: 2,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.headline5!.color,
                        // fontWeight: FontWeight.bold,

                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 50.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CreateColumnOfInfo extends StatelessWidget {
  String topText;
  String bottomText;
  String tooltipText;
  CreateColumnOfInfo(this.topText, this.bottomText, this.tooltipText);
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipText,
      padding: EdgeInsets.all(10.0),
      showDuration: Duration(seconds: 4),
      child: Column(
        children: [
          SingleInfoText(topText),
          SingleInfoTextBold(bottomText),
        ],
      ),
    );
  }
}

class SingleInfoText extends StatelessWidget {
  String text;
  SingleInfoText(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.0,
      child: Text(
        text,
        // overflow: TextOverflow.ellipsis,
        maxLines: 2,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).textTheme.headline5!.color,
          // fontWeight: FontWeight.bold,

          fontSize: 16.0,
        ),
      ),
    );
  }
}

String convertBigToSmall(int meters) {
  if (meters >= 3000) return '${((meters / 100).round()) / 10} km';
  return '$meters m';
}

TimeOfDay stringToTimeOfDay(String s) {
  int hour = int.parse(s.split(":")[0]);
  int minute = int.parse(s.split(":")[1]);
  return TimeOfDay(hour: hour, minute: minute);
}

String numOfPersonToString(int persons) {
  int lastDigit =
      int.parse(persons.toString().substring(persons.toString().length - 1));
  if (persons == 1)
    return '1 osoba';
  else if (persons <= 21 && persons >= 5)
    return '$persons osób';
  else if ((persons <= 4 && persons > 1) || (lastDigit >= 2 && lastDigit < 5))
    return '$persons osoby';
  return '$persons osób';
}

class SingleInfoTextBold extends StatelessWidget {
  String text;
  SingleInfoTextBold(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      // overflow: TextOverflow.ellipsis,
      maxLines: 2,
      // textAlign: TextAlign.left,
      style: TextStyle(
        color: Theme.of(context).textTheme.headline5!.color,
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
      ),
    );
  }
}

// class MySeparator extends StatelessWidget {
//   final double height;
//   final Color color;

//   const MySeparator({this.height = 1, this.color = Colors.grey});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2.0),
//       child: LayoutBuilder(
//         builder: (BuildContext context, BoxConstraints constraints) {
//           final boxWidth = constraints.constrainWidth();
//           final dashWidth = 15.0;
//           final dashHeight = height;
//           final dashCount = (boxWidth / (2 * dashWidth)).floor();
//           return Flex(
//             children: List.generate(dashCount, (_) {
//               return SizedBox(
//                 width: dashWidth,
//                 height: dashHeight,
//                 child: DecoratedBox(
//                   decoration: BoxDecoration(color: color),
//                 ),
//               );
//             }),
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             direction: Axis.horizontal,
//           );
//         },
//       ),
//     );
//   }
// }
