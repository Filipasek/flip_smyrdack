import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_smyrdack/screens/fullscreen_image_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DetailsScreen extends StatefulWidget {
  String name, startTime, endTime, difficulty, description;
  Timestamp date;
  int index,
      transportCost,
      otherCosts,
      elevation,
      elev_differences,
      trip_length;
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
    return Scaffold(
      // bottomNavigationBar: Container(
      //   height: 50.0,
      //   child: Center(child: Text('helo')),
      // ),
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
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
                initialPage: 2,
                autoPlay: true,
                height: 220.0,
                // reverse: true,
                viewportFraction: 0.99,
              ),
              items: imageSliders,
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
                  CreateColumnOfInfo('Trudność', widget.difficulty),
                  CreateColumnOfInfo("Kiedy",
                      "${DateFormat('dd MMM', 'pl_PL').format(widget.date.toDate().toLocal())}"),
                  CreateColumnOfInfo('Chętnych', 'dużo osób'),
                  CreateColumnOfInfo('Wyjście', widget.startTime),
                  CreateColumnOfInfo('Czas', 'trochę'),
                  CreateColumnOfInfo('Zejście', widget.endTime),
                  CreateColumnOfInfo('Przewyższenia',
                      '${widget.elev_differences.toString()} m'),
                  CreateColumnOfInfo(
                      'Wysokosć', '${widget.elevation.toString()} m'),
                  CreateColumnOfInfo(
                      'Długość', '${widget.trip_length.toString()} m'),
                  CreateColumnOfInfo('Transport', '${widget.transportCost} zł'),
                  SizedBox(),
                  CreateColumnOfInfo('Inne', '${widget.otherCosts} zł'),
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
    );
  }
}

class CreateColumnOfInfo extends StatelessWidget {
  String topText;
  String bottomText;
  CreateColumnOfInfo(this.topText, this.bottomText);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleInfoText(topText),
        SingleInfoTextBold(bottomText),
      ],
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
