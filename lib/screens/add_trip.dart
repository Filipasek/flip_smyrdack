import 'dart:io';
import 'dart:math';

import 'package:badges/badges.dart';
import 'package:flip_smyrdack/models/user_data.dart';
import 'package:flip_smyrdack/screens/home_screen.dart';
import 'package:flip_smyrdack/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:flip_smyrdack/ad_helper.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AddTripScreen extends StatefulWidget {
  final String? tripId, name, description, difficulty;
  final int? transportCost, otherCosts, elevation, elevDifferences, tripLength;
  final TimeOfDay? startTime, endTime;
  final DateTime? date;
  final List<String>? image;

  AddTripScreen({
    this.tripId,
    this.name,
    this.description,
    this.difficulty,
    this.transportCost,
    this.otherCosts,
    this.elevation,
    this.elevDifferences,
    this.tripLength,
    this.startTime,
    this.endTime,
    this.date,
    this.image,
  });
  @override
  _AddTripScreenState createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  // late BannerAd _ad;
  String get bannerAdUnitId {
    if (kDebugMode)
      return MobileAds.bannerAdTestUnitId;
    else
      return 'ca-app-pub-9537370157330943/1364439321';
  }

  bool isSent = false, isDone = false, isThisUpdate = false;
  String? name, description, difficulty;
  String sendingErrorText = '';
  int? transportCost, otherCosts, elevation, elevDifferences, tripLength;
  TimeOfDay? startTime, endTime;
  DateTime? date;
  bool error = false, loading = false;
  String errorText = '';
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTimeStart = TimeOfDay.now();
  TimeOfDay selectedTimeEnd = TimeOfDay.now();

  List<File>? _image;
  final picker = ImagePicker();

  final df = DateFormat('dd.MM.yyyy');

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

  Future getFiles(List<String> images) async {
    // return true;
    if (images.length == 0 || !isThisUpdate) return false;
    List<File> imageFiles = [];
    for (int i = 0; i < images.length; i++) {
      File file = await urlToFile(images[i]);
      imageFiles = [
        ...imageFiles,
        ...[file]
      ];
    }
    return imageFiles;
    // return Future.delayed(Duration(seconds: 3));
  }

  Future<File> urlToFile(String imageUrl) async {
// generate random number.
    var rng = new Random();
// get temporary directory of device.
    Directory tempDir = await getTemporaryDirectory();
// get temporary path from temporary directory.
    String tempPath = tempDir.path;
// create a new file in temporary path with random file name.
    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
// call http.get method and pass imageUrl into it to get response.
    http.Response response = await http.get(Uri.parse(imageUrl));
// write bodyBytes received in response to file.
    await file.writeAsBytes(response.bodyBytes);
// now return the file which is created with random name in
// temporary directory and image bytes from response is written to // that file.
    return file;
  }

  @override
  Widget build(BuildContext context) {
    selectedDate = widget.date ?? selectedDate;
    selectedTimeStart = widget.startTime ?? selectedTimeStart;
    selectedTimeEnd = widget.endTime ?? selectedTimeEnd;
    isThisUpdate = widget.tripId != null;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(isThisUpdate ? 'Zaktualizuj wyprawę' : 'Dodaj wyprawę'),
        elevation: 0.0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10.0),
          child: loading
              ? LinearProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      Theme.of(context).accentColor),
                  backgroundColor:
                      Theme.of(context).accentColor.withOpacity(0.3),
                )
              : SizedBox(),
        ),
      ),
      body: isDone
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isSent
                      ? Icon(Icons.done_outline,
                          size: 70.0, color: Color.fromRGBO(132, 207, 150, 1))
                      : Icon(Icons.close,
                          size: 70.0, color: Color.fromRGBO(249, 101, 116, 1)),
                  SizedBox(height: 20.0),
                  isSent
                      ? Text(
                          isThisUpdate
                              ? 'Wyprawa została zaktualizowana'
                              : 'Wyprawa została wysłana',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.0,
                            color:
                                Theme.of(context).textTheme.headline5!.color!,
                          ),
                        )
                      : Text(
                          'Coś poszło nie tak',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.0,
                            color:
                                Theme.of(context).textTheme.headline5!.color!,
                          ),
                        ),
                  Text(
                    sendingErrorText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Theme.of(context).textTheme.headline5!.color!,
                    ),
                  ),
                ],
              ),
            )
          : FutureBuilder(
              future: getFiles(widget.image ?? []),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != false)
                    _image = snapshot.data as List<File>;
                  return SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Provider.of<UserData>(context, listen: false).showAds!
                            ? BannerAd(
                                unitId: bannerAdUnitId,
                                size: BannerSize.ADAPTIVE,
                                loading:
                                    Center(child: Text('Ładowanie reklamy')),
                                error: Center(
                                    child:
                                        Text('Brak reklamy. Na nasz koszt :)')),
                              )
                            : SizedBox(),
                        // Container(
                        //   // margin: EdgeInsets.symmetric(horizontal: 15.0),
                        //   child: AdWidget(ad: _ad),
                        //   // width: _ad.size.width.toDouble(),
                        //   height: _ad.size.height.toDouble(),
                        //   // height: 72.0,
                        //   width: double.infinity,
                        //   alignment: Alignment.center,
                        // ),
                        Form(
                          key: _formKey,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20.0, top: 0.0),
                            child: Column(
                              children: [
                                isThisUpdate
                                    ? Container(
                                      margin: EdgeInsets.only(bottom: 10.0),
                                      child: FlatButton.icon(
                                          onPressed: loading
                                              ? null
                                              : () async {
                                                  setState(() {
                                                    loading = true;
                                                  });
                                                  await AuthService.hideTrip(
                                                          widget.tripId
                                                              .toString())
                                                      .then((value) {
                                                    if (value) {
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  HomeScreen()));
                                                    }
                                                  }).onError((error, stackTrace) {
                                                    setState(() {
                                                      loading = false;
                                                    });
                                                  });
                                                },
                                                splashColor: Theme.of(context).accentColor,
                                          label: Text(
                                            'Zarchiwizuj wyprawę',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headline5!
                                                  .color,
                                            ),
                                          ),
                                          icon: Icon(
                                            Icons.archive_rounded,
                                            color: Color.fromRGBO(249, 101, 116, 1),
                                          ),
                                        ),
                                    )
                                    : SizedBox(height: 20.0),
                                CustomTextField(
                                  'Nazwa miejsca',
                                  'text',
                                  3,
                                  setName,
                                  loading,
                                  Theme.of(context).textTheme.headline5!.color!,
                                  widget.name,
                                ),
                                SizedBox(height: 5.0),

                                CustomTextField(
                                  'Wysokość (w metrach)',
                                  'int',
                                  3,
                                  setElevation,
                                  loading,
                                  Theme.of(context).textTheme.headline5!.color!,
                                  widget.elevation,
                                ),
                                SizedBox(height: 5.0),
                                CustomTextField(
                                  'Przewyższenia (w metrach)',
                                  'int',
                                  3,
                                  setElevationDifferences,
                                  loading,
                                  Theme.of(context).textTheme.headline5!.color!,
                                  widget.elevDifferences,
                                ),
                                SizedBox(height: 5.0),
                                CustomTextField(
                                  'Długość trasy (w metrach)',
                                  'int',
                                  3,
                                  setTripLength,
                                  loading,
                                  Theme.of(context).textTheme.headline5!.color!,
                                  widget.tripLength,
                                ),
                                SizedBox(height: 5.0),
                                CustomTextField(
                                  'Koszt transportu (w zł)',
                                  'int',
                                  1,
                                  settransportCost,
                                  loading,
                                  Theme.of(context).textTheme.headline5!.color!,
                                  widget.transportCost,
                                ),
                                SizedBox(height: 5.0),
                                CustomTextField(
                                  'Inne koszty (w zł)',
                                  'int',
                                  1,
                                  setOtherCosts,
                                  loading,
                                  Theme.of(context).textTheme.headline5!.color!,
                                  widget.otherCosts,
                                ),
                                SizedBox(height: 5.0),
                                // CustomTextField('Trudność', 'string', 3, setDifficulty),
                                Container(
                                  padding: EdgeInsets.only(
                                      bottom: 5.0, left: 15.0, right: 15.0),
                                  width: double.infinity,
                                  child: DropdownButtonFormField<String>(
                                    dropdownColor:
                                        Theme.of(context).primaryColor,
                                    focusColor: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .color!,
                                    decoration: InputDecoration(
                                      helperStyle: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .color!,
                                      ),
                                      hintStyle: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .color!,
                                      ),
                                      labelStyle: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .color!,
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
                                    value: widget.difficulty,
                                    hint: Text(
                                      'Wybierz trudność',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .color!,
                                      ),
                                    ),
                                    items: <String>[
                                      'Banalne',
                                      'Średnie',
                                      'Trudne',
                                      'O holibka...'
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
                                              difficulty = value!;
                                            });
                                          },
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return "Wpisz dane";
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                CustomTextField(
                                  'Opis',
                                  'text',
                                  50,
                                  setDescription,
                                  loading,
                                  Theme.of(context).textTheme.headline5!.color!,
                                  widget.description,
                                ),
                                SizedBox(height: 5.0),
                                Container(
                                  margin: EdgeInsets.only(
                                      bottom: 5.0, left: 15.0, right: 15.0),
                                  width: double.infinity,
                                  height: 50.0,
                                  child: RaisedButton(
                                    color: Theme.of(context).accentColor,
                                    onPressed: loading
                                        ? null
                                        : () => _selectDate(context),
                                    child: Text(
                                      "Data: " +
                                          "${df.format(selectedDate.toLocal())}"
                                              .split(' ')[0],
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      bottom: 5.0, left: 15.0, right: 15.0),
                                  width: double.infinity,
                                  height: 50.0,
                                  child: RaisedButton(
                                    color: Theme.of(context).accentColor,
                                    onPressed: loading
                                        ? null
                                        : () => _selectTimeStart(context),
                                    child: Text(
                                      "Rozpoczęcie: ${selectedTimeStart.hour < 10 ? '0${selectedTimeStart.hour}' : selectedTimeStart.hour}:${selectedTimeStart.minute < 10 ? '0${selectedTimeStart.minute}' : selectedTimeStart.minute}",
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      bottom: 5.0, left: 15.0, right: 15.0),
                                  width: double.infinity,
                                  height: 50.0,
                                  child: RaisedButton(
                                    color: Theme.of(context).accentColor,
                                    onPressed: loading
                                        ? null
                                        : () => _selectTimeEnd(context),
                                    child: Text(
                                      "Zakończenie: ${selectedTimeEnd.hour < 10 ? '0${selectedTimeEnd.hour}' : selectedTimeEnd.hour}:${selectedTimeEnd.minute < 10 ? '0${selectedTimeEnd.minute}' : selectedTimeEnd.minute}",
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
                        _image == null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    border: Border.all(
                                      width: 3.0,
                                      color: Theme.of(context).accentColor,
                                    ),
                                  ),
                                  width: double.infinity,
                                  height: 100.0,
                                  margin: EdgeInsets.only(
                                      bottom: 5.0, left: 15.0, right: 15.0),
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(11.0),
                                    ),
                                    splashColor: Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.6),
                                    highlightColor: Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.2),
                                    onPressed: loading ? null : getImage,
                                    child: Center(
                                      child: Icon(
                                        Icons.add_a_photo_outlined,
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                margin: EdgeInsets.only(
                                    bottom: 5.0, left: 15.0, right: 15.0),
                                width: double.infinity,
                                height: 210.0,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _image!.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == 0)
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              border: Border.all(
                                                width: 3.0,
                                                color: Theme.of(context)
                                                    .accentColor,
                                              ),
                                            ),
                                            width: 150.0,
                                            // height: 100.0,
                                            margin:
                                                EdgeInsets.only(right: 15.0),
                                            child: FlatButton(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(11.0),
                                              ),
                                              splashColor: Theme.of(context)
                                                  .accentColor
                                                  .withOpacity(0.6),
                                              highlightColor: Theme.of(context)
                                                  .accentColor
                                                  .withOpacity(0.2),
                                              onPressed:
                                                  loading ? null : getImage,
                                              child: Center(
                                                child: Icon(
                                                  Icons.add_a_photo_outlined,
                                                  color: Color.fromRGBO(
                                                      255, 182, 185, 1),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20.0, top: 10.0),
                                      child: Badge(
                                        padding: EdgeInsets.all(0.0),
                                        badgeColor:
                                            Theme.of(context).accentColor,
                                        // elevation: 0,
                                        badgeContent: Container(
                                          height: 30.0,
                                          width: 30.0,
                                          child: IconButton(
                                            padding: EdgeInsets.all(0),
                                            icon: Icon(Icons.highlight_remove,
                                                color: Colors.white),
                                            onPressed: loading
                                                ? null
                                                : () {
                                                    setState(() {
                                                      _image!
                                                          .removeAt(index - 1);
                                                    });
                                                  },
                                          ),
                                        ),
                                        child: Container(
                                          // margin: EdgeInsets.only(right: 15.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            child: Image.file(
                                              _image![index - 1],
                                              height: 200.0,
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                        error
                            ? Text(
                                errorText,
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              )
                            : SizedBox(),
                        Container(
                          margin: EdgeInsets.only(
                              bottom: 35.0, left: 15.0, right: 15.0, top: 20.0),
                          width: double.infinity,
                          height: 50.0,
                          child: RaisedButton(
                            onPressed: loading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      if (_image!.length < 3) {
                                        setState(() {
                                          error = true;
                                          errorText =
                                              'Wybierz minimum 3 zdjęcia (max 5)';
                                          loading = false;
                                          // errorText = _image![0].path.split(".").last;
                                        });
                                      } else if (_image!.length > 5) {
                                        setState(() {
                                          error = true;
                                          errorText =
                                              'Wybierz maksymalnie 5 zdjęć';
                                          loading = false;
                                          // errorText = _image![0].path.split(".").last;
                                        });
                                      } else {
                                        // _formKey.currentState!.save();

                                        setState(() {
                                          error = false;
                                          errorText = '';
                                          loading = true;
                                        });

                                        try {
                                          AuthService.addTripToDatabase(
                                            widget.tripId != null
                                                ? int.parse(widget.tripId!)
                                                : DateTime.now()
                                                    .microsecondsSinceEpoch,
                                            name ?? widget.name!,
                                            transportCost ??
                                                widget.transportCost!,
                                            otherCosts ?? widget.otherCosts!,
                                            description ?? widget.description!,
                                            selectedDate,
                                            selectedTimeStart,
                                            selectedTimeEnd,
                                            _image!,
                                            difficulty ?? widget.difficulty!,
                                            elevation ?? widget.elevation!,
                                            elevDifferences ??
                                                widget.elevDifferences!,
                                            tripLength ?? widget.tripLength!,
                                            Provider.of<UserData>(context,
                                                    listen: false)
                                                .isAdmin!,
                                          ).then((bool value) {
                                            setState(() {
                                              isSent = value;
                                              isDone = true;
                                              loading = false;
                                            });
                                          });
                                        } catch (e) {
                                          setState(() {
                                            isSent = false;
                                            isDone = true;
                                            loading = false;
                                            sendingErrorText = e.toString();
                                          });
                                        }
                                      }
                                    }
                                  },
                            color: Color.fromRGBO(0, 191, 166, 1),
                            child: Text(
                              isThisUpdate
                                  ? "Zaktualizuj wyprawę"
                                  : "Dodaj wyprawę",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }

  _selectTimeStart(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTimeStart,
      cancelText: "Anuluj",
      confirmText: "Wybierz",
      helpText: 'Wybierz planowaną godzinę rozpoczęcia',
    );
    if (picked != null && picked != selectedTimeStart)
      setState(() {
        selectedTimeStart = picked;
      });
  }

  _selectTimeEnd(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTimeEnd,
      cancelText: "Anuluj",
      confirmText: "Wybierz",
      helpText: 'Wybierz planowaną godzinę zakończenia',
    );
    if (picked != null && picked != selectedTimeEnd)
      setState(() {
        selectedTimeEnd = picked;
      });
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime.now(),
      lastDate: DateTime.utc(DateTime.now().year + 2),
      cancelText: "Anuluj",
      confirmText: "Wybierz",
      helpText: 'Wybierz datę wyprawy',
      // locale: Locale('pl', 'en'),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  void removeImage(int index) {}
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        // _image?[_image!.length] = File(pickedFile.path);
        if (_image == null)
          _image = [File(pickedFile.path)];
        else
          _image = [
            ...[File(pickedFile.path)],
            ..._image!
          ];
      } else {
        print('Nie wybrano obrazów.');
      }
    });
  }
  // int? transportCost, otherCosts;
  // TimeOfDay? startTime, endTime;
  // DateTime? date;

  void setName(dynamic data) {
    name = data;
  }

  void setElevation(dynamic data) {
    elevation = int.parse(data);
  }

  void setElevationDifferences(dynamic data) {
    elevDifferences = int.parse(data);
  }

  void setTripLength(dynamic data) {
    tripLength = int.parse(data);
  }

  void setDescription(dynamic data) {
    description = data;
  }

  void setDifficulty(dynamic data) {
    difficulty = data;
  }

  void settransportCost(dynamic data) {
    transportCost = int.parse(data);
  }

  void setOtherCosts(dynamic data) {
    otherCosts = int.parse(data);
  }

  void setStartTime(dynamic data) {
    startTime = data;
  }

  void setEndTime(dynamic data) {
    endTime = data;
  }

  void setDate(dynamic data) {
    date = data;
  }
  // void SettingVariables();
}

class CustomTextField extends StatefulWidget {
  final ValueChanged<dynamic> callback;
  String nazwa;
  String type;
  int length;
  bool loading;
  Color textColor;
  dynamic initialValue;
  CustomTextField(
    this.nazwa,
    this.type,
    this.length,
    this.callback,
    this.loading,
    this.textColor,
    this.initialValue,
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
        initialValue:
            widget.initialValue != null ? widget.initialValue.toString() : null,
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
