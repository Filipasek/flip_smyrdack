import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/add_transport_screen.dart';
import 'package:flip_smyrdack/screens/trip_clients_screen.dart';
import 'package:flip_smyrdack/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';

class TransportScreen extends StatefulWidget {
  int _tripId;
  TransportScreen(this._tripId);

  @override
  _TransportScreenState createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  String joinedTransportId = '';
  String masterOfId = '';
  String startingPlace = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Transport'),
        actions: [
          joinedTransportId == '' && masterOfId == ''
              ? IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              AddTransportScreen(widget._tripId.toString())),
                    );
                  },
                  icon: Icon(
                    Icons.add_circle_rounded,
                    size: 28.0,
                    color: Theme.of(context).textTheme.headline5!.color,
                  ),
                )
              : SizedBox(),
        ],
      ),
      body: Container(
        constraints: BoxConstraints(maxWidth: 700.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('trips')
              .doc(widget._tripId.toString())
              .collection('transport')
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List data = snapshot.data.docs;
              for (int i = 0; i < data.length; i++) {
                if (data[i]['userId'] ==
                    Provider.of<UserData>(context, listen: false)
                        .currentUserId) {
                  masterOfId = data[i]['userId'];
                } else {
                  masterOfId = '';
                }
                for (int j = 0; j < data[i]['clients'].length; j++) {
                  if (data[i]['clients'][j]['id'] ==
                      Provider.of<UserData>(context, listen: false)
                          .currentUserId) {
                    joinedTransportId = data[i]['userId'];
                    startingPlace = data[i]['clients'][j]['where'];
                    j = data[i]['clients'].length;
                    i = data.length;
                    break;
                  } else {
                    joinedTransportId = '';
                  }
                }
              }

              WidgetsBinding.instance!.addPostFrameCallback((_) {
                if (mounted) setState(() {});
              });
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  dynamic info = data[index];

                  return TransportTile(info, index, widget._tripId.toString(),
                      joinedTransportId, masterOfId, startingPlace);
                },
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

Widget mySeparator() {
  return Column(
    children: List.generate(
      300 ~/ 19,
      (index) => Expanded(
        child: Container(
          color: index % 2 == 0 ? Colors.white : Colors.transparent,
          width: 0.5,
        ),
      ),
    ),
  );
}

class MySeparator extends StatelessWidget {
  final double height;
  final Color color;

  const MySeparator({
    this.height = 1,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxHeight = constraints.constrainHeight();
        final dashWidth = 10.0;
        final dashHeight = height;
        final dashCount = (boxHeight / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashHeight,
              height: dashWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.vertical,
        );
      },
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

class TransportTile extends StatefulWidget {
  dynamic info;
  int index;
  String tripId;
  String joinedTransportId;
  String masterOfId;
  String startingPlace;
  TransportTile(this.info, this.index, this.tripId, this.joinedTransportId,
      this.masterOfId, this.startingPlace);

  @override
  State<TransportTile> createState() => _TransportTileState();
}

class _TransportTileState extends State<TransportTile> {
  List<Color> accentColors = [
    Color.fromRGBO(122, 87, 209, 1),
    Color.fromRGBO(36, 136, 136, 1),
    Color.fromRGBO(245, 78, 162, 1),
    Color.fromRGBO(91, 231, 196, 1),
  ];

  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(17.0),
      //   border: Border.all(
      //     color: Colors.transparent,
      //     width: 2.0
      //   ),
      // ),
      margin: EdgeInsets.fromLTRB(13.0, 10.0, 13.0, 10.0),
      height: 290.0,
      child: RaisedButton(
        disabledColor: Theme.of(context).accentColor,
        disabledTextColor: Colors.black,
        textColor: Theme.of(context).textTheme.headline5!.color,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: widget.info['userId'] == widget.joinedTransportId ||
                    widget.info['userId'] == widget.masterOfId
                ? Colors.red
                : Colors.transparent,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        // color: Theme.of(context).accentColor,
        color: accentColors[widget.index % accentColors.length],
        padding: EdgeInsets.all(5.0),
        onPressed: () {
          setState(() {
            isClicked = !isClicked;
          });
          // await _removePickedStation();

          // await Future.delayed(Duration(milliseconds: 200));
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (_) => MainScreen()),
          // );
        },
        child: Column(
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 10.0),
                child: Text(
                  widget.info['name'],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  // data.containsKey('realName')
                  //     ? data['realName']
                  //     : data['name'],
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              height: 204.0,
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedCrossFade(
                      crossFadeState: isClicked
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: Duration(milliseconds: 350),
                      firstChild: LeftPart(widget.info),
                      secondChild: LeftPartClicked(widget.info, isClicked,
                          widget.tripId, widget.joinedTransportId),
                    ),
                  ),
                  MySeparator(
                    color: Colors.white,
                  ),
                  Expanded(
                    child: AnimatedCrossFade(
                      crossFadeState: isClicked
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: Duration(milliseconds: 350),
                      firstChild: RightPart(widget.info),
                      secondChild: RightPartClicked(
                          widget.info,
                          isClicked,
                          widget.tripId,
                          widget.joinedTransportId,
                          widget.masterOfId,
                          widget.startingPlace),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RightPart extends StatelessWidget {
  dynamic info;
  RightPart(this.info);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 204.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CreateColumnOfInfo(
              'Wyjazd',
              'o ${info['leaving']}',
              'Godzina, o której ${info['name'].toString().split(" ")[0]} wyjeżdża od siebie',
            ),
            CreateColumnOfInfo(
              'Koszty',
              '${info['calculatePerPerson'] ? (info['costs'] / (info['clients'].length + 1)).round() : info['costs']} zł/os',
              'Koszt przejazdu na osobę (zależny od ilości osób jadących, aktualnie ${info['clients'].length} osoby + ty)',
            ),
            CreateColumnOfInfo(
              'Wszystkich',
              '${info['availableSeats']} miejsc',
              'Określa czy ${info['name'].toString().split(" ")[0]} jest w stanie podjechać i jak daleko',
            ),
          ],
        ),
      ),
    );
  }
}

class LeftPart extends StatelessWidget {
  dynamic info;
  LeftPart(this.info);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 204.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CreateColumnOfInfo(
              'Skąd',
              info['from'],
              'Miejsce, z którego ${info['name'].toString().split(" ")[0]} startuje',
            ),
            CreateColumnOfInfo(
              'Dojazd',
              info['pick-up'],
              'Określa czy ${info['name'].toString().split(" ")[0]} jest w stanie podjechać i jak daleko',
            ),
            CreateColumnOfInfo(
              'Zajęte',
              '${info['clients'].length} miejsca',
              'Określa czy ${info['name'].toString().split(" ")[0]} jest w stanie podjechać i jak daleko',
            ),
          ],
        ),
      ),
    );
  }
}

class LeftPartClicked extends StatelessWidget {
  dynamic info;
  bool isClicked;
  String tripId;
  String joinedTransportId;

  LeftPartClicked(
      this.info, this.isClicked, this.tripId, this.joinedTransportId);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 204.0,
        width: double.infinity,
        child: FlatButton(
          onPressed: !isClicked
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TripClientsScreen(
                          info['clients'], tripId, info['userId']),
                    ),
                  );
                },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.groups_rounded,
                size: 60.0,
                color: Colors.white,
              ),
              Text(
                'Kto jedzie?',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RightPartClicked extends StatefulWidget {
  dynamic info;
  bool isClicked;
  String tripId;
  String joinedTransportId;
  String masterOfId;
  String startingPlace;
  RightPartClicked(this.info, this.isClicked, this.tripId,
      this.joinedTransportId, this.masterOfId, this.startingPlace);

  @override
  State<RightPartClicked> createState() => _RightPartClickedState();
}

class _RightPartClickedState extends State<RightPartClicked> {
  final _formKey = GlobalKey<FormState>();
  String? joiningPlace;
  bool isMasterOfSomething = false;
  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < widget.info['clients'].length; i++)
      if (widget.info['clients'][i]['id'] ==
          Provider.of<UserData>(context, listen: false))
        isMasterOfSomething = true;
    return Center(
      child: Container(
        height: 204.0,
        width: double.infinity,
        child: FlatButton(
          onPressed: !widget.isClicked
              ? null
              : () async {
                  if (widget.joinedTransportId == '')
                    DialogBackground(
                      blur: 15.0,
                      color: Theme.of(context).primaryColor,
                      dialog: AlertDialog(
                        backgroundColor: Theme.of(context).primaryColor,
                        title: Text(
                          "Podaj miejsce",
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.headline5!.color),
                        ),
                        content: Container(
                          height: 250,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Wpisz tutaj miejsce, z którego mniej więcej chcesz zostać zabrany. Może to być miejscowość, bądź adres na niej. Ta informacja będzie widoczna tylko dla kierowcy.',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .color,
                                ),
                              ),
                              Form(
                                key: _formKey,
                                child: TextFormField(
                                  // enabled: !widget.loading,
                                  // keyboardType:
                                  //     widget.type == 'int' ? TextInputType.number : TextInputType.text,
                                  style: TextStyle(
                                    // color: Theme.of(context).textTheme.headline5!.color,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .color,
                                  ),
                                  showCursor: true,
                                  autocorrect: true,
                                  autofocus: false,
                                  // initialValue:
                                  //     widget.initialValue != null ? widget.initialValue.toString() : null,
                                  maxLines: null,
                                  cursorColor: Theme.of(context).accentColor,
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                      // color: Theme.of(context).textTheme.headline5!.color,
                                      // color: Theme.of(context).accentColor,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color,
                                    ),
                                    labelText: 'Miejsce',
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        // color: Theme.of(context).textTheme.headline5!.color!,
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .color!,
                                        width: 2.0,
                                      ),
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Wpisz dane";
                                    } else if (value.length < 3) {
                                      return 'Coś za krótkie';
                                    }
                                    return null;
                                  },
                                  onChanged: (text) {
                                    setState(() {
                                      joiningPlace = text;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                              child: Text(
                                "Dołącz",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .color,
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await AuthService.joinTransport(
                                          widget.tripId,
                                          Provider.of<UserData>(context,
                                                  listen: false)
                                              .currentUserId!,
                                          widget.info['userId'],
                                          joiningPlace!)
                                      .onError((error, stackTrace) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor:
                                            Color.fromRGBO(249, 101, 116, 1),
                                        behavior: SnackBarBehavior.floating,
                                        content: Text(
                                          error.toString(),
                                        ),
                                        duration: Duration(
                                            seconds:
                                                ((error.toString().length) / 6)
                                                        .round() +
                                                    5),
                                      ),
                                    );
                                    return true;
                                  });
                                  Navigator.pop(context);

                                  // if (mounted) setState(() {});
                                }
                                // print('---------- $newName');
                              }),
                        ],
                      ),
                    ).show(context);
                  else if (widget.joinedTransportId == widget.info['userId']) {
                    if (widget.info['userId'] ==
                        Provider.of<UserData>(context, listen: false)
                            .currentUserId) {
                      //zrezygnuj
                      await AuthService.removeTransport(
                        widget.tripId,
                        widget.info['userId'],
                      ).onError((error, stackTrace) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Color.fromRGBO(249, 101, 116, 1),
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              error.toString(),
                            ),
                            duration: Duration(
                                seconds:
                                    ((error.toString().length) / 6).round() +
                                        5),
                          ),
                        );
                        return true;
                      });
                    } else {
                      //opuść
                      await AuthService.removeUserFromTransport(
                        widget.tripId,
                        Provider.of<UserData>(context, listen: false)
                            .currentUserId!,
                        widget.info['userId'],
                        widget.startingPlace,
                      ).onError((error, stackTrace) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Color.fromRGBO(249, 101, 116, 1),
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              error.toString(),
                            ),
                            duration: Duration(
                                seconds:
                                    ((error.toString().length) / 6).round() +
                                        5),
                          ),
                        );
                        return true;
                      });
                    }
                  } else if (widget.masterOfId != '') {
                    //zrezygnuj i dołącz

                    await resignAndJoin(widget.tripId, widget.masterOfId,
                        context, widget.info['userId'], widget.startingPlace);
                  } else {
                    //zmień na ten tutaj
                    bool done = await AuthService.removeUserFromTransport(
                      widget.tripId,
                      Provider.of<UserData>(context, listen: false)
                          .currentUserId!,
                      widget.joinedTransportId,
                      widget.startingPlace,
                    ).then((value) {
                      return value;
                    }).onError((error, stackTrace) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Color.fromRGBO(249, 101, 116, 1),
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            error.toString(),
                          ),
                          duration: Duration(
                              seconds:
                                  ((error.toString().length) / 6).round() + 5),
                        ),
                      );
                      return false;
                    });
                    if (done)
                      await AuthService.joinTransport(
                        widget.tripId,
                        Provider.of<UserData>(context, listen: false)
                            .currentUserId!,
                        widget.info['userId'],
                        widget.startingPlace,
                      ).onError((error, stackTrace) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Color.fromRGBO(249, 101, 116, 1),
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              error.toString(),
                            ),
                            duration: Duration(
                                seconds:
                                    ((error.toString().length) / 6).round() +
                                        5),
                          ),
                        );
                        return true;
                      });
                  }
                },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.person_pin_circle_rounded,
                size: 60.0,
                color: Colors.white,
              ),
              Text(
                widget.joinedTransportId == ''
                    ? 'Wejdź na pokład'
                    : widget.joinedTransportId == widget.info['userId']
                        ? widget.info['userId'] ==
                                Provider.of<UserData>(context, listen: false)
                                    .currentUserId
                            ? "Zrezygnuj z bycia kierowcą"
                            : "Opuść pokład"
                        : widget.masterOfId != ''
                            ? "Zrezygnuj z bycia kierowcą i dołącz do tego typa tutaj"
                            : "Zmień pokład na ten tutaj",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> resignAndJoin(String tripId, String masterOfId,
    BuildContext context, String transportId, String startingPlace) async {
  bool done = await AuthService.removeTransport(
    tripId,
    masterOfId,
  ).then((value) {
    return value;
  }).onError((error, stackTrace) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color.fromRGBO(249, 101, 116, 1),
        behavior: SnackBarBehavior.floating,
        content: Text(
          error.toString(),
        ),
        duration:
            Duration(seconds: ((error.toString().length) / 6).round() + 5),
      ),
    );
    return false;
  });
  if (done)
    await AuthService.joinTransport(
      tripId,
      Provider.of<UserData>(context, listen: false).currentUserId!,
      transportId,
      startingPlace,
    ).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromRGBO(249, 101, 116, 1),
          behavior: SnackBarBehavior.floating,
          content: Text(
            error.toString(),
          ),
          duration:
              Duration(seconds: ((error.toString().length) / 6).round() + 5),
        ),
      );
      return true;
    });
}
