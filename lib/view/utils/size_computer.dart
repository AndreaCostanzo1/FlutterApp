

class SizeComputer {

  static final small = 's';
  static final medium = 'm';

  static final Map<double,String> sizes ={
    320: small,
    480: medium,
  };


  static String computeSize(double width){
    for(int i=0; i<sizes.length; i++){
      List<double> sizeValues = sizes.keys.toList();
      if((width/sizeValues[i])<=1)
        return sizes[sizeValues[i]];
    }
    return medium;
  }
}