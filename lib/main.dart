import 'package:nueve_platos_cestari/BaseDeDatos/connections/db_conexion.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/helpers/settings/first_data.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/services/settings/service_config.dart';
import 'package:nueve_platos_cestari/Controllers/config_controller.dart';
import 'package:nueve_platos_cestari/Controllers/ensayo_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso_controller.dart';
import 'package:nueve_platos_cestari/Pages/Home/homePage.dart';
import 'package:nueve_platos_cestari/Pages/ensayos/ensayos_page.dart';
import 'package:nueve_platos_cestari/Pages/inicio_ensayo/inicio_ensayo_page.dart';
import 'package:nueve_platos_cestari/Pages/nueve_platos/nueve_platos_page.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:nueve_platos_cestari/generated/l10n.dart';
import 'package:nueve_platos_cestari/models/config_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

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
  final ensayo = Get.put(EnsayoController());
  late final List<PesoController> platos;

  @override
  void initState() {
    super.initState();
    platos = [
      for (var n = 1; n <= puertos.cantidadPlatos; n++)
        Get.put(PesoController(plato: n), tag: 'plato$n'),
    ];
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
      final config = ConfigModel(puertos: puertosPorDefecto);
      final service = ServiceConfig(DBconeccion.db);
      await service.insertarConfig(config);
    }else{
      puertos.setPuertos(resp[0].puertos);
    }

    for (final plato in platos) {
      plato.recibirPeso();
    }
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
      title: 'Platos Cestari',
      home:  const HomePage(),
      routes: {
        'home'    : (context) => const HomePage(),
        'ensayos' : (context) => const EnsayosPage(),
        'platos'  : (context) => NuevePlatosPage(),
        'inicioEnsayo' : (context) => const InicioEnsayoPage(),
      }
    );
  }
}

