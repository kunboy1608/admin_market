import 'dart:io';

import 'package:admin_market/service/firestorage_service.dart';
import 'package:admin_market/service/firestore_service.dart';
import 'package:admin_market/util/const.dart';
import 'package:admin_market/util/widget_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../entity/product.dart';
import '../util/thousand_seprator_input_formater.dart';

class ProductEditor extends StatefulWidget {
  const ProductEditor({super.key, this.data});
  final Product? data;

  @override
  State<ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<ProductEditor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameTEC = TextEditingController();
  final TextEditingController _priceTEC = TextEditingController();
  final TextEditingController _providerTEC = TextEditingController();
  final FocusNode _nodePrice = FocusNode();
  final FocusNode _nodeProvider = FocusNode();
  final _picker = ImagePicker();

  Widget? _img;

  String? _imgPath;
  late int _valueSelected;
  late Product _pro;

  @override
  void initState() {
    super.initState();
    _valueSelected = widget.data?.categoryId ?? 1;
    _pro = widget.data ?? Product();
    if (widget.data != null) {
      _nameTEC.text = _pro.name ?? "";
      _priceTEC.text = _pro.price?.toString() ?? "0";
      _providerTEC.text = _pro.provider ?? "";
      _valueSelected = _pro.categoryId ?? 1;

      if (widget.data!.actuallyLink != null &&
          widget.data!.actuallyLink!.isNotEmpty) {
        _img = FadeInImage.assetNetwork(
          placeholder: 'assets/img/loading.gif',
          image: widget.data!.actuallyLink!,
        );
      }
    }
    _img ??= const Card(
      child: Icon(
        Icons.add_rounded,
        size: 300,
      ),
    );
  }

  void _getImageFromGallery() async {
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

  void _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String? oldImgUrl;

    if (_imgPath != null && _imgPath!.isNotEmpty) {
      oldImgUrl = _pro.imgUrl;
      _pro.imgUrl =
          "images/${_imgPath!.substring(_imgPath!.lastIndexOf("/") + 1)}";
    }

    if (widget.data == null) {
      FirestoreService.instance.add(_pro
        ..categoryId = _valueSelected
        ..date = Timestamp.now()
        ..name = _nameTEC.text
        ..price = double.parse(_priceTEC.text
            .replaceAll(ThousandsSeparatorInputFormatter.SEPARATOR, ''))
        ..provider = _providerTEC.text);
    } else {
      FirestoreService.instance
          .update(_pro
            ..categoryId = _valueSelected
            ..date = Timestamp.now()
            ..name = _nameTEC.text
            ..price = double.parse(_priceTEC.text
                .replaceAll(ThousandsSeparatorInputFormatter.SEPARATOR, ''))
            ..provider = _providerTEC.text)
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

      WidgetUtil.showLoadingDialog(context);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: isLandscape ? 0.8 : 0.35,
                      maxChildSize: isLandscape ? 0.8 : 0.35,
                      minChildSize: isLandscape ? 0.7 : 0.3,
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onInverseSurface,
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
                      },
                    ),
                  );
                },
                child: Hero(
                  tag: 'thumbnail${widget.data?.id ?? ""}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(defRadius),
                    child: Container(child: _img),
                  ),
                ),
              ),
            ),
            Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(defPading),
                  child: Column(
                    children: [
                      TextFormField(
                        autofocus: true,
                        controller: _nameTEC,
                        onEditingComplete: () => _nodePrice.requestFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter product's name";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            label: const Text("Product's name*"),
                            suffixIcon: IconButton(
                                onPressed: () => _nameTEC.text = "",
                                icon: const Icon(Icons.clear_rounded))),
                      ),
                      const SizedBox(height: defPading),
                      TextFormField(
                        focusNode: _nodePrice,
                        controller: _priceTEC,
                        onEditingComplete: () => _nodeProvider.requestFocus(),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          ThousandsSeparatorInputFormatter()
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter product's cost";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            label: const Text("Product's cost*"),
                            suffixIcon: IconButton(
                                onPressed: () => _priceTEC.text = "",
                                icon: const Icon(Icons.clear_rounded))),
                      ),
                      const SizedBox(height: defPading),
                      TextFormField(
                        focusNode: _nodeProvider,
                        controller: _providerTEC,
                        decoration: InputDecoration(
                            label: const Text("Product's provider*"),
                            suffixIcon: IconButton(
                                onPressed: () => _providerTEC.text = "",
                                icon: const Icon(Icons.clear_rounded))),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter product's provider";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: defPading),
                      DropdownButton(
                          isExpanded: true,
                          value: _valueSelected,
                          items: const [
                            DropdownMenuItem(
                                value: 1, child: Text("Category 1")),
                            DropdownMenuItem(
                                value: 2, child: Text("Category 2")),
                            DropdownMenuItem(
                                value: 3, child: Text("Category 3")),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _valueSelected = value ?? _valueSelected;
                            });
                          }),
                      const SizedBox(height: defPading),
                      FilledButton(onPressed: _save, child: const Text("Save")),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
