import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class DetailsScreen extends StatefulWidget {
  int index;
  String name;
  String difficulty;
  String description;
  Timestamp date;
  int transportCost;
  int otherCosts;
  String startTime;
  String endTime;
  String imageUrl; //TODO: list

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: Container(
      //   height: 50.0,
      //   child: Center(child: Text('helo')),
      // ),
      appBar: AppBar(
        elevation: 0.0,
        title: Text(widget.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: Hero(
                tag: 'image${widget.index}',
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(15.0)),
                  child: Image(
                    image: NetworkImage(widget.imageUrl),
                    height: 300.0,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 25.0, 10.0, 5.0),
              child: Column(
                children: [
                  // SingleInfoText('Trudność: łatwa'),
                  SingleInfoTextBold('Informacje podstawowe:'),
                  Container(margin: EdgeInsets.only(bottom: 10.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CreateColumnOfInfo('Trudność', widget.difficulty),
                      CreateColumnOfInfo("Kiedy",
                          "${DateFormat('dd MMM').format(widget.date.toDate().toLocal())}"),
                      CreateColumnOfInfo('Chętnych', 'dużo osób'),
                    ],
                  ),
                  Container(margin: EdgeInsets.only(bottom: 10.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CreateColumnOfInfo('Wyjście', widget.startTime),
                      CreateColumnOfInfo('Czas', 'trochę'),
                      CreateColumnOfInfo('Zejście', widget.endTime),
                    ],
                  ),
                  Container(margin: EdgeInsets.only(bottom: 10.0)),
                  SingleInfoTextBold('Koszty:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // CreateColumnOfInfo('Wstęp', '7 zł'),
                      CreateColumnOfInfo(
                          'Transport', '${widget.transportCost} zł'),
                      CreateColumnOfInfo('Inne', '${widget.otherCosts} zł'),
                    ],
                  ),
                  SingleInfoTextBold('Opis:'),
                  Text(
                    widget.description,
                    // maxLines: 2,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.headline5!.color,
                      // fontWeight: FontWeight.bold,

                      fontSize: 16.0,
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

class CreateColumnOfInfo extends StatelessWidget {
  String topText;
  String bottomText;
  CreateColumnOfInfo(this.topText, this.bottomText);
  @override
  Widget build(BuildContext context) {
    return Container(
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
      // width: double.infinity/3,
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

class MySeparator extends StatelessWidget {
  final double height;
  final Color color;

  const MySeparator({this.height = 1, this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final boxWidth = constraints.constrainWidth();
          final dashWidth = 15.0;
          final dashHeight = height;
          final dashCount = (boxWidth / (2 * dashWidth)).floor();
          return Flex(
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color),
                ),
              );
            }),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
          );
        },
      ),
    );
  }
}
