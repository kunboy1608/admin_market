import 'dart:io';

import 'package:admin_market/entity/banner.dart';
import 'package:admin_market/home/banner/banner_editor.dart';
import 'package:admin_market/util/const.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart' hide Banner;

class BannerCard extends StatelessWidget {
  const BannerCard({super.key, required this.banner});

  final Banner banner;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => BannerEditor(
                banner: banner,
              ),
            ));
      },
      child: Hero(
          tag: 'thumbnail${banner.id}',
          child: ClipRRect(
              borderRadius: BorderRadius.circular(defRadius),
              child: banner.actuallyLink != null &&
                      banner.actuallyLink!.isNotEmpty
                  ? FadeInImage(
                      placeholder: const AssetImage('assets/img/loading.gif'),
                      image: FileImage(File(banner.actuallyLink!)),
                    )
                  : const Icon(
                      Icons.add_rounded,
                      size: 160.0,
                    ))),
    );
  }
}
