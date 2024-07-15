import 'package:dio/dio.dart';
import 'package:dio_oidc_interceptor/dio_oidc_interceptor.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Dio _dio;

  /*
   * Replace with your own configuration
   */
  final OpenId _openId = OpenId(
    configuration: OpenIdConfiguration(
      clientId: 'ZvNul3BQsU6pq_ojk8_3zpNt',
      clientSecret: 'Ord1ltlUuMJwFsVI30gJ1cY0JZaeePe3WBu4IxRyjVBAu4FF',
      uri: Uri.parse('https://authorization-server.com'),
      scopes: ['openid', 'profile', 'email', 'phone', 'address'],
    ),
  );
  bool _isConnected = false;

  @override
  void initState() {
    _dio = Dio()..interceptors.add(_openId);
    checkConnection();
    super.initState();
  }

  Future<void> checkConnection() async {
    var result = await _openId.isConnected;
    _dio.close();
    setState(() {
      _isConnected = result;
    });
  }

  Future<void> login() async {
    await _openId.login();
    await checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _isConnected
                  ? 'You\'re connected'
                  : 'User: super-gibbon@example.com',
            ),
            _isConnected
                ? const SizedBox()
                : const Text('Password: Friendly-Hamster-8'),
            _isConnected
                ? const SizedBox()
                : ElevatedButton(
                    onPressed: login,
                    child: const Text('Login'),
                  ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
