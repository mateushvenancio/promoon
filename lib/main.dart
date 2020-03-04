import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:promoon/pages/cadastraUsuario.dart';
import 'pages/cadastro_promocao.dart';
import 'package:promoon/pages/login.dart';
import 'pages/telas_gps.dart';
import 'pages/retornaPromocoes.dart';
import 'package:promoon/pages/bloc/bloc.dart';
import 'database/entidades.dart';
import 'package:promoon/pages/notificacao.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() async {
  var tela;
  var user = await FirebaseAuth.instance.currentUser();

  if (user == null)
    tela = Login();
  else
    tela = Principal();

  runApp(Inicio(tela));
}

class Inicio extends StatelessWidget {
  final widgetInicial;

  Inicio(this.widgetInicial);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
         primarySwatch: Colors.indigo,
         canvasColor: Colors.white,
        
         
      ),
      title: "PromoOn",
      home: widgetInicial,
    );
  }
}

class Principal extends StatefulWidget {
  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  List<dynamic> todasAsPromocoes = new List<dynamic>();
  var flnp;

  onSelectNotification(String payload) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Nova promoção!'),
          content: Text("$payload"),
        );
      },
    );
  }

  void inicializa(String payload) {
    flnp = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flnp.initialize(initSetttings,
        onSelectNotification: onSelectNotification(payload));
  }

  enviaNotificacao(String payload) async {
    await Future.delayed(Duration(seconds: 5));
    inicializa(payload);
    var titulo = 'Nova promoção';
    var corpo = 'Uma nova promoção pertinho de você';
    var android = AndroidNotificationDetails('Id', 'Name', 'Description');
    var iOS = IOSNotificationDetails();
    var details = NotificationDetails(android, iOS);
    flnp.show(0, titulo, payload, details);
  }

  var bloc = Bloc();

  String emailUsuario = "";
  bool logado = false;
  String nomeUsuario = "";
  String idUsuario = "";
  Usuario user;
  FirebaseAuth auth = FirebaseAuth.instance;
  Firestore db = Firestore.instance;

  Future verificaUsuarioLogado() async {
    FirebaseUser usuario = await auth.currentUser();
    Future.delayed(const Duration(seconds: 5));

    if (usuario != null) {
      var data = await db.collection('usuarios').document(usuario.uid).get();
      setState(() {
        nomeUsuario = data['nome'];
        emailUsuario = usuario.email;
        idUsuario = usuario.uid;
        logado = true;
      });
    } else {
      setState(() {
        nomeUsuario = "Usuário";
        emailUsuario = "";
        idUsuario = "";
        logado = false;
      });
    }
  }

  _fazLogoff() async {
    auth.signOut().then((value) {
      setState(() {
        nomeUsuario = "Fazer login";
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    });
  }

  bool categoriaAtiva;
  String nomeCategoria;
  @override
  void initState() {
    verificaUsuarioLogado();
    bloc.initOneSignal();
    categoriaAtiva = false;
    nomeCategoria = '';
    super.initState();
  }

  String u = "https://i.pravatar.cc/100";
  @override
  Widget build(BuildContext context) {
    _atualiza(nome, ativo) {
      setState(() {
        nomeCategoria = nome;
        categoriaAtiva = ativo;
      });
      print(nomeCategoria);
    }

    StreamBuilder constroiPromocoes() {
      Widget _buildList(context, document) {
        todasAsPromocoes.add(document);
        return retornaPromocao(
            document['nome'],
            document['loja'],
            double.parse(document['precoOriginal'].toString()),
            double.parse(document['precoAtual'].toString()),
            NetworkImage(document['foto']),
            double.parse(document['latitude'].toString()),
            double.parse(document['longitude'].toString()),
            context);
      }

      return StreamBuilder(
        stream: Firestore.instance.collection('promocoes').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text("Carregando... Aguarde!");
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              return _buildList(context, snapshot.data.documents[index].data);
            },
          );
        },
      );
    }

    StreamBuilder constroiPromocoesCategoria(nomeCategoria) {
      Widget _buildList(context, document) {
        return retornaPromocao(
            document['nome'],
            document['loja'],
            double.parse(document['precoOriginal'].toString()),
            double.parse(document['precoAtual'].toString()),
            NetworkImage(document['foto']),
            double.parse(document['latitude'].toString()),
            double.parse(document['longitude'].toString()),
            context);
      }

      return StreamBuilder(
        stream: Firestore.instance
            .collection('promocoes')
            .where('categoria', isEqualTo: nomeCategoria)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text("Carregando... Aguarde!");
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              return _buildList(context, snapshot.data.documents[index].data);
            },
          );
        },
      );
    }

    GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
    final double larguraTela = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: FloatingActionButton(
        child: Icon(FontAwesomeIcons.bell),
        onPressed: () {
          Random r = new Random();
          var i = r.nextInt(todasAsPromocoes.length);
          var nome = todasAsPromocoes[i]['nome'].toString();
          var diferenca = retornaDiferencaDePrecos(
              double.parse(todasAsPromocoes[i]['precoOriginal'].toString()),
              double.parse(todasAsPromocoes[i]['precoAtual'].toString()));
          String payload = 'Aproveite: $nome com $diferenca no preço!';
          enviaNotificacao(payload);
        },
      ),
      drawer: Drawer(
        
        child: ListView(
      
          children: <Widget>[
            
            UserAccountsDrawerHeader(
              currentAccountPicture: (logado)
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(u),
                    )
                  : CircleAvatar(
                      backgroundImage: AssetImage('images/usuariopadrao.png')),
              accountEmail: Text(emailUsuario),
              accountName: Text(nomeUsuario),
              onDetailsPressed: () {
                if (FirebaseAuth.instance.currentUser() != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                } else {
                  _fazLogoff();
                }
              },
            ),
          
            ListTile(
              title: Text('Nova promoção'),
              subtitle: Text('Cadastrar uma nova Promoção'),
              leading: Icon(FontAwesomeIcons.tag),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        cadastroPromocao(idUsuario, nomeUsuario),
                  ),
                );
              },
            ),
            ListTile(
                
              title: Text('Minhas promoções'),
              subtitle: Text('Lista as promoções cadastradas por você'),
              leading: Icon(FontAwesomeIcons.tags),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ListaDePromosUser(idUsuario)),
                );
              },
            ),
            ListTile(
               title: Text("Filtrar"),
               subtitle: Text('Filtra as promoçoes por distancias'),
               leading: Icon(FontAwesomeIcons.streetView),
               trailing: Icon(Icons.keyboard_arrow_right),
               onTap: () {  

               },
            ),
            // ListTile(
            //     title: Text("Cadastrar Loja"),
            //     onTap: () {
            //       if (logado)
            //         Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //                 builder: (BuildContext context) =>
            //                     cadastroPromocao(idUsuario, nomeUsuario)));
            //     }),
            // ListTile(
            //   title: Text("NOTIFICACAO TESTE"),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => Notificacao(),
            //       ),
            //     );
            //   },
            // ),
            ListTile(
              title: Text("Logoff"),
              onTap: () {
                var atual = FirebaseAuth.instance;
                if (logado) {
                  atual.signOut();
                  setState(() {
                    verificaUsuarioLogado();
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          AppBar(
            title: Text(
              'PromoOn',
              style: TextStyle(fontFamily: 'Lobster'),
            ),
            centerTitle: true,
            backgroundColor: Color(0xff3f51b5),
            elevation: 0,
            actions: <Widget>[
              IconButton(
                icon: Icon(FontAwesomeIcons.searchLocation),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => telaGPS(0, 0)));
                },
              ),
            /*  IconButton(
                icon: Icon(Icons.list),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ListaDePromosUser(idUsuario)));
                },
              ),*/
            ],
          ),
          Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      "Categorias:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Container(
                height: 200,
                width: larguraTela,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        _atualiza('', false);
                      },
                      child: retornaCategoria(
                          "Todas", "images/categorias/todas.png"),
                    ),
                    GestureDetector(
                      onTap: () {
                        _atualiza('Alimentação', true);
                      },
                      child: retornaCategoria(
                          "Alimentação", "images/categorias/alimentação.png"),
                    ),
                    GestureDetector(
                      onTap: () {
                        _atualiza('Conveniências', true);
                      },
                      child: retornaCategoria("Conveniências",
                          "images/categorias/conveniências.png"),
                    ),
                    GestureDetector(
                      onTap: () {
                        _atualiza('Vestuário', true);
                      },
                      child: retornaCategoria(
                          "Vestuário", "images/categorias/vestuário.png"),
                    ),
                    GestureDetector(
                      onTap: () {
                        _atualiza('Eletrônicos', true);
                      },
                      child: retornaCategoria(
                          "Eletrônicos", "images/categorias/eletrônicos.png"),
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      "Promoções:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.fitHeight,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: (categoriaAtiva == false)
                  ? constroiPromocoes()
                  : constroiPromocoesCategoria(nomeCategoria),
            ),
          ),
        ],
      ),
    );
  }
}
