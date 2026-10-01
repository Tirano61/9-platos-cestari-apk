import 'package:cuatro_platos/BaseDeDatos/connections/db_conexion.dart';
import 'package:cuatro_platos/BaseDeDatos/helpers/settings/first_data.dart';
import 'package:cuatro_platos/BaseDeDatos/services/settings/service_config.dart';
import 'package:cuatro_platos/Controllers/config_controller.dart';
import 'package:cuatro_platos/Controllers/ejes_controller.dart';
import 'package:cuatro_platos/Controllers/multi_ejes_controller.dart';
import 'package:cuatro_platos/Controllers/peso1_controller.dart';
import 'package:cuatro_platos/Pages/Home/homePage.dart';
import 'package:cuatro_platos/Pages/cuatro_platos/cuatro_platos_page.dart';
import 'package:cuatro_platos/Pages/pesadas/pesadas_page.dart';
import 'package:cuatro_platos/Pages/por_ejes/por_multi_ejes_page.dart';
import 'package:cuatro_platos/Pages/por_ejes/por_ejes_page.dart';
import 'package:cuatro_platos/config/SizeScreen.dart';
import 'package:cuatro_platos/config/theme.dart';
import 'package:cuatro_platos/generated/l10n.dart';
import 'package:cuatro_platos/models/config_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'Controllers/peso2_controller.dart';
import 'Controllers/peso3_controller.dart';
import 'Controllers/peso4_controller.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
   const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final puertos =  Get.put(ConfigController());
  final peso1 =  Get.put(Peso1Controller());
  final peso2 =  Get.put(Peso2Controller());
  final peso3 =  Get.put(Peso3Controller());
  final peso4 =  Get.put(Peso4Controller());
  final ejes  =  Get.put(EjesController());
  final multiEjes2 = Get.put(MultiEjesController(numEjes: 2), tag: '2ejes');
  final multiEjes3 = Get.put(MultiEjesController(numEjes: 3), tag: '3ejes');
  final multiEjes4 = Get.put(MultiEjesController(numEjes: 4), tag: '4ejes');
  final multiEjes5 = Get.put(MultiEjesController(numEjes: 5), tag: '5ejes');
  final multiEjes6 = Get.put(MultiEjesController(numEjes: 6), tag: '6ejes');

  @override
  void initState() {
    super.initState();
    getConfig();
    
    FlutterNativeSplash.remove();
  }
  
  isAnchoScreen(BuildContext context){
    if(SizeScreen.minWidth > MediaQuery.of(context).size.width) return false;
    return true;
  }
  getConfig()async{
   
    final service = ServiceConfig(DBconeccion.db);  
    final resp = await service.getConfig();
   
    if(resp.isEmpty){ 
      const puerto = Puertos.puerto;
      final config = ConfigModel(
        plato1: puerto.puerto1,
        plato2: puerto.puerto2,
        plato3: puerto.puerto3,
        plato4: puerto.puerto4,
        connectionType: ConnectionType.udp,
      );
      final service = ServiceConfig(DBconeccion.db);
      await service.insertarConfig(config);
    }else{
      puertos.setPuerto1(resp[0].plato1);
      puertos.setPuerto2(resp[0].plato2);
      puertos.setPuerto3(resp[0].plato3);
      puertos.setPuerto4(resp[0].plato4);
      puertos.setConnectionType(resp[0].connectionType);
      puertos.setPlato1BleName(resp[0].plato1BleName);
      puertos.setPlato2BleName(resp[0].plato2BleName);
      puertos.setPlato3BleName(resp[0].plato3BleName);
      puertos.setPlato4BleName(resp[0].plato4BleName);
    }

    peso1.recibirPeso1();
    peso2.recibirPeso2();
    peso3.recibirPeso3();
    peso4.recibirPeso4();
  }

  @override
  Widget build(BuildContext context) {
    final screen = isAnchoScreen(context);
    final width = MediaQuery.of(context).size.width;
    SizeScreen.sc().setMinWidth(screen);
    SizeScreen.sc().setSreenWidth(width);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        S.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,

      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: ThemeApp.colorTituloPlatos,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold) 
        ),
        iconButtonTheme: IconButtonThemeData(          
          style: ButtonStyle(         
            backgroundColor: WidgetStateProperty.resolveWith((state){
              if(state.contains(WidgetState.pressed)){
                return ThemeApp.colorPesoPlatos;
              }
              return Colors.transparent;
            })
          ),
        ),
        iconTheme: const IconThemeData(
          color: ThemeApp.colorTituloPlatos,
        )
      ),
      title: 'Cuatro Platos',
      home:  const HomePage(),
      routes: {
        'home'    : (context) => const HomePage(),
        'pesadas' : (context) => PesadasPage(),
        'platos'  : (context) => CuatroPlatosPage(),
        'ejes'    : (context) => PorEjesPage(),
        'ejes2'   : (context) => PorMultiEjesPage(numEjes: 2, title: 'Pesaje Por Ejes', controllerTag: '2ejes'),
        'ejes3'   : (context) => PorMultiEjesPage(numEjes: 3, title: 'Pesaje Por 3 Ejes', controllerTag: '3ejes'),
        'ejes4'   : (context) => PorMultiEjesPage(numEjes: 4, title: 'Pesaje Por 4 Ejes', controllerTag: '4ejes'),
        'ejes5'   : (context) => PorMultiEjesPage(numEjes: 5, title: 'Pesaje Por 5 Ejes', controllerTag: '5ejes'),
        'ejes6'   : (context) => PorMultiEjesPage(numEjes: 6, title: 'Pesaje Por 6 Ejes', controllerTag: '6ejes'),
      }
    );
  }
}

