import 'dart:io';

import 'package:admin_market/entity/banner.dart';
import 'package:admin_market/service/entity/banner_service.dart';
import 'package:admin_market/service/google/firestorage_service.dart';
import 'package:admin_market/util/const.dart';
import 'package:admin_market/util/widget_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart' hide Banner;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class BannerEditor extends StatefulWidget {
  const BannerEditor({super.key, this.banner});
  final Banner? banner;

  @override
  State<BannerEditor> createState() => _BannerEditorState();
}

class _BannerEditorState extends State<BannerEditor> {
  final _picker = ImagePicker();
  String? _imgPath;
  late Banner _banner;
  late Widget? _img;

  @override
  void initState() {
    super.initState();

    _banner = widget.banner ?? Banner();

    if (widget.banner != null) {
      if (_banner.actuallyLink != null && _banner.actuallyLink!.isNotEmpty) {
        _img = FadeInImage(
          placeholder: const AssetImage('assets/img/loading.gif'),
          image: FileImage(File(_banner.actuallyLink!)),
        );
      }
    } else {
      _img = const Card(
        child: Icon(
          Icons.add_rounded,
          size: 300,
        ),
      );
    }
  }

  void _getImageFromGallery() {
    _picker
        .pickImage(source: ImageSource.gallery, imageQuality: 30)
        .then((image) {
      if (image != null) {
        getTemporaryDirectory().then((direc) {
          _imgPath = "${direc.path}/${const Uuid().v4()}.jpg";
          image.saveTo(_imgPath!).then(
            (_) {
              setState(() {
                _img = Image.file(File(_imgPath!));
              });
            },
          );
        });
      }
    }).onError((error, stackTrace) {
      setState(() {});
    });
  }

  void _takeAPhoto() {
    _picker
        .pickImage(source: ImageSource.camera, imageQuality: 30)
        .then((image) {
      if (image != null) {
        getTemporaryDirectory().then((direc) {
          _imgPath = "${direc.path}/${const Uuid().v4()}.jpg";
          image.saveTo(_imgPath!).then(
            (_) {
              setState(() {
                _img = Image.file(File(_imgPath!));
              });
            },
          );
        });
      }
    }).onError((error, stackTrace) {
      setState(() {});
    });
  }

  void _showOptionChooseImage() {
    showModalBottomSheet(
        context: context,
        builder: (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.35,
            maxChildSize: 0.35,
            minChildSize: 0.3,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(defPading / 2),
                      child: Container(
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.onInverseSurface,
                            borderRadius: BorderRadius.circular(90)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _takeAPhoto();
                      },
                      child: const ListTile(
                        leading: Icon(
                          Icons.camera_enhance,
                          size: 48,
                        ),
                        title: Text("Take a photo"),
                      ),
                    ),
                    const Divider(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _getImageFromGallery();
                      },
                      child: const ListTile(
                          leading: Icon(
                            Icons.folder_rounded,
                            size: 48,
                          ),
                          title: Text("Choose photo")),
                    )
                  ],
                ),
              );
            }));
  }

  void _save() {
    WidgetUtil.showLoadingDialog(context);
    String? oldImgUrl;

    if (_imgPath != null && _imgPath!.isNotEmpty) {
      oldImgUrl = _banner.imgUrl;
      _banner.imgUrl =
          "images/${_imgPath!.substring(_imgPath!.lastIndexOf("/") + 1)}";
    }

    if (widget.banner == null) {
      BannerService.instance.add(_banner
        ..uploadDate = Timestamp.now()
        ..lastUpdatedDate = Timestamp.now());
    } else {
      BannerService.instance
          .update(_banner..lastUpdatedDate = Timestamp.now())
          .then((_) {
        // delete old img
        if (oldImgUrl != null && oldImgUrl.isNotEmpty) {
          FirestorageService.instance.delete(oldImgUrl);
        }
      });
    }

    if (_imgPath != null) {
      FirestorageService.instance.upload(_imgPath!).then((taskSnapshot) {
        switch (taskSnapshot.state) {
          case TaskState.running:
            final progress = 100.0 *
                (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
            debugPrint("Upload is $progress% complete.");
            break;
          case TaskState.paused:
            debugPrint("Upload is paused.");
            break;
          case TaskState.canceled:
            debugPrint("Upload was canceled");
            break;
          case TaskState.error:
            debugPrint("Uploading has error");
            break;
          case TaskState.success:
            Navigator.pop(context);
            Navigator.pop(context);
            break;
        }
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _delete() {
    if (widget.banner != null) {
      BannerService.instance
          .delete(_banner.id ?? "")
          .then((_) => Navigator.pop(context));
      if (_banner.imgUrl != null) {
        if (_banner.actuallyLink != null && _banner.actuallyLink!.isNotEmpty) {
          final file = File(_banner.actuallyLink!);
          file.exists().then((value) => value ? file.delete() : ());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Banner Editor"),
      ),
      body: GestureDetector(
        onTap: _showOptionChooseImage,
        child: Hero(
          tag: 'thumbnail${_banner.id ?? ""}',
          child: ClipRRect(
              borderRadius: BorderRadius.circular(defRadius),
              child: Align(alignment: Alignment.topCenter, child: _img!)),
        ),
      ),
      bottomSheet: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(defRadius),
            topRight: Radius.circular(defRadius)),
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _delete,
                  child: Container(
                    height: 60,
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: const Center(child: Text("Delete")),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (_imgPath == null) {
                      _showOptionChooseImage();
                    } else {
                      _save();
                    }
                  },
                  child: Container(
                    height: 60,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: const Center(child: Text("Save")),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
