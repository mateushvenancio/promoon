import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'telas_gps.dart';
import 'externo.dart';

Widget retornaCategoria(String nome, String imagem) {
  return Container(
    width: 150,
    child: Padding(
      padding: EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            image:
                DecorationImage(image: AssetImage(imagem), fit: BoxFit.cover),
          ),
          child: Center(
            child: Text(
              nome,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget retornaPromocao(String nome, String loja, double pOr, double pAt,
    NetworkImage foto, double lat, double long, context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => telaGPS(lat, long)));
    },
    child: Padding(
      padding: EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 100,
          width: 400,
          color: Color(0xff3f51b5),
          child: Row(
            children: <Widget>[
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                    image: DecorationImage(image: foto, fit: BoxFit.cover)),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(loja,style: TextStyle(color: Colors.white)),
                        Expanded(child: Center(child: Text(nome , style: TextStyle(color: Colors.white)))),
                        Text("De R\$ " +
                            pOr.toString() +
                            " por R\$ " +
                            pAt.toString() +
                            "",style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 100,
                width: 50,
                color: Colors.grey,
                child: Center(
                  child: Text(
                    retornaDiferencaDePrecos(pOr, pAt).toString(),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget promosNoMapa(int i) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        height: 100,
        width: 100,
        color: Colors.yellow,
        child: Center(
          child: Text("Promoção" + i.toString()),
        ),
      ),
    ),
  );
}

// class Promocao {
//   String nome;
//   double latitude;
//   double longitude;
//   String loja;

//   double precoOriginal;
//   double precoAtual;

//   NetworkImage foto;

//   Promocao(this.nome, this.foto, this.latitude, this.longitude, this.loja,
//       this.precoOriginal, this.precoAtual);
// }

// List<Promocao> promocoes() {
//   List<Promocao> lista = List<Promocao>();

//   lista.add(new Promocao(
//       "Tenis Adidas 37/38",
//       NetworkImage(
//           "https://assets.adidas.com/images/w_600,h_600,f_auto,q_auto:sensitive,fl_lossy/c68970dc89ee4217beb3a83a01259c66_9366/Tenis_X_PLR_Preto_CQ2405_01_standard.jpg"),
//       -18.574565,
//       -46.514591,
//       "Loja de tenis",
//       200,
//       150));

//   lista.add(new Promocao(
//       "Sanduiche de presunto",
//       NetworkImage(
//           "https://t1.uc.ltmcdn.com/pt/images/0/1/3/img_como_fazer_sanduiche_natural_9310_600.jpg"),
//       -18.574934,
//       -46.514629,
//       "Lanchonete da praça",
//       30,
//       25));

//   lista.add(new Promocao(
//       "Carne bovina 1kg",
//       NetworkImage(
//           "http://revistagalileu.globo.com/Revista/Galileu2/foto/0,,69178369,00.jpg"),
//       -18.575311,
//       -46.514645,
//       "Acougue central",
//       65,
//       50));

//   lista.add(new Promocao(
//       "Fusca",
//       NetworkImage("https://img0.icarros.com/dbimg/imgnoticia/4/26532_1"),
//       -18.575124,
//       -46.514355,
//       "Loja de carros",
//       35000,
//       30000));

//   lista.add(new Promocao(
//       "Pokemon omega ruby 3ds",
//       NetworkImage(
//           "https://vgboxart.com/boxes/3DS/65902-pokemon-omega-ruby.png"),
//       -18.574725,
//       -46.514284,
//       "Loja de jogos",
//       150,
//       100));

//   return lista;
// }

String retornaDiferencaDePrecos(double precoAntigo, double precoNovo) {
  double total = 100 - ((precoNovo * 100) / precoAntigo);
  return "-" + total.round().toString() + "%";
}

// List<Marker> marcs(BuildContext context) {
//   List<Marker> marcadores = new List<Marker>();
//   var promos = promocoes();
//   for (var i = 0; i < promos.length; i++) {
//     var atual = promos[i];
//     marcadores.add(retornaMarcador(atual.nome, atual.latitude, atual.longitude,
//         atual.nome, atual.loja, context));
//   }
//   return marcadores;
// }

Marker retornaMarcador(String id, double latitude, double longitude,
    String titulo, String descricao, BuildContext context) {
  return Marker(
    markerId: MarkerId(id),
    draggable: false,
    onTap: () {
      print('clicado!');
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.shopping_cart),
                  title: Text("Ver a loja"),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.spa),
                  title: Text("Ver a promoção"),
                  onTap: () {
                    
                  },
                ),
                ListTile(
                  leading: Icon(Icons.drive_eta),
                  title: Text("Ir para a loja"),
                  onTap: () {
                    abrirNoGoogleMaps(latitude, longitude);
                  },
                ),
              ],
            );
          });
    },
    position: LatLng(latitude, longitude),
    infoWindow: InfoWindow(
      title: titulo,
      snippet: descricao,
    ),
  );
}

final databaseReference = Firestore.instance;
var todos = new List<Widget>();
