import 'package:admin_market/home/home.dart';
import 'package:admin_market/service/google/firebase_service.dart';
import 'package:admin_market/util/const.dart';
import 'package:admin_market/util/widget_util.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _nodePassword = FocusNode();

  final TextEditingController _usernameTEC = TextEditingController();
  final TextEditingController _passwordTEC = TextEditingController();

  String _noti = "";

  String? _checkEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter username";
    }
    final RegExp regex =
        RegExp(r'^[a-zA-Z0-9.a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]');
    return regex.hasMatch(value) ? null : "Invalid email";
  }

  String? _checkPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter password";
    }

    if (value.length < 6) {
      return "Password leasts 6 chracters";
    }

    return null;
  }

  void _login() {
    _usernameTEC.text = _usernameTEC.text.trim();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    WidgetUtil.showLoadingDialog(context);

    FirebaseService.instance
        .signInWithEmail(_usernameTEC.text, _passwordTEC.text)
        .then((credential) {
      Navigator.of(context).pop();

      if (credential != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Home(),
            ));
      } else {
        setState(() {
          _noti = "Invalid user's information";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        "assets/img/background_login.png",
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.cover,
      ),
      bottomSheet: SingleChildScrollView(
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(defPading),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(defRadius),
                  topRight: Radius.circular(defRadius)),
              color: Theme.of(context).colorScheme.secondaryContainer),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        label: const Text("Username"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(defRadius)),
                        prefixIcon: const Icon(Icons.person_2_rounded),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => _usernameTEC.text = "",
                        ),
                      ),
                      controller: _usernameTEC,
                      keyboardType: TextInputType.emailAddress,
                      autofocus: true,
                      validator: (value) => _checkEmail(value),
                      onEditingComplete: () => _nodePassword.requestFocus(),
                    ),
                    const SizedBox(height: defPading),
                    TextFormField(
                      decoration: InputDecoration(
                        label: const Text("Password"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(defRadius)),
                        prefixIcon: const Icon(Icons.lock_rounded),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => _passwordTEC.text = "",
                        ),
                      ),
                      controller: _passwordTEC,
                      focusNode: _nodePassword,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) => _checkPassword(value),
                      onEditingComplete: _login,
                    ),
                    _noti.isEmpty
                        ? const SizedBox(
                            height: defPading,
                          )
                        : Text(
                            _noti,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                    SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                            onPressed: _login, child: const Text("Login"))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
