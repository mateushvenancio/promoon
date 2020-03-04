import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';
import 'entidades.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CrudFirestore {
  void adicionarLoja(Loja loja) {
    DocumentReference db = Firestore.instance
        .collection('loja')
        .document("LOJA_" + geradorDeDocumento());

    Map<String, dynamic> dadosLoja = {
      "cnpj": loja.cnpj,
      "endereco": loja.endereco,
      "latitude": loja.latitude,
      "longitude": loja.longitude,
      "nome": loja.nome,
    };

    db.setData(dadosLoja).whenComplete(() {
      print('inserido com sucesso');
    }).catchError((e) {
      print(e);
    });
  }

  void adicionaPromocao(Promocao promocao) {
    DocumentReference db = Firestore.instance
        .collection('promocoes')
        .document("PROMO_" + geradorDeDocumento());

    Map<String, dynamic> dadosPromocao = {
      "nome": promocao.nome,
      "loja": promocao.loja,
      "categoria": promocao.categoria,
      "usuario": promocao.usuario,
      "latitude": promocao.latitude,
      "longitude": promocao.longitude,
      "precoOriginal": promocao.precoOriginal,
      "precoAtual": promocao.precoAtual,
      "foto": promocao.foto,
      "ativo": promocao.ativo,
    };

    db.setData(dadosPromocao).whenComplete(() {
      print('inserido com sucesso');
    }).catchError((e) {
      print(e);
    });
  }

  void adicionarUsuario(Usuario usuario) {
    DocumentReference db = Firestore.instance
        .collection('usuário')
        .document("USUARIO_" + geradorDeDocumento());

    Map<String, dynamic> dadosUsuario = {
      "nome": usuario.nome,
      "celular": usuario.celular,
      "email": usuario.email,
      "senha": usuario.senha
    };

    db.setData(dadosUsuario).whenComplete(() {
      print('inserido com sucesso');
    }).catchError((e) {
      print(e);
    });
  }

  void retornaLojaPorId(String id) {}

  void retornaLojaPorNome(String nome) {}

  void retornaPromocaoPorId(String id) {}

  void retornaPromocaoPorLatLong(double lat, double long) {}

  void retornaUsuarioPorId(String id) {}

  void retornaUsuarioPorNome(String nome) {}

  var db = Firestore.instance;

  Stream<QuerySnapshot> getList({int offset, int limit}) {
    Stream<QuerySnapshot> snaps = db.collection('promocoes').snapshots();

    if (offset != null) {
      snaps = snaps.skip(offset);
    }

    if (limit != null) {
      snaps = snaps.take(limit);
    }

    return snaps;
  }

  String geradorDeDocumento() {
    var id = randomBetween(10000000, 99999999);
    return id.toString();
  }
}

void retornaCoordenadasDeEndereco() {}

class CadastraUsuario {
  FirebaseAuth auth = FirebaseAuth.instance;

  cadastrarUsuario(Usuario usuario) {
    auth
        .createUserWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((result) {
      //result.user;
    });
  }
}
