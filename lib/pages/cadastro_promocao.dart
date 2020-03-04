import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:promoon/database/database_helper.dart';
import 'package:promoon/database/entidades.dart';
import 'package:promoon/main.dart';
import 'package:promoon/pages/cadastraUsuario.dart';
import 'package:promoon/pages/retornaPromocoes.dart';

CrudFirestore crud = new CrudFirestore();

//loja
var nomeEmpresaController = new TextEditingController();
var cnpjController = new TextEditingController();
var enderecoController = new TextEditingController();

//promocao
var nomePromocaoController = new TextEditingController();
var lojaController = new TextEditingController();
var precoAtualController = new TextEditingController();
var precoOriginalController = new TextEditingController();
var fotoController = new TextEditingController();
var ativoController = new TextEditingController();
var latitudeController = new TextEditingController();
var longitudeController = new TextEditingController();

class cadastroLoja extends StatefulWidget {
  @override
  _cadastroLojaState createState() => _cadastroLojaState();
}

class _cadastroLojaState extends State<cadastroLoja> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastrar promoção"),
      ),
      body: Container(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15),
              child: TextField(
                controller: nomeEmpresaController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: "Nome da empresa",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: TextField(
                controller: cnpjController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: "CNPJ",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: TextField(
                controller: enderecoController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: "Endereço",
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          if (verificaSeCamposEstaoPreenchidosLoja()) {
            cadastraLoja();
            limpaTudo();
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

void cadastraLoja() {
  String nome = nomeEmpresaController.text;
  String endereco = enderecoController.text;
  int cnpj = int.parse(cnpjController.text);
  double latitude = 0;
  double longitude = 0;

  Loja novaLoja = new Loja(nome, endereco, cnpj, latitude, longitude);

  crud.adicionarLoja(novaLoja);
}

class cadastroPromocao extends StatefulWidget {
  String idUsuario;
  String nomeUsuario;

  cadastroPromocao(this.idUsuario, this.nomeUsuario);

  @override
  _cadastroPromocaoState createState() =>
      _cadastroPromocaoState(idUsuario, nomeUsuario);
}

class _cadastroPromocaoState extends State<cadastroPromocao> {
  String categoria = 'Selecione...';
  String idUsuario;
  String nomeUsuario;

  _cadastroPromocaoState(this.idUsuario, this.nomeUsuario);

  void cadastraPromocao(String categoria) {
    String nome = nomePromocaoController.text;
    String loja = nomeUsuario;
    double precoOriginal = double.parse(precoOriginalController.text);
    double precoAtual = double.parse(precoAtualController.text);
    double latitude = double.parse(latitudeController.text);
    double longitude = double.parse(longitudeController.text);
    String foto = fotoController.text;

    Promocao promocao = new Promocao(nome, foto, loja, latitude, longitude,
        precoOriginal, precoAtual, categoria, idUsuario);

    crud.adicionaPromocao(promocao);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
                icon: Icon(FontAwesomeIcons.arrowLeft),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Principal()));
                },
              ),
        title: Text("Cadastrar promoção"),
        
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              campoTexto(nomePromocaoController, 'Nome da promoção'),
              Row(
                children: <Widget>[
                  campoPrecos(precoAtualController, 'Preço Atual'),
                  campoPrecos(precoOriginalController, 'Preço Original'),
                ],
              ),
              campoTexto(fotoController, 'Foto da promoção (URL)'),
              campoTexto(latitudeController, 'Latitude'),
              campoTexto(longitudeController, 'Longitude'),
              DropdownButton(
                isExpanded: true,
                onChanged: (valor) {
                  setState(() {
                    categoria = valor;
                  });
                },
                hint: Text(categoria),
                items: <DropdownMenuItem>[
                  DropdownMenuItem(
                    child: Text('Alimentação'),
                    value: 'Alimentação',
                  ),
                  DropdownMenuItem(
                    child: Text('Conveniências'),
                    value: 'Conveniências',
                  ),
                  DropdownMenuItem(
                    child: Text('Vestuário'),
                    value: 'Vestuário',
                  ),
                  DropdownMenuItem(
                    child: Text('Eletrônicos'),
                    value: 'Eletrônicos',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          if (verificaSeCamposEstaoPreenchidosPromocao(categoria)) {
            cadastraPromocao(categoria);
            limpaTudo();
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

Widget campoTexto(controller, label) {
  return Padding(
    padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
    child: TextField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.fiber_manual_record, color: Color(0xff3f51b5)),
        labelText: label,
      ),
    ),
  );
}

Widget campoPrecos(controller, label) {
  return Flexible(
    child: Padding(
      padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
      child: TextField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        controller: controller,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
        ),
      ),
    ),
  );
}

void limpaTudo() {
  nomeEmpresaController.text = "";
  enderecoController.text = "";
  cnpjController.text = "";
  nomePromocaoController.text = "";
  lojaController.text = "";
  precoAtualController.text = "";
  precoOriginalController.text = "";
  fotoController.text = "";
  ativoController.text = "";
  latitudeController.text = "";
  longitudeController.text = "";
}

bool verificaSeCamposEstaoPreenchidosLoja() {
  if (nomeEmpresaController.text != "" &&
      cnpjController.text != "" &&
      enderecoController.text != "") {
    print("nenhum nulo! Ótimo!");
    return true;
  } else {
    print("Está tudo nulo, ou algum deles está nulo");
    return false;
  }
}

bool verificaSeCamposEstaoPreenchidosPromocao(categoria) {
  if (nomePromocaoController.text != "" &&
      categoria != 'Selecione...' &&
      fotoController.text != "" &&
      precoOriginalController.text != "" &&
      precoAtualController.text != "" &&
      latitudeController.text != "" &&
      longitudeController.text != "") {
    print("nenhum nulo! Ótimo!");
    return true;
  } else {
    print("Está tudo nulo, ou algum deles está nulo");
    return false;
  }
}

class ListaPromocoes extends StatefulWidget {
  @override
  _ListaPromocoesState createState() => _ListaPromocoesState();
}

class _ListaPromocoesState extends State<ListaPromocoes> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ListaDePromosUser extends StatefulWidget {
  String idUser;
  ListaDePromosUser(this.idUser);
  @override
  _ListaDePromosUserState createState() => _ListaDePromosUserState(idUser);
}

class _ListaDePromosUserState extends State<ListaDePromosUser> {
  String idUser;
  _ListaDePromosUserState(this.idUser);

  void _desativaPromocao(String id) {
    DocumentReference db =
        Firestore.instance.collection('promocoes').document(id);
    db.delete();
  }

  StreamBuilder constroiPromocoes() {
    Widget _promoTile(context, document) {
      var data = document.data;
      return Padding(
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
                      image: DecorationImage(
                          image: NetworkImage(data['foto']),
                          fit: BoxFit.cover)),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          Expanded(child: Center(child: Text(data['nome']))),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 100,
                  width: 50,
                  child: Center(
                    child: IconButton(
                        onPressed: () {
                          _desativaPromocao(document.documentID);
                        },
                        icon: Icon(Icons.delete_forever, color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Widget _buildList(context, document) {
    //   return retornaPromocao(
    //       document['nome'],
    //       document['loja'],
    //       double.parse(document['precoOriginal'].toString()),
    //       double.parse(document['precoAtual'].toString()),
    //       NetworkImage(document['foto']),
    //       double.parse(document['latitude'].toString()),
    //       double.parse(document['longitude'].toString()),
    //       context);
    // }

    return StreamBuilder(
      stream: Firestore.instance
          .collection('promocoes')
          .where('usuario', isEqualTo: idUser)
          .where('ativo', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Text("Carregando... Aguarde!");
        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) {
            return _promoTile(context, snapshot.data.documents[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
                icon: Icon(FontAwesomeIcons.arrowLeft),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Principal()));
                },
              ),
        title: Text('Promoções ativas!'),
        centerTitle: true,
      ),
      body: constroiPromocoes(),
    );
  }
}
