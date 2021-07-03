import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddTransportScreen extends StatefulWidget {
  String _tripId;
  AddTransportScreen(this._tripId);

  @override
  _AddTransportScreenState createState() => _AddTransportScreenState();
}

class _AddTransportScreenState extends State<AddTransportScreen> {
  String? from, leaving, pickup;
  int? availableSeats, costs;
  bool loading = false;
  TimeOfDay? selectedTimeStart;
  String? dropdownValue;

  bool calculatePerPerson = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb)
      FirebaseCrashlytics.instance
          .setCustomKey("screen name", 'Add transport screen');
    return Scaffold(
      appBar: AppBar(
        title: Text('Zostań kierowcą'),
        elevation: 0.0,
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Container(
          height: double.infinity,
          constraints: BoxConstraints(maxWidth: 700.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  child: Form(
                    key: _formKey,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0, top: 0.0),
                      child: Column(
                        children: [
                          // Container(
                          //   margin: EdgeInsets.only(bottom: 10.0),
                          //   child: FlatButton.icon(
                          //     onPressed: loading
                          //         ? null
                          //         : () async {
                          //             // setState(() {
                          //             //   loading = true;
                          //             // });
                          //             // await AuthService
                          //             //         .hideTrip(widget
                          //             //             .tripId
                          //             //             .toString())
                          //             //     .then((value) {
                          //             //   if (value) {
                          //             //     Navigator.pushReplacement(
                          //             //         context,
                          //             //         MaterialPageRoute(
                          //             //             builder: (_) =>
                          //             //                 HomeScreen()));
                          //             //   }
                          //             // }).onError((error,
                          //             //         stackTrace) {
                          //             //   setState(() {
                          //             //     loading = false;
                          //             //   });
                          //             // });
                          //           },
                          //     splashColor: Theme.of(context).accentColor,
                          //     label: Text(
                          //       'Zarchiwizuj wyprawę',
                          //       style: TextStyle(
                          //         color: Theme.of(context).textTheme.headline5!.color,
                          //       ),
                          //     ),
                          //     icon: Icon(
                          //       Icons.archive_rounded,
                          //       color: Color.fromRGBO(249, 101, 116, 1),
                          //     ),
                          //   ),
                          // ),
                          SizedBox(height: 10.0),
                          CustomTextField(
                            'Skąd jedziesz',
                            'text',
                            3,
                            setFrom,
                            loading,
                            Theme.of(context).textTheme.headline5!.color!,
                          ),
                          SizedBox(height: 5.0),
                          // CustomTextField('Trudność', 'string', 3, setDifficulty),
                          Container(
                            padding: EdgeInsets.only(
                                bottom: 5.0, left: 15.0, right: 15.0),
                            width: double.infinity,
                            child: DropdownButtonFormField<String>(
                              dropdownColor: Theme.of(context).primaryColor,
                              focusColor:
                                  Theme.of(context).textTheme.headline5!.color!,
                              decoration: InputDecoration(
                                helperStyle: TextStyle(
                                  color:
                                      Theme.of(context).textTheme.headline5!.color!,
                                ),
                                hintStyle: TextStyle(
                                  color:
                                      Theme.of(context).textTheme.headline5!.color!,
                                ),
                                labelStyle: TextStyle(
                                  color:
                                      Theme.of(context).textTheme.headline5!.color!,
                                ),
                                // labelText: widget.nazwa,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .color!,
                                    width: 2.0,
                                  ),
                                ),
                                border: OutlineInputBorder(),
                              ),
                              value: dropdownValue,
                              hint: Text(
                                'Jesteś w stanie podjechać?',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).textTheme.headline5!.color!,
                                ),
                              ),
                              items: <String>[
                                'Tak',
                                'Tak, do x kilometrów',
                                'Tylko po drodze',
                                'Nie, tylko ode mnie',
                              ].map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color!,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: loading
                                  ? null
                                  : (String? value) {
                                      setState(() {
                                        dropdownValue = value;
                                        pickup = value;
                                      });
                                    },
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return "Wybierz z listy";
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 5.0),
                          dropdownValue == 'Tak, do x kilometrów'
                              ? CustomTextField(
                                  'Do ilu kilometrów podjedziesz?',
                                  'int',
                                  1,
                                  setPickUp,
                                  loading,
                                  Theme.of(context).textTheme.headline5!.color!,
                                )
                              : SizedBox(),
                          SizedBox(height: 5.0),
                          CustomTextField(
                            'Ile masz miejsc w aucie?',
                            'int',
                            1,
                            setAvailableSeats,
                            loading,
                            Theme.of(context).textTheme.headline5!.color!,
                          ),
                          SizedBox(height: 5.0),
                          Container(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Przeliczać koszty na osobę?',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .color,
                                  ),
                                ),
                                Switch(
                                  value: calculatePerPerson,
                                  onChanged: (value) {
                                    setState(() {
                                      calculatePerPerson = value;
                                    });
                                  },
                                  activeTrackColor: Color.fromRGBO(20, 161, 146, 1),
                                  activeColor: Color.fromRGBO(0, 191, 166, 1),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5.0),
                          CustomTextField(
                            !calculatePerPerson
                                ? 'Ile będzie kosztów na osobę?'
                                : 'Ile cała trasa będzie cię kosztować?',
                            'int',
                            1,
                            setCosts,
                            loading,
                            Theme.of(context).textTheme.headline5!.color!,
                          ),

                          SizedBox(height: 5.0),
                          Container(
                            margin: EdgeInsets.only(
                                bottom: 5.0, left: 15.0, right: 15.0),
                            width: double.infinity,
                            height: 50.0,
                            child: RaisedButton(
                              color: Theme.of(context).accentColor,
                              onPressed:
                                  loading ? null : () => _selectTimeStart(context),
                              child: Text(
                                selectedTimeStart == null
                                    ? 'Rozpoczęcie: nie wybrano'
                                    : 'Rozpoczęcie: ${selectedTimeStart!.hour < 10 ? '0${selectedTimeStart!.hour}' : selectedTimeStart!.hour}:${selectedTimeStart!.minute < 10 ? '0${selectedTimeStart!.minute}' : selectedTimeStart!.minute}',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 25.0),
                          Container(
                            margin: EdgeInsets.only(
                                bottom: 5.0, left: 15.0, right: 15.0),
                            width: double.infinity,
                            height: 50.0,
                            child: RaisedButton(
                              onPressed: loading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate() &&
                                          selectedTimeStart != null) {
                                        if (mounted)
                                          setState(() {
                                            loading = true;
                                          });
                                        // throw Exception();
                                        try {
                                          await AuthService.addTransport(
                                            widget._tripId,
                                            Provider.of<UserData>(context,
                                                    listen: false)
                                                .currentUserId!,
                                            availableSeats!,
                                            calculatePerPerson,
                                            costs!,
                                            from!,
                                            selectedTimeStart!,
                                            Provider.of<UserData>(context,
                                                    listen: false)
                                                .name!,
                                            pickup!,
                                          ).then((bool value) {
                                            print('---------${value.toString}');
                                            if (mounted)
                                              setState(() {
                                                loading = false;
                                              });
                                            Navigator.pop(context);
                                          }).onError((error, stackTrace) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                backgroundColor: Color.fromRGBO(
                                                    249, 101, 116, 1),
                                                behavior: SnackBarBehavior.floating,
                                                content: Text(
                                                  error.toString(),
                                                ),
                                                duration: Duration(
                                                    seconds:
                                                        ((error.toString().length) /
                                                                    6)
                                                                .round() +
                                                            5),
                                              ),
                                            );
                                            if (mounted)
                                              setState(() {
                                                loading = false;
                                              });
                                          });
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor:
                                                  Color.fromRGBO(249, 101, 116, 1),
                                              behavior: SnackBarBehavior.floating,
                                              content: Text(
                                                e.toString(),
                                              ),
                                              duration: Duration(
                                                  seconds:
                                                      ((e.toString().length) / 6)
                                                              .round() +
                                                          5),
                                            ),
                                          );
                                          if (mounted)
                                            setState(() {
                                              loading = false;
                                            });
                                        }
                                      }
                                    },
                              color: Color.fromRGBO(0, 191, 166, 1),
                              child: Text(
                                // isThisUpdate ? "Zaktualizuj wyprawę" : "Dodaj wyprawę",
                                'Dodaj siebie jako kierowcę',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _selectTimeStart(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      cancelText: "Anuluj",
      confirmText: "Wybierz",
      helpText: 'Wybierz planowaną godzinę rozpoczęcia',
    );
    if (picked != null)
      setState(() {
        selectedTimeStart = picked;
      });
  }

  void setFrom(dynamic data) {
    from = data;
  }

  void setAvailableSeats(dynamic data) {
    availableSeats = data == "" ? null : int.parse(data);
  }

  void setCosts(dynamic data) {
    costs = data == "" ? null : int.parse(data);
  }

  void setPickUp(dynamic data) {
    pickup = 'Tak, do ${data.toString()} km';
  }
  // void setFrom(dynamic data) {
  //   from = data;
  // }
  // void setFrom(dynamic data) {
  //   from = data;
  // }
}

class CustomTextField extends StatefulWidget {
  final ValueChanged<dynamic> callback;
  String nazwa;
  String type;
  int length;
  bool loading;
  Color textColor;
  CustomTextField(
    this.nazwa,
    this.type,
    this.length,
    this.callback,
    this.loading,
    this.textColor,
  );
  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.0, left: 15.0, right: 15.0),
      child: TextFormField(
        enabled: !widget.loading,
        keyboardType:
            widget.type == 'int' ? TextInputType.number : TextInputType.text,
        style: TextStyle(
          // color: Theme.of(context).textTheme.headline5!.color,
          color: widget.textColor,
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
            color: widget.textColor,
          ),
          labelText: widget.nazwa,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              // color: Theme.of(context).textTheme.headline5!.color!,
              color: widget.textColor,
              width: 2.0,
            ),
          ),
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Wpisz dane";
          } else if (value.length < widget.length) {
            return '\"${widget.nazwa}\" musi mieć minimum ${widget.length} znaki';
          } else if (widget.type == 'int' && int.parse(value) < 0) {
            return 'Kwota nie może być ujemna!';
          }
          return null;
        },
        onChanged: (text) {
          widget.callback(text);
        },
      ),
    );
  }
}
