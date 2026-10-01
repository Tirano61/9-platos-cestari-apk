



enum Puertos {
  puerto(puerto1:"8001", puerto2:'8002', puerto3:'8003',puerto4:'8004');
  
  final String puerto1;
  final String puerto2;
  final String puerto3;
  final String puerto4;
  const Puertos({required this.puerto1, required this.puerto2, required this.puerto3, required this.puerto4});
}