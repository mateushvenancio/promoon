import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

// Future<Post> fetchPost() async {
//   final response =
//       await http.get('https://jsonplaceholder.typicode.com/posts/1');

//   if (response.statusCode == 200) {
//     // If the call to the server was successful, parse the JSON.
//     return Post.fromJson(json.decode(response.body));
//   } else {
//     // If that call was not successful, throw an error.
//     throw Exception('Failed to load post');
//   }
// }

// class Post {
//   final int userId;
//   final int id;
//   final String title;
//   final String body;

//   Post({this.userId, this.id, this.title, this.body});

//   factory Post.fromJson(Map<String, dynamic> json) {
//     return Post(
//       userId: json['userId'],
//       id: json['id'],
//       title: json['title'],
//       body: json['body'],
//     );
//   }
// }

// void main() => runApp(MyApp());

// class MyApp extends StatefulWidget {
//   MyApp({Key key}) : super(key: key);

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
// Future<Post> post;

//   @override
//   void initState() {
//     super.initState();
//     post = fetchPost();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Fetch Data Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Fetch Data Example'),
//         ),
//         body: Center(
//           child: FutureBuilder<Post>(
//             future: post,
//             builder: (context, snapshot) {
//               if (snapshot.hasData) {
//                 return Text(snapshot.data.title);
//               } else if (snapshot.hasError) {
//                 return Text("${snapshot.error}");
//               }

//               // By default, show a loading spinner.
//               return CircularProgressIndicator();
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

class Notificacao extends StatefulWidget {
  @override
  _NotificacaoState createState() => _NotificacaoState();
}

class _NotificacaoState extends State<Notificacao> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var android;
  var iOS;
  var initSetttings;

  onSelectNotification(String payload) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Nova promoção!'),
          content: Text("Retorno: $payload"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    void inicializa(String payload) {
      flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
      android = new AndroidInitializationSettings('@mipmap/ic_launcher');
      iOS = new IOSInitializationSettings();
      initSetttings = new InitializationSettings(android, iOS);
      flutterLocalNotificationsPlugin.initialize(initSetttings,
          onSelectNotification: onSelectNotification(payload));
    }

    enviaNotificacao() async {
      await Future.delayed(Duration(seconds: 5));
      inicializa('');
      var titulo = 'Nova promoção';
      var corpo = 'Uma nova promoção pertinho de você';
      var android = AndroidNotificationDetails('Id', 'Name', 'Description');
      var iOS = IOSNotificationDetails();
      var details = NotificationDetails(android, iOS);
      flutterLocalNotificationsPlugin.show(0, titulo, corpo, details);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Recebe notificação'),
      ),
      body: Center(
        child: FlatButton(
          onPressed: () {
            enviaNotificacao();
          },
          child: Text("Recebe"),
        ),
      ),
    );
  }
}
