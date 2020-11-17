import 'package:finacash/screen/InicialPage.dart';
import 'package:finacash/screen/camara.dart';
import 'package:finacash/screen/voz.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

main() {
  initializeDateFormatting().then((_) {
    runApp(MaterialApp(
      initialRoute: '/',
      routes: {
        '/' : (BuildContext context)=>InicialPage(),
        'camara' : (BuildContext context)=>CamaraPage(),
        'voz'    : (BuildContext context)=>VoicePage(),
      },
      debugShowCheckedModeBanner: false,
    ));
  });
}
