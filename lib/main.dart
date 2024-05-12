import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';
import 'login_screen.dart';
import 'task_screen.dart';
import 'signup_screen.dart';
import 'init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeParse();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'QuickTask',
        theme: ThemeData(
          primaryColor: Colors.indigo,
          hintColor: Colors.pinkAccent,
          scaffoldBackgroundColor: Colors.grey[100],
          textTheme: TextTheme(
            headline6: TextStyle(color: Colors.black87, fontSize: 20.0),
            bodyText2: TextStyle(color: Colors.black54),
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.indigo,
            textTheme: ButtonTextTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.indigo),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        initialRoute: '/', // Set the initial route
        routes: {
          '/': (context) => LoginScreen(), // Ensure this is the root
          '/taskScreen': (context) => TaskScreen(),
          '/signup': (context) => SignupScreen(),
        },
      ),
    );
  }
}
