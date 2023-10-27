import 'package:admin_market/entity/voucher.dart';
import 'package:admin_market/service/entity/voucher_service.dart';
import 'package:admin_market/util/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VoucherEditor extends StatefulWidget {
  const VoucherEditor({super.key, this.voucher});
  final Voucher? voucher;

  @override
  State<VoucherEditor> createState() => _VoucherEditorState();
}

class _VoucherEditorState extends State<VoucherEditor> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _codeTEC = TextEditingController();
  final TextEditingController _percentTEC = TextEditingController();
  final TextEditingController _maxValueTEC = TextEditingController();
  final TextEditingController _countTEC = TextEditingController();

  final FocusNode _percentNode = FocusNode();
  final FocusNode _maxValueNode = FocusNode();
  final FocusNode _countNode = FocusNode();

  late Voucher _voucher;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    _voucher = widget.voucher ?? Voucher();
    if (widget.voucher != null) {
      _isPublic = _voucher.isPublic;
      _codeTEC.text = _voucher.name ?? "";
      _percentTEC.text = _voucher.percent?.toString() ?? "0";
      _maxValueTEC.text = _voucher.maxValue?.toString() ?? "0";
      _countTEC.text = _voucher.count?.toString() ?? "0";

      _startDate = _voucher.startDate?.toDate();
      _endDate = _voucher.endDate?.toDate();
    }
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

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _voucher.name = _codeTEC.text.toUpperCase();
    _voucher.percent = double.parse(_percentTEC.text);
    _voucher.maxValue = double.parse(_maxValueTEC.text);
    _voucher.count = int.parse(_countTEC.text);
    _voucher.startDate =
        _startDate == null ? null : Timestamp.fromDate(_startDate!);
    _voucher.endDate = _endDate == null ? null : Timestamp.fromDate(_endDate!);

    _voucher.isPublic = _isPublic;

    if (widget.voucher == null) {
      VoucherService.instance.add(_voucher);
    } else {
      VoucherService.instance.update(_voucher);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voucher Editor"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defPading),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Id: ${_voucher.id ?? "<Generate automatically>"}",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (_voucher.id != null)
                        IconButton(
                          icon: const Icon(Icons.copy_rounded),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _voucher.id!))
                                .then((_) {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Copied voucher id")),
                              );
                            });
                          },
                        ),
                    ],
                  ),
                  TextFormField(
                    autofocus: true,
                    controller: _codeTEC,
                    onEditingComplete: () => _percentNode.requestFocus(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter voucher's code";
                      }
                      if (value.length < 4) {
                        return "Code leasts 4 letters";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        label: const Text("Code"),
                        hintText: "Ex: THGT2023, SSAAA3",
                        helperText: "Customers use this code to apply discount",
                        suffixIcon: IconButton(
                            onPressed: () => _codeTEC.text = "",
                            icon: const Icon(Icons.clear_rounded))),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    focusNode: _percentNode,
                    controller: _percentTEC,
                    onEditingComplete: () => _maxValueNode.requestFocus(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter voucher's percent";
                      }
                      try {
                        if (double.parse(value) <= 100.0 &&
                            double.parse(value) >= 0.0) {
                          return null;
                        }
                      } catch (e) {
                        return "Input is invalid";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        label: const Text("Percent (%)"),
                        hintText: "10%",
                        helperText:
                            "The value ranges from 0 to 100. \nA value of 0 indicates no dependence on the percentage.",
                        helperMaxLines: 2,
                        suffix: const Text("%"),
                        suffixIcon: IconButton(
                            onPressed: () => _percentTEC.text = "",
                            icon: const Icon(Icons.clear_rounded))),
                  ),
                  TextFormField(
                    focusNode: _maxValueNode,
                    controller: _maxValueTEC,
                    onEditingComplete: () => _countNode.requestFocus(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter voucher's max value";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        label: const Text("Max value"),
                        helperText: "It clamp value if order's cost too large",
                        hintText:
                            "If percent is null, it will apply this value",
                        suffixIcon: IconButton(
                            onPressed: () => _maxValueTEC.text = "",
                            icon: const Icon(Icons.clear_rounded))),
                  ),
                  TextFormField(
                    focusNode: _countNode,
                    controller: _countTEC,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter voucher's count";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        label: const Text("Count"),
                        hintText: "A value of -1 indicates unlimited usage",
                        helperText: "How many it can be applied",
                        suffixIcon: IconButton(
                            onPressed: () => _countTEC.text = "",
                            icon: const Icon(Icons.clear_rounded))),
                  ),
                  Row(
                    children: [
                      const Text("Start date:"),
                      Expanded(
                          child: Text(_startDate.toString(),
                              textAlign: TextAlign.right)),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _startDate = null;
                            });
                          },
                          icon: const Icon(Icons.clear_rounded)),
                      IconButton(
                          onPressed: () {
                            _chooseDate().then((value) {
                              if (value != null) {
                                setState(() {
                                  _startDate = value;
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
                          child: Text(_endDate.toString(),
                              textAlign: TextAlign.right)),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _endDate = null;
                            });
                          },
                          icon: const Icon(Icons.clear_rounded)),
                      IconButton(
                          onPressed: () {
                            _chooseDate().then((value) {
                              if (value != null) {
                                setState(() {
                                  _endDate = value;
                                });
                              }
                            });
                          },
                          icon: const Icon(Icons.calendar_today)),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(
                          child: Text(
                        "Allow customers can see this voucher",
                        overflow: TextOverflow.ellipsis,
                      )),
                      Switch(
                        value: _isPublic,
                        onChanged: (value) {
                          setState(() {
                            _isPublic = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              )),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: const Icon(Icons.save_as_rounded),
      ),
    );
  }

  @override
  void dispose() {
    _codeTEC.dispose();
    _countNode.dispose();
    _countTEC.dispose();
    _maxValueNode.dispose();
    _maxValueTEC.dispose();
    _percentNode.dispose();
    _percentTEC.dispose();
    super.dispose();
  }
}
