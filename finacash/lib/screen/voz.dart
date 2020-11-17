
import 'package:finacash/Widgets/CustomDialogVoz.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
// import 'package:parcial1_sw1/login_state.dart';
// import 'package:provider/provider.dart';
//import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoicePage extends StatefulWidget { 
  @override
  _VoicePageState createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Presiona el boton e indica cuánto y en qué gastaste ahora: ';
  DateTime date = DateTime.now();

  @override
  initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ingresa por Voz"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: Duration(milliseconds: 2000),
        repeatPauseDuration: Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: Text(
            _text,
            //  words: _highlights,
            style: TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void _voiceDialog(String categoria, double valor) {
    showCupertinoDialog(
        barrierDismissible: false,
        context: context,
        builder: (buildcontext) {
          return AlertDialog(
            title: Text("Desea registrar un gasto de: Bs. $valor en $categoria ?"),
            actions: <Widget>[
              RaisedButton(
                color: Colors.blueAccent,
                child: Text(
                  "Aceptar",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  // if (valor > 0 && categoria != "") {
                  //   Firestore.instance
                  //   .collection('gasto')
                  //   .document().setData({
                  //     "categoria": categoria,
                  //     "valor": valor,
                  //     "mes": date.month,
                  //     "dia": date.day,
                  //   });
                  // }
                  _dialogAddVoz(categoria,valor);
                  // Navigator.of(context).pop();
                  // Navigator.of(context).pop();
                },
              ),
              RaisedButton(
                color: Colors.blueAccent,
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void _showDialog(String text) {
    // flutter defined function
    showCupertinoDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Error"),
          content: new Text("Ingresa un$text"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool disponible = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (disponible) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = '-Tu: ' + val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      print(_text);

      //sacar monto de _text
      // var intRegex = RegExp(r'(\d+)', multiLine: true);
      // String valorS = intRegex.firstMatch(_text).group(0);
      var intRegex = RegExp(r'(\d+)', multiLine: true);
      String valorS = intRegex.stringMatch(_text);

      double monto = 0;
      if (valorS != null) {
        monto = double.parse(valorS);
        print(monto);
      }

      //identificar categorias
      String com1 = "Comida";
      String com2 = "pollo";
      String com3 = "hamburguesa";
      String com4 = "pizza";

      String ser1 = "Servicios";
      String ser2 = "luz";
      String ser3 = "agua";
      String ser4 = "gas";

      String beb1 = "Bebida";
      String beb2 = "soda";
      String beb3 = "cerveza";
      String beb4 = "loquillo";

      //captura las Comidas
      var comRegex = RegExp(
          "\\b(\w*$com1\w*)|(\w*$com2\w*)|(\w*$com3\w*)|(\w*$com4\w*)\\b",
          caseSensitive: false);
      
      //captura los Servicios
      var serRegex = RegExp(
          "\\b(\w*$ser1\w*)|(\w*$ser2\w*)|(\w*$ser3\w*)|(\w*$ser4\w*)\\b",
          caseSensitive: false);

      //captura las bebidas
      var bebRegex = RegExp(
          "\\b(\w*$beb1\w*)|(\w*$beb2\w*)|(\w*$beb3\w*)|(\w*$beb4\w*)\\b",
          caseSensitive: false);

      //  print (comRegex.stringMatch(_text));
      //  print (serRegex.stringMatch(_text));
      if (monto > 0) {
        if (comRegex.hasMatch(_text)) {
          print(com1);
          _voiceDialog(com1, monto);
        } else if (serRegex.hasMatch(_text)) {
          print(ser1);
          _voiceDialog(ser1, monto);
        } else if (bebRegex.hasMatch(_text)) {
          print(beb1);
          _voiceDialog(beb1, monto);
        } else {
          _showDialog("a categoria");
        }
      } else {
        _showDialog(" valor");
      }

      //alert
      // _showAlertDialog();
    }
  }
  _dialogAddVoz(String categoria,double valor) {
    showDialog(
        context: context,
        builder: (context) {
          return CustomDialogVoz(categoria:categoria,valor:valor);
        });
  }
}
