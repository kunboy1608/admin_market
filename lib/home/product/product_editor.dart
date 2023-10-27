import 'dart:io';

import 'package:admin_market/service/entity/product_service.dart';
import 'package:admin_market/service/google/firestorage_service.dart';
import 'package:admin_market/util/const.dart';
import 'package:admin_market/util/widget_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../entity/product.dart';

class ProductEditor extends StatefulWidget {
  const ProductEditor({super.key, this.data});
  final Product? data;

  @override
  State<ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<ProductEditor> {
  final _formKey = GlobalKey<FormState>();
  final _formDiscountKey = GlobalKey<FormState>();

  final TextEditingController _nameTEC = TextEditingController();
  final TextEditingController _priceTEC = TextEditingController();
  final TextEditingController _providerTEC = TextEditingController();
  final TextEditingController _descriptionTEC = TextEditingController();
  final TextEditingController _discountPriceTEC = TextEditingController();

  final FocusNode _nodePrice = FocusNode();
  final FocusNode _nodeProvider = FocusNode();
  final FocusNode _nodeCategory = FocusNode();
  final FocusNode _nodeDecription = FocusNode();
  final FocusNode _nodeDiscountPrice = FocusNode();

  bool _isDiscount = false;
  DateTime? _startDiscountDate;
  DateTime? _endDiscountDate;

  String _noti = "";

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
      _priceTEC.text = _pro.price?.toString() == null
          ? "0"
          : double.parse(_pro.price!.toString()).toString();
      _providerTEC.text = _pro.provider ?? "";
      _valueSelected = _pro.categoryId ?? 1;
      _startDiscountDate = _pro.startDiscountDate?.toDate();
      _endDiscountDate = _pro.endDiscountDate?.toDate();

      _isDiscount = _pro.discountPrice != null;
      _discountPriceTEC.text = _pro.discountPrice?.toString() ?? "";

      if (widget.data!.actuallyLink != null &&
          widget.data!.actuallyLink!.isNotEmpty) {
        _img = FadeInImage(
          placeholder: const AssetImage('assets/img/loading.gif'),
          image: FileImage(File(widget.data!.actuallyLink!)),
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

  Future<DateTime?> _chooseDate() {
    return showDatePicker(
            context: context,
            initialDatePickerMode: DatePickerMode.year,
            initialDate: DateTime.now(),
            firstDate: DateTime(0),
            lastDate: DateTime(9999))
        .then((date) {
      if (date != null) {
        return showTimePicker(context: context, initialTime: TimeOfDay.now())
            .then((time) {
          if (time != null) {
            return DateTime(
                date.year, date.month, date.day, time.hour, time.minute);
          }
          return date;
        });
      }
      return null;
    });
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

  void _save() async {
    if (!_formKey.currentState!.validate() ||
        (_isDiscount && !_formDiscountKey.currentState!.validate())) {
      return;
    }

    if ((_isDiscount &&
        _endDiscountDate == null &&
        _startDiscountDate == null)) {
      setState(() {
        _noti = "Please choose periods time discount";
      });
      return;
    }

    WidgetUtil.showLoadingDialog(context);

    String? oldImgUrl;

    if (_imgPath != null && _imgPath!.isNotEmpty) {
      oldImgUrl = _pro.imgUrl;
      _pro.imgUrl =
          "images/${_imgPath!.substring(_imgPath!.lastIndexOf("/") + 1)}";
    }

    if (_isDiscount) {
      _pro
        ..discountPrice = double.parse(_discountPriceTEC.text)
        ..startDiscountDate = _startDiscountDate == null
            ? null
            : Timestamp.fromDate(_startDiscountDate!)
        ..endDiscountDate = _endDiscountDate == null
            ? null
            : Timestamp.fromDate(_endDiscountDate!);
    }

    if (widget.data == null) {
      ProductService.instance.add(_pro
        ..categoryId = _valueSelected
        ..uploadDate = Timestamp.now()
        ..name = _nameTEC.text
        // ..price = double.parse(_priceTEC.text
        //     .replaceAll(ThousandsSeparatorInputFormatter.SEPARATOR, ''))
        ..price = double.parse(_priceTEC.text)
        ..provider = _providerTEC.text);
    } else {
      ProductService.instance
          .update(_pro
            ..categoryId = _valueSelected
            ..name = _nameTEC.text
            // ..price = double.parse(_priceTEC.text
            //     .replaceAll(ThousandsSeparatorInputFormatter.SEPARATOR, ''))
            ..price = double.parse(_priceTEC.text)
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
    } else {
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  Widget _partInputDiscount() {
    return AnimatedContainer(
      height: _isDiscount ? 190.0 : 0.0,
      duration: const Duration(seconds: 1),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Form(
              key: _formDiscountKey,
              child: TextFormField(
                focusNode: _nodeDiscountPrice,
                controller: _discountPriceTEC,
                onEditingComplete: () => _nodeDecription.requestFocus(),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter product's discount price";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    label: const Text("Product's discount price*"),
                    suffixIcon: IconButton(
                        onPressed: () => _discountPriceTEC.text = "",
                        icon: const Icon(Icons.clear_rounded))),
              ),
            ),
            Row(
              children: [
                const Text("Start date:"),
                Expanded(
                    child: Text(_startDiscountDate.toString(),
                        textAlign: TextAlign.right)),
                IconButton(
                    onPressed: () {
                      setState(() {
                        _startDiscountDate = null;
                      });
                    },
                    icon: const Icon(Icons.clear_rounded)),
                IconButton(
                    onPressed: () {
                      _chooseDate().then((value) {
                        if (value != null) {
                          setState(() {
                            _startDiscountDate = value;
                          });
                        }
                      });
                    },
                    icon: const Icon(Icons.calendar_today)),
              ],
            ),
            Row(
              children: [
                const Text("End date:"),
                Expanded(
                    child: Text(_endDiscountDate.toString(),
                        textAlign: TextAlign.right)),
                IconButton(
                    onPressed: () {
                      setState(() {
                        _endDiscountDate = null;
                      });
                    },
                    icon: const Icon(Icons.clear_rounded)),
                IconButton(
                    onPressed: () {
                      _chooseDate().then((value) {
                        if (value != null) {
                          setState(() {
                            _endDiscountDate = value;
                          });
                        }
                      });
                    },
                    icon: const Icon(Icons.calendar_today)),
              ],
            ),
            Text(
              _noti,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product editor"),
      ),
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
                        onEditingComplete: () => _nodeCategory.requestFocus(),
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
                          focusNode: _nodeCategory,
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
                            _nodeDecription.requestFocus();
                          }),
                      const SizedBox(height: defPading),
                      Row(
                        children: [
                          const Expanded(
                              child: Text(
                            "Create discount event",
                            overflow: TextOverflow.ellipsis,
                          )),
                          Switch(
                            value: _isDiscount,
                            onChanged: (value) {
                              setState(() {
                                _isDiscount = value;
                              });
                              if (_isDiscount) {
                                _nodeDiscountPrice.requestFocus();
                              } else {
                                FocusScope.of(context).unfocus();
                              }
                            },
                          ),
                        ],
                      ),
                      _partInputDiscount(),
                      const SizedBox(height: defPading),
                      TextFormField(
                        focusNode: _nodeDecription,
                        controller: _descriptionTEC,
                        maxLines: 4,
                        onEditingComplete: () => _nodeCategory.requestFocus(),
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(defRadius))),
                            label: const Text("Product's description"),
                            suffixIcon: IconButton(
                                onPressed: () => _descriptionTEC.text = "",
                                icon: const Icon(Icons.clear_rounded))),
                        validator: (_) => null,
                      ),
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

  @override
  void dispose() {
    _descriptionTEC.dispose();
    _nameTEC.dispose();
    _priceTEC.dispose();
    _providerTEC.dispose();
    _discountPriceTEC.dispose();

    _nodeCategory.dispose();
    _nodeDecription.dispose();
    _nodePrice.dispose();
    _nodeProvider.dispose();
    _nodeDiscountPrice.dispose();
    super.dispose();
  }
}
