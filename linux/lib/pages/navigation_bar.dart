import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uas_pemweb/auth.dart';
import 'edit_page.dart';

class NavBar extends StatelessWidget {
  NavBar({Key? key}) : super(key: key);

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _userUid() {
    return Text(
      user?.email ?? 'User email',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      style: ButtonStyle(
          elevation: const MaterialStatePropertyAll(0),
          minimumSize:
              MaterialStateProperty.all(const Size(double.infinity, 52)),
          backgroundColor: MaterialStateProperty.all(
            Colors.red,
          ),
          shape: MaterialStateProperty.all(const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))))),
      child: Flex(
        direction: Axis.horizontal,
        children: const [
          Icon(
            Icons.logout,
            color: Colors.white,
          ),
          SizedBox(
            width: 6,
          ),
          Text(
            'Sign Out',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _navigateToEditPage(BuildContext context) async {
    String? password = await showDialog(
      context: context,
      builder: (context) {
        String password = '';

        return AlertDialog(
          content: TextField(
            obscureText: true,
            onChanged: (value) {
              password = value;
            },
            decoration: const InputDecoration(
                labelText: 'Konfirmasi Password',
                disabledBorder: OutlineInputBorder(),
                filled: true,
                fillColor: Color.fromARGB(255, 237, 237, 241),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                )),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Selanjutnya'),
              onPressed: () {
                Navigator.pop(context, password);
              },
            ),
          ],
        );
      },
    );

    if (password != null) {
      try {
        // Require authentication with entered password before navigating to edit page
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: user!.email!,
          password: password,
        );

        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditPage()),
        );
      } catch (e) {
        // Handle authentication errors
        String errorMessage = 'Error occurred while authenticating.';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              errorMessage = 'Pengguna tidak ditemukan';
              break;
            case 'wrong-password':
              errorMessage = 'Password salah';
              break;
          }
        }

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 3),
        ));
      }
    }
  }

  Widget _editButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _navigateToEditPage(context);
      },
      style: ButtonStyle(
          elevation: const MaterialStatePropertyAll(0),
          minimumSize:
              MaterialStateProperty.all(const Size(double.infinity, 52)),
          backgroundColor:
              MaterialStateProperty.all(Colors.black.withOpacity(0.1)),
          shape: MaterialStateProperty.all(const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))))),
      child: Flex(
        direction: Axis.horizontal,
        children: const [
          Icon(
            Icons.settings,
            color: Colors.black,
          ),
          SizedBox(
            width: 6,
          ),
          Text(
            'Edit Profil',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/user_background_default.jpg'),
                      fit: BoxFit.fitWidth),
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              Flex(
                direction: Axis.vertical,
                children: [
                  const Text(
                    'Sedang Login Sebagai:',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  _userUid(),
                ],
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                _editButton(context),
                const SizedBox(
                  height: 8,
                ),
                _signOutButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
