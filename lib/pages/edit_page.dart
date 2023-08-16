import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uas_pemweb/auth.dart';

class EditPage extends StatefulWidget {
  const EditPage({Key? key}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  String? errorMessage = '';
  String? successMessage = '';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the text controller with the current email
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _emailController.text = currentUser.email ?? '';
    }
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Future<void> updateUserProfile() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.updateEmail(_emailController.text);
        if (_newPasswordController.text.isNotEmpty) {
          await currentUser.updatePassword(_newPasswordController.text);
        }
        setState(() {
          errorMessage = ''; // Clear any previous error message
          successMessage = 'Data Berhasil Diubah';

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                  'Login Kembali',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 42, 78, 20),
                  ),
                ),
                content: const Text('Silakan login kembali untuk melanjutkan.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      signOut();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
        successMessage = '';
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
        ),
      ),
      obscureText: obscure,
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all(const Color.fromRGBO(65, 171, 0, 1)),
        minimumSize: MaterialStateProperty.all(const Size(double.infinity, 52)),
        shape: MaterialStateProperty.all(const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        )),
      ),
      onPressed: updateUserProfile,
      child: const Text(
        'Simpan Perubahan',
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _deleteButton(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.red),
        minimumSize: MaterialStateProperty.all(const Size(double.infinity, 52)),
        shape: MaterialStateProperty.all(const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        )),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Konfirmasi Hapus Akun',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              content: const Text(
                'Apakah Anda yakin ingin menghapus akun ini? Tindakan ini tidak dapat dibatalkan.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      User? currentUser = FirebaseAuth.instance.currentUser;

                      if (currentUser != null) {
                        await currentUser.delete();
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                        signOut();
                      }
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        errorMessage = e.message;
                        successMessage = '';
                      });
                    }
                  },
                  child: const Text('Hapus Akun'),
                ),
              ],
            );
          },
        );
      },
      child: const Text(
        'Hapus Akun',
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? successMessage ?? '' : 'Error: $errorMessage',
      style: TextStyle(
        color: errorMessage == '' ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 42, 78, 20),
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              )),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/jembatan_kahayan.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                  _labelText('Edit Email'),
                  const SizedBox(height: 4),
                  _inputField(_emailController, false),
                  const SizedBox(height: 16),
                  _labelText('Edit Password'),
                  const SizedBox(height: 4),
                  _inputField(_newPasswordController, true),
                  const SizedBox(height: 16),
                  _errorMessage(),
                  const SizedBox(height: 16),
                  _submitButton(),
                  const SizedBox(height: 16),
                  _deleteButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
