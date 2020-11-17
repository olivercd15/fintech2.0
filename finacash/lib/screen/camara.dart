import 'dart:io';
import 'package:finacash/Widgets/CustomDialogVoz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
// import 'package:parcial1_sw1/login_state.dart';
// import 'package:provider/provider.dart';

class CamaraPage extends StatefulWidget {
  CamaraPage({Key key}) : super(key: key);

  @override
  _CamaraPageState createState() => _CamaraPageState();
}

class _CamaraPageState extends State<CamaraPage> {
  File pickedImage;
  bool isImageLoaded = false;
  DateTime date = DateTime.now();

  pickImage() async {
    // ignore: deprecated_member_use
    File tempStore = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = tempStore;
      isImageLoaded = true;
    });
  }

  Future readText() async {
    bool haytotal = false;
    bool existeComida = false;
    bool existeServicio = false;
    bool existeBebida = false;

    //identificar categorias
    String com1 = "Comida";
    String com2 = "pollo";
    String com3 = "hamburguesa";
    String com4 = "pan";

    String ser1 = "Servicios";
    String ser2 = "luz";
    String ser3 = "agua";
    String ser4 = "gas";

    String beb1 = "Bebida";
    String beb2 = "coca";
    String beb3 = "cerveza";
    String beb4 = "vino";

    //String tot = "total";
    String nuevoS = "";
    double valorS = 0;

    var comRegex = RegExp(
        "\\b(\w*$com1\w*)|(\w*$com2\w*)|(\w*$com3\w*)|(\w*$com4\w*)\\b",
        caseSensitive: false);
    var serRegex = RegExp(
        "\\b(\w*$ser1\w*)|(\w*$ser2\w*)|(\w*$ser3\w*)|(\w*$ser4\w*)\\b",
        caseSensitive: false);
    var bebRegex = RegExp(
        "\\b(\w*$beb1\w*)|(\w*$beb2\w*)|(\w*$beb3\w*)|(\w*$beb4\w*)\\b",
        caseSensitive: false);

    var totalRegex = RegExp("\\b(T[ouOU]T[a@A][l1L])", caseSensitive: false);

    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          print(word.text);
          
          if (comRegex.hasMatch(word.text)) {
            existeComida = true;
          }
          if (serRegex.hasMatch(word.text)) {
            existeServicio = true;
          }
          if (bebRegex.hasMatch(word.text)) {
            existeBebida = true;
          }
          if (totalRegex.hasMatch(word.text) || haytotal) {
            // print(word.text);
            if (!haytotal) {
              haytotal = true;
            } else {
              if (existeComida) {
                nuevoS = word.text.replaceAll(new RegExp(r','), '.');
                valorS = double.parse(nuevoS);

                print(valorS);
                print("Comida");
                _textDialog("Comida", valorS);
                haytotal = false;

              } else if (existeServicio) {
                nuevoS = word.text.replaceAll(new RegExp(r','), '.');
                valorS = double.parse(nuevoS);

                print(valorS);
                print("Servicio");
                _textDialog("Servicio", valorS);
                haytotal = false;

              } else if (existeBebida) {
                nuevoS = word.text.replaceAll(new RegExp(r','), '.');
                valorS = double.parse(nuevoS);

                print(valorS);
                print("Bebida");
                _textDialog("Bebida", valorS);
                haytotal = false;
              }
            }
          } // IF */
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Ingresar por Imagen"),
        ),
        body: Column(
          children: <Widget>[
            SizedBox(height: 100.0),
            isImageLoaded
                ? Center(
                    child: Container(
                        height: 200.0,
                        width: 200.0,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(pickedImage),
                                fit: BoxFit.cover))),
                  )
                : Container(),
            SizedBox(height: 10.0),
            RaisedButton(
              color: Colors.blueAccent,
              child: Text(
                'Elige una imagen de tu Galeria',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: pickImage,
            ),
            SizedBox(height: 10.0),
            RaisedButton(
              color: Colors.blueAccent,
              child: Text(
                'Analizar Texto',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: readText,
            ),
          ],
        ));
  }

  void _textDialog(String categoria, double valor) {
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
                  //var user = Provider.of<LoginState>(context, listen: false).currentUser();
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
                  // Navigator.of(context).pop();
                  // Navigator.of(context).pop();
                  _dialogAdd(categoria,valor);
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

  _dialogAdd(String categoria,double valor) {
    showDialog(
        context: context,
        builder: (context) {
          return CustomDialogVoz(categoria:categoria,valor:valor);
        });
  }
}