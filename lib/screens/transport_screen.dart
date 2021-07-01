import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransportScreen extends StatefulWidget {
  int _tripId;
  TransportScreen(this._tripId);

  @override
  _TransportScreenState createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Transport'),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.add)),
        ],
      ),
      body: Container(
        constraints: BoxConstraints(maxWidth: 700.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('trips')
              .doc(widget._tripId.toString())
              .collection('transport').snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List data = snapshot.data.docs;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  dynamic info = data[index];

                  List<Color> accentColors = [
                    Color.fromRGBO(122, 87, 209, 1),
                    Color.fromRGBO(36, 136, 136, 1),
                    Color.fromRGBO(245, 78, 162, 1),
                    Color.fromRGBO(91, 231, 196, 1),
                  ];
                  return Container(
                    margin: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    height: 290.0,
                    child: RaisedButton(
                      disabledColor: Theme.of(context).accentColor,
                      disabledTextColor: Colors.black,
                      textColor: Theme.of(context).textTheme.headline5!.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      // color: Theme.of(context).accentColor,
                      color: accentColors[index % accentColors.length],
                      padding: EdgeInsets.all(5.0),
                      onPressed: () async {
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
                              padding:
                                  EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 10.0),
                              child: Text(
                                info['name'],
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
                                    child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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
                                )),
                                Container(
                                  margin:
                                      EdgeInsets.only(bottom: 15.0, top: 10.0),
                                  child: MySeparator(
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                                Expanded(
                                    child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
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
