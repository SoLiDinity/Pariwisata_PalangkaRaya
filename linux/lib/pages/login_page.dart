import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> signInWithEmailPassword() async {
    try {
      await Auth().signInWithEmailPassword(
          email: _emailController.text, password: _passwordController.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _labelText(
    final String label,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    bool obscure,
  ) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          )),
      obscureText: obscure,
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(const Color.fromRGBO(65, 171, 0, 1)),
          minimumSize:
              MaterialStateProperty.all(const Size(double.infinity, 52)),
          shape: MaterialStateProperty.all(const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))))),
      onPressed:
          isLogin ? signInWithEmailPassword : createUserWithEmailAndPassword,
      child: Text(isLogin ? 'Login' : 'Sign Up',
          style: const TextStyle(fontSize: 20)),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
        onPressed: () {
          setState(() {
            isLogin = !isLogin;
          });
        },
        child: Align(
          alignment: Alignment.bottomCenter,
          child: RichText(
            text: TextSpan(
              text: isLogin ? 'Belum punya akun? ' : 'Sudah punya akun? ',
              style: const TextStyle(color: Colors.white),
              children: [
                TextSpan(
                  text: isLogin ? 'Daftar' : 'Masuk',
                  style: const TextStyle(
                      color: Color.fromARGB(255, 0, 255, 102), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _loginOrRegisterTitle() {
    return Text(
      isLogin ? 'MASUK' : 'DAFTAR',
      style: const TextStyle(
          fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : 'Tedapat error: $errorMessage',
      style: const TextStyle(
        color: Colors.red,
      ),
    );
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(isLogin
                    ? 'assets/jembatan_kahayan.png'
                    : 'assets/bukit_tangkiling.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 32, vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/wonderful_indonesia.png",
                    width: 100,
                  ),
                  const SizedBox(
                    height: 90,
                  ),
                  _loginOrRegisterTitle(),
                  const SizedBox(
                    height: 30,
                  ),
                  _labelText('Email'),
                  const SizedBox(height: 4),
                  _inputField(_emailController, false),
                  const SizedBox(height: 16),
                  _labelText('Password'),
                  const SizedBox(height: 4),
                  _inputField(_passwordController, true),
                  const SizedBox(height: 16),
                  _errorMessage(),
                  const SizedBox(height: 16),
                  _submitButton(),
                  _loginOrRegisterButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
