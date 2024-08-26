import 'package:flutter/material.dart';
import 'package:hasta_app/home_page.dart';
// import 'package:hasta_app/WelcomeScreen.dart';
// import 'package:hasta_app/reg_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passwordHidden = true, _isLoading = false;
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  Text loginStatus = const Text("");
  // Create storage
  final storage = const FlutterSecureStorage();

  Future<void> login(String email, String password) async {
    const apiUrl = '${const String.fromEnvironment('devUrl')}api/v1/login';

    final response = await http.post(Uri.parse(apiUrl), body: {
      'email': email,
      'password': password,
    });

    inspect(response.statusCode);

    if (response.statusCode == 200) {
      //mengambil data token
      final token = json.decode(response.body)['token'];

      //mengabil data user
      final user = json.decode(response.body)['user'];

      //menyimpan data token
      await storage.write(key: 'tokenSecure', value: token['token']);
      await storage.write(key: 'userData', value: jsonEncode(user));

      //berpindah halaman
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            id: user['id'],
            name: user['name'],
            email: user['email'],
          ),
        ),
        (route) => false,
      );
    } else {
      debugPrint(apiUrl);
      print(response.statusCode);
      setState(() {
        _isLoading = false;
        loginStatus = const Text("Sandi Atau Email Salah!..",
            style: TextStyle(color: Colors.red));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color(0xff7fc7d9),
                  Color(0xff365486),
                ]),
              ),
              child: const Padding(
                padding: EdgeInsets.only(top: 60.0, left: 22),
                child: Text(
                  'Halo...\nMasuk!...',
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 200.0),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                  color: Colors.white,
                ),
                height: double.infinity,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                            suffixIcon: Icon(
                              Icons.check,
                              color: Colors.grey,
                            ),
                            label: Text(
                              'Email',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff365486),
                              ),
                            )),
                      ),
                      TextFormField(
                        controller: passwordController,
                        obscureText: passwordHidden,
                        enableSuggestions: false,
                        autocorrect: false,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(passwordHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(
                                  () {
                                    passwordHidden = !passwordHidden;
                                  },
                                );
                              },
                              color: Colors.grey,
                            ),
                            label: const Text(
                              'Sandi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff365486),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 20,
                        child: loginStatus,
                      ),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          // 'Lupa Sandi?..',
                          '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Color(0xff281537),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 70,
                      ),
                      Container(
                        height: 55,
                        width: 300,
                        child: Center(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shadowColor: Colors.transparent),
                            onPressed: () {
                              setState(() => _isLoading = true);
                              login(emailController.text,
                                  passwordController.text);
                            },
                            icon: _isLoading
                                ? Container(
                                    width: 24,
                                    height: 24,
                                    padding: const EdgeInsets.all(2.0),
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Icon(Icons.login, color: Colors.white,),
                            label: const Text(
                              'Masuk',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 150,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
