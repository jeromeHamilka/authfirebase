import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../common/loading.dart';
import '../../services/authentication.dart';

class AuthenticateScreen extends StatefulWidget {
  const AuthenticateScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticateScreen> createState() => _AuthenticateScreenState();
}

class _AuthenticateScreenState extends State<AuthenticateScreen> {
  final AuthenticationService _auth = AuthenticationService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  bool showSignIn = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void toggleView() {
    setState(() {
      _formKey.currentState?.reset();
      error = '';
      emailController.text = '';
      nameController.text = '';
      passwordController.text = '';
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.blue,
              elevation: 0.0,
              title: Text(
                showSignIn
                    ? 'Sign in to Water Social'
                    : 'Register to Water Social',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              actions: <Widget>[
                TextButton.icon(
                  icon: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  label: Text(showSignIn ? "Register" : 'Sign In',
                      style: const TextStyle(color: Colors.white)),
                  onPressed: () => toggleView(),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      !showSignIn
                          ? TextFormField(
                              controller: nameController,
                              decoration:
                                  textInputDecoration.copyWith(hintText: 'name'),
                              validator: (value) => value == null || value.isEmpty
                                  ? "Enter a name"
                                  : null,
                            )
                          : Container(),
                      !showSignIn ? const SizedBox(height: 10.0) : Container(),
                      TextFormField(
                        controller: emailController,
                        decoration:
                            textInputDecoration.copyWith(hintText: 'email'),
                        validator: (value) => value == null || value.isEmpty
                            ? "Enter an email"
                            : null,
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: passwordController,
                        decoration:
                            textInputDecoration.copyWith(hintText: 'password'),
                        obscureText: true,
                        validator: (value) => value != null && value.length < 6
                            ? "Enter a password with at least 6 characters"
                            : null,
                      ),
                      const SizedBox(height: 10.0),
                      ElevatedButton(
                        child: Text(
                          showSignIn ? "Sign In" : "Register",
                          style: const TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState?.validate() == true) {
                            setState(() => loading = true);
                            var password = passwordController.value.text;
                            var email = emailController.value.text;
                            var name = nameController.value.text;

                            dynamic result = showSignIn
                                ? await _auth.signInWithEmailAndPassword(email, password)
                                : await _auth.registerWithEmailAndPassword(name, email, password);
                            if (result == null) {
                              setState(() {
                                loading = false;
                                error = 'Please supply a valid email';
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        error,
                        style: const TextStyle(color: Colors.red, fontSize: 15.0),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
