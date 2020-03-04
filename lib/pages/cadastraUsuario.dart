import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:promoon/main.dart';
import 'package:promoon/database/database_helper.dart';
import 'package:promoon/database/entidades.dart';
import 'package:promoon/pages/login.dart';

CrudFirestore crud = new CrudFirestore();

//usuario
var nomeUsuarioController = new TextEditingController();
var celularController = new TextEditingController();
var emailController = new TextEditingController();
var senhaController = new TextEditingController();

class CadastraUsuario extends StatefulWidget {
  @override
  _CadastraUsuarioState createState() => _CadastraUsuarioState();
}

class _CadastraUsuarioState extends State<CadastraUsuario> {
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  String nome, email, celular, senha, _mensagem = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        backgroundColor: Color(0xff3f50b5),
        body: Padding(
          padding: EdgeInsets.only(top: 40, left: 40, right: 40),
          child: new Container(
            child: new Form(
              key: _key,
              autovalidate: _validate,
              child: _formUI(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formUI() {
    return new Column(
      children: <Widget>[
        SizedBox(
          width: 128,
          height: 128,
          child: Image.network(
            'https://i.pravatar.cc/100',
          ),
          //  child: Image.asset("images/usuariopadrao.png"),
        ),
        SizedBox(
          height: 20,
        ),
        new TextFormField(
          controller: nomeUsuarioController,
          decoration: new InputDecoration(hintText: 'Nome Completo'),
          maxLength: 40,
          validator: _validarNome,
          onSaved: (String val) {
            nome = val;
          },
        ),
        new TextFormField(
            controller: celularController,
            decoration: new InputDecoration(hintText: 'Celular'),
            keyboardType: TextInputType.phone,
            maxLength: 11,
            validator: _validarCelular,
            onSaved: (String val) {
              celular = val;
            }),
        new TextFormField(
            controller: emailController,
            decoration: new InputDecoration(hintText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            maxLength: 40,
            validator: _validarEmail,
            onSaved: (String val) {
              email = val;
            }),
        new TextFormField(
          controller: senhaController,
          decoration: new InputDecoration(hintText: 'Senha'),
          maxLength: 15,
          validator: _validarSenha,
          onSaved: (String val) {
            senha = val;
          },
        ),
        Container(
          height: 50,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.3, 1],
              colors: [
                Color(0xFFF58524),
                Color(0XFFF92B7F),
              ],
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          child: SizedBox.expand(
            child: FlatButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "CRIAR USUÁRIO",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              onPressed: () {
                _sendForm();
                cadastraUser();
                limpaTudo();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          height: 50,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.3, 1],
              colors: [
                Color(0xFFF58524),
                Color(0XFFF92B7F),
              ],
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          child: SizedBox.expand(
            child: FlatButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "VOLTAR",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                );
              },
            ),
          ),
        ),
        Text(_mensagem),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  String _validarNome(String value) {
    String patttern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Informe o nome";
    } else if (!regExp.hasMatch(value)) {
      return "O nome deve conter caracteres de a-z ou A-Z";
    }
    return null;
  }

  String _validarCelular(String value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Informe o celular";
    } else if (value.length != 11) {
      return "O número deve ter o DDD ex:34";
    } else if (!regExp.hasMatch(value)) {
      return "O número do celular so deve conter dígitos";
    }
    return null;
  }

  String _validarEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "Informe o Email";
    } else if (!regExp.hasMatch(value)) {
      return "Email inválido";
    } else {
      return null;
    }
  }

  /*String _validarSenha(String value) {
    String patttern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Crie a senha";
    } else if (!regExp.hasMatch(value)) {
      return "A senha deve conter caracteres de a-z ou A-Z";
    }
    return null;
  }*/

  String _validarSenha(String value) {
    String patttern = r'(^[a-zA-Z 0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Informe a senha";
    } else if (value.length < 6) {
      return "a senha deve ter no minimo 6 caracteres";
    } else if (!regExp.hasMatch(value)) {
      return "A senha deve conter caracteres de a-z ou A-Z";
    }
    return null;
  }

  void cadastraUser() {
    String nome = nomeUsuarioController.text;
    int celular = int.parse(celularController.text);
    String email = emailController.text;
    String senha = senhaController.text;

    Usuario usuario = new Usuario();
    usuario.nome = nome;
    usuario.celular = celular;
    usuario.email = email;
    usuario.senha = senha;

    if (senhaController.text.length >= 6) {
      FirebaseAuth auth = FirebaseAuth.instance;
      auth
          .createUserWithEmailAndPassword(
              email: usuario.email, password: usuario.senha)
          .then((result) {
        Firestore.instance
            .collection('usuarios')
            .document(result.user.uid)
            .setData(usuario.toMap());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Principal(),
          ),
        );
      }).catchError((e) {
        setState(() {
          print(e);
          _mensagem = "Erro! Verifique os campos e tente novamente!";
        });
      });
    }
  }

  void limpaTudo() {
    nomeUsuarioController.text = "";
    celularController.text = "";
    emailController.text = "";
    senhaController.text = "";
  }

  _sendForm() {
    if (_key.currentState.validate()) {
      // Sem erros na validação
      _key.currentState.save();
      print("Nome $nome");
      print("Celular $celular");
      print("Email $email");
      print("senha $senha");
    } else {
      // erro de validação
      setState(() {
        _validate = true;
      });
    }
  }
}
