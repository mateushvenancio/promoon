import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'retornaPromocoes.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:promoon/pages/bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';


class telaGPS extends StatefulWidget {
  double parLatitude = 0.0;
  double parLongitude = 0.0;
  telaGPS(this.parLatitude, this.parLongitude);
  @override
  _telaGPSState createState() => _telaGPSState(parLatitude, parLongitude);
}

class _telaGPSState extends State<telaGPS> {
  var todasAsPromosAoRedor = List<Widget>();
  GoogleMapController _controle;
  var latitudeAtual = 0.0;
  var longitudeAtual = 0.0;

  _telaGPSState(this.latitudeAtual, this.longitudeAtual);

  var bloc = Bloc();


  void _rodaTimer() async{
    Timer.periodic(Duration(seconds: 5), (timer) async {
      var documentos = await Firestore.instance.collection('promocoes').getDocuments();
      var localAtual = await Location().getLocation();  
         
    });
  }

  @override
  void initState() {
    criarMarcadores(context);
    bloc.initOneSignal();
    super.initState();
    _getLocalAtual();
    // _rodaTimer();
  }

  void _getLocalAtual() async {
    var location = new Location();
    LocationData localAtual = await location.getLocation().then((onValue) {
      _controle.moveCamera(
          CameraUpdate.newLatLng(LatLng(onValue.latitude, onValue.longitude)));

      return onValue;
    });

    latitudeAtual = localAtual.latitude;
    longitudeAtual = localAtual.longitude;

    _controle.moveCamera(
        CameraUpdate.newLatLng(LatLng(latitudeAtual, longitudeAtual)));
  }

  List<Circle> circulo() {
    List<Circle> circulos = new List<Circle>();
    circulos.add(Circle(
      circleId: CircleId("circulo"),
      center: LatLng(retornaLat(), retornaLong()),
      visible: true,
      radius: 200,
    ));
    return circulos;
  }

  double retornaLat() {
    _getLocalAtual();
    return latitudeAtual;
  }

  double retornaLong() {
    _getLocalAtual();
    return longitudeAtual;
  }

  void atualiza() async {
    setState(() {
      criarMarcadores(context);
    });
  }

  List<Marker> markers = new List<Marker>();

  void criarMarcadores(context) {
    Firestore.instance.collection("promocoes").snapshots().listen((docs) {
      if (docs.documents.isNotEmpty) {
        for (int i = 0; i < docs.documents.length; i++) {
          var doc = docs.documents[i];
          setState(() {
            markers.add(retornaMarcador(
                doc.documentID,
                double.parse(doc.data['latitude'].toString()),
                double.parse(doc.data['longitude'].toString()),
                doc.data['nome'],
                doc.data['loja'],
                context));
          });
        }
      }
    });
  }

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

  var promos = List<dynamic>();
  var promosAntiga = List<dynamic>();

  @override
  Widget build(BuildContext context) {
    _atualizaPromos() async {
      var documentos =
          await Firestore.instance.collection('promocoes').getDocuments();
      var localAtual = await Location().getLocation();
      var geolocator = Geolocator();

      for (var doc in documentos.documents) {
        var latitudePromo = double.parse(doc.data['latitude'].toString());
        var longitudePromo = double.parse(doc.data['longitude'].toString());
        var latitudeAtual = localAtual.latitude;
        var longitudeAtual = localAtual.longitude;

        var distancia = await geolocator.distanceBetween(
            latitudeAtual, longitudeAtual, latitudePromo, longitudePromo);

        if (distancia < 100) promos.add(doc);
      }

      if (promos.length != promosAntiga.length)
        enviaNotificacao(promos.elementAt(promos.length - 1)['nome']);

      print("Tamanho promos " + promos.length.toString());
      print("Tamanho promos antiga " + promosAntiga.length.toString());

      setState(() {
        promosAntiga = promos;
      });
    }

    void _rodaTimer() {
      Timer.periodic(Duration(seconds: 3), (timer) {
        _atualizaPromos();
      });
    }

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            GoogleMap(
              myLocationEnabled: true,
              onMapCreated: (controller) {
                _controle = controller;
                _getLocalAtual();
                _rodaTimer();
                atualiza();
              },
              markers: Set.of(markers),
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                  target: LatLng(retornaLat(), retornaLong()), zoom: 18),
            ),
          ],
        ),
      ),
    );
  }
}
