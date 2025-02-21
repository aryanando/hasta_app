import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'repositories/auth_repository.dart';
import 'bloc/auth_bloc.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authRepository = AuthRepository();
  final isLoggedIn = await authRepository.isLoggedIn();

  print(
      'Running in ${AppConfig.currentEnv == Environment.development ? 'Development' : 'Production'} Mode');

  runApp(MyApp(authRepository: authRepository, isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final bool isLoggedIn;

  const MyApp(
      {super.key, required this.authRepository, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(authRepository: authRepository),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Auth App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: isLoggedIn ? const MainScreen() : const LoginScreen(),
      ),
    );
  }
}
