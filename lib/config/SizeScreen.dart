

class SizeScreen{

  static final SizeScreen _sizeScreen = SizeScreen._internal();

  SizeScreen._internal();

  factory SizeScreen.sc() => _sizeScreen;

  bool _isMinWidth = false;
  var _screenWidth = 500.0;

  static const minWidth = 420;
  static const minHeight = 900;
  
  get screenWidth{
    return _screenWidth;
  }

  setSreenWidth(double size){
    _screenWidth = size;
  }

  setMinWidth(bool isMin){
    _isMinWidth = isMin;
  }

  get isMinWidth{
    return _isMinWidth;
  }

}