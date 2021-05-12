import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailsScreen extends StatefulWidget {
  String name;
  int index;
  String difficulty;
  int cost;
  Timestamp date;
  String imageUrl;
  DetailsScreen(this.name, this.index, this.date, this.difficulty, this.cost,
      this.imageUrl);
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CreateColumnOfInfo('Trudność', 'łatwa'),
                      CreateColumnOfInfo('Kiedy', '13 maja'),
                      CreateColumnOfInfo('Chętnych', '5 osób'),
                    ],
                  ),
                  Container(margin: EdgeInsets.only(bottom: 5.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CreateColumnOfInfo('Wyjście', '13:38'),
                      CreateColumnOfInfo('Czas', '3h'),
                      CreateColumnOfInfo('Zejście', '17:00'),
                    ],
                  ),
                  Container(margin: EdgeInsets.only(bottom: 10.0)),
                  SingleInfoTextBold('Koszty:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // CreateColumnOfInfo('Wstęp', '7 zł'),
                      CreateColumnOfInfo('Transport', '15 zł'),
                      CreateColumnOfInfo('Inne', '2 zł'),
                    ],
                  ),
                   SingleInfoTextBold('Opis:'),
                   Text(
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce semper quam vitae lorem tempor, a condimentum felis pellentesque. Aenean cursus, augue et porttitor dapibus, lacus ex facilisis eros, vitae vestibulum lectus quam eu tortor. Sed pulvinar mi nibh. Suspendisse accumsan felis nec lorem luctus, a accumsan sapien venenatis. Nullam et lacinia lorem. Pellentesque consectetur lobortis leo, id porttitor libero tincidunt eu. Suspendisse et nibh sapien. In id risus est.',
        // overflow: TextOverflow.ellipsis,
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
