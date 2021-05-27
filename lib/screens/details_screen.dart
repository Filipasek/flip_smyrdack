import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/fullscreen_image_screen.dart';
import 'package:flip_smyrdack/screens/main_screen.dart';
import 'package:flip_smyrdack/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';

class DetailsScreen extends StatefulWidget {
  String name, startTime, endTime, difficulty, description;
  Timestamp date;
  int index,
      transportCost,
      otherCosts,
      elevation,
      elev_differences,
      trip_length,
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
    this.elev_differences,
    this.elevation,
    this.trip_length,
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
  Widget build(BuildContext context) {
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
        body: SingleChildScrollView(
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
                          ? Text('Zrezygnowano z udziału')
                          : Text('Zrezygnuj z udziału'),
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
                          ? Text('Potwierdzono udział')
                          : Text('Potwiedź udział'),
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
                height: 260.0,
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
                    CreateColumnOfInfo(
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
                        convertBigToSmall(widget.elev_differences),
                        // '${widget.elev_differences.toString()} m',
                        'Ilość przewyższeń według map wyrażona w metrach'),
                    CreateColumnOfInfo(
                        'Wysokosć',
                        convertBigToSmall(widget.elevation),
                        // '${widget.elevation.toString()} m',
                        'Wysokość miejsca docelowego wyrażona w metrach'),
                    CreateColumnOfInfo(
                        'Długość',
                        convertBigToSmall(widget.trip_length),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 40.0),
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
            ],
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
