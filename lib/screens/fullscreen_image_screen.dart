import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
// import 'package:photo_view/src/utils/photo_view_hero_attributes.dart';
export '/services/photo_view_hero_attributes.dart';

class FullscreenImageScreen extends StatefulWidget {
  String fileTag;
  FullscreenImageScreen(this.fileTag);
  @override
  _FullscreenImageScreenState createState() => _FullscreenImageScreenState();
}

class _FullscreenImageScreenState extends State<FullscreenImageScreen> {
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb)
      FirebaseCrashlytics.instance.setCustomKey("screen name", 'Full Screen Image');
    return Container(
      child: GestureDetector(
        onTap: () =>
            Navigator.of(context).pop(),
        child: PhotoView(
          enableRotation: false,
          imageProvider: NetworkImage(widget.fileTag),
          heroAttributes: PhotoViewHeroAttributes(tag: widget.fileTag),
        ),
      ),
    );
  }
}
