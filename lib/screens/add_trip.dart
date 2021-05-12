import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddTripScreen extends StatefulWidget {
  @override
  _AddTripScreenState createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  bool error = false;
  String errorText = '';
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTimeStart = TimeOfDay.now();
  TimeOfDay selectedTimeEnd = TimeOfDay.now();

  List<File>? _image;
  final picker = ImagePicker();

  final df = DateFormat('dd.MM.yyyy');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dodaj wyprawę'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Container(
                margin: EdgeInsets.only(bottom: 20.0, top: 20.0),
                child: Theme(
                  data: ThemeData(
                    primaryColor: Theme.of(context).accentColor,
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                          'Nazwa miejsca', 'text', 3, _setError, _removeError),
                      SizedBox(height: 5.0),
                      CustomTextField('Koszt transportu (w zł)', 'int', 1,
                          _setError, _removeError),
                      SizedBox(height: 5.0),
                      CustomTextField('Inne koszty (w zł)', 'int', 1, _setError,
                          _removeError),
                      SizedBox(height: 5.0),
                      CustomTextField(
                          'Opis', 'text', 50, _setError, _removeError),
                      SizedBox(height: 5.0),
                      Container(
                        margin: EdgeInsets.only(
                            bottom: 5.0, left: 15.0, right: 15.0),
                        width: double.infinity,
                        height: 50.0,
                        child: RaisedButton(
                          color: Color.fromRGBO(255, 182, 185, 1),
                          onPressed: () => _selectDate(context),
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
                          color: Color.fromRGBO(255, 182, 185, 1),
                          onPressed: () => _selectTimeStart(context),
                          child: Text(
                            "Rozpoczęcie: ${selectedTimeStart.hour}:${selectedTimeStart.minute}",
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
                          color: Color.fromRGBO(255, 182, 185, 1),
                          onPressed: () => _selectTimeEnd(context),
                          child: Text(
                            "Zakończenie: ${selectedTimeEnd.hour}:${selectedTimeEnd.minute}",
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
            _image == null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                          width: 3.0,
                          color: Color.fromRGBO(255, 182, 185, 1),
                        ),
                      ),
                      width: double.infinity,
                      height: 100.0,
                      margin:
                          EdgeInsets.only(bottom: 5.0, left: 15.0, right: 15.0),
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11.0),
                        ),
                        splashColor:
                            Color.fromRGBO(255, 182, 185, 1).withOpacity(0.6),
                        highlightColor:
                            Color.fromRGBO(255, 182, 185, 1).withOpacity(0.2),
                        onPressed: getImage,
                        child: Center(
                          child: Icon(
                            Icons.add_a_photo_outlined,
                            color: Color.fromRGBO(255, 182, 185, 1),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
                    margin:
                        EdgeInsets.only(bottom: 5.0, left: 15.0, right: 15.0),
                    width: double.infinity,
                    height: 200.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _image!.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0)
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                  width: 3.0,
                                  color: Color.fromRGBO(255, 182, 185, 1),
                                ),
                              ),
                              width: 150.0,
                              // height: 100.0,
                              margin: EdgeInsets.only(right: 15.0),
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11.0),
                                ),
                                splashColor: Color.fromRGBO(255, 182, 185, 1)
                                    .withOpacity(0.6),
                                highlightColor: Color.fromRGBO(255, 182, 185, 1)
                                    .withOpacity(0.2),
                                onPressed: getImage,
                                child: Center(
                                  child: Icon(
                                    Icons.add_a_photo_outlined,
                                    color: Color.fromRGBO(255, 182, 185, 1),
                                  ),
                                ),
                              ),
                            ),
                          );
                        return Container(
                          margin: EdgeInsets.only(right: 15.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Image.file(
                              _image![index - 1],
                              height: 100.0,
                              fit: BoxFit.fitHeight,
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
                  bottom: 5.0, left: 15.0, right: 15.0, top: 20.0),
              width: double.infinity,
              height: 50.0,
              child: RaisedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_image!.length < 3) {
                      setState(() {
                        error = true;
                        errorText = 'Wybierz minimum 3 zdjęcia';
                      });
                    } else {
                      setState(() {
                        error = false;
                        errorText = '';
                      });
                      _formKey.currentState!.save();
                    }

                    // _saveApiKey(_apiKey.trim());
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (_) => MyApp()),
                    // );
                  }
                },
                color: Color.fromRGBO(0, 191, 166, 1),
                child: Text(
                  "Dodaj wyprawę",
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
    );
  }

  _selectTimeStart(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTimeStart,
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
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

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

  _setError(String newErrorText) {
    setState(() {
      error = true;
      errorText = newErrorText;
    });
  }

  _removeError() {
    setState(() {
      error = false;
      errorText = '';
    });
  }
}

class CustomTextField extends StatefulWidget {
  String nazwa;
  String type;
  int length;
  Function setError;
  Function removeError;
  CustomTextField(
      this.nazwa, this.type, this.length, this.setError, this.removeError);
  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.0, left: 15.0, right: 15.0),
      child: TextFormField(
        // inputFormatters: [
        //   widget.type == 'int' ? UpperCaseTextFormatter(),
        // ],
        keyboardType:
            widget.type == 'int' ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: Theme.of(context).textTheme.headline5!.color),
        showCursor: true,
        autocorrect: true,
        autofocus: false,
        cursorColor: Theme.of(context).accentColor,
        decoration: InputDecoration(
          labelStyle: TextStyle(
            color: Theme.of(context).textTheme.headline5!.color,
          ),
          labelText: widget.nazwa,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              // color: Theme.of(context).textTheme.headline5!.color,
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
          }
          return null;
        },
        onChanged: (text) {
          if (text.length < widget.length)
            widget.setError(
                '\"${widget.nazwa}\" musi mieć minimum ${widget.length} znaki');
        },
      ),
    );
  }
}

// class NumbersTextFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     return TextEditingValue(
//       text: newValue.text?.toUpperCase(),
//       selection: newValue.selection,
//     );
//   }
// }