
class Beer {
  final String _id;
  final String _name;
  final String _producer;
  final double _rating;
  final double _alcohol;
  final double _temperature;
  final String _beerImageUrl;
  final String _style;
  final String _color;
  final double _carbonation;

  Beer.fromSnapshot(Map<String, dynamic> snapshot)
      : _id = snapshot['id'],
        _name = snapshot['name'],
        _producer = snapshot['producer'],
        _rating = ((snapshot['rating'] ?? 0).toDouble()*10).round() / 10,
        _alcohol = (snapshot['alcohol'] ?? 0.0).toDouble(),
        _temperature = (snapshot['temperature'] ?? 0).toDouble(),
        _beerImageUrl = snapshot['imageUrl'],
        _style = snapshot['style'],
        _color = snapshot['color'],
        _carbonation = (snapshot['carbonation'] ?? 0.0).toDouble();

  Beer.fromBeer(Beer beer)
      : _id = beer.id,
        _name = beer.name,
        _producer = beer.producer,
        _rating = beer.rating,
        _alcohol = beer.alcohol,
        _temperature = beer.temperature,
        _beerImageUrl = beer.beerImageUrl,
        _style = beer.style,
        _color = beer.color,
        _carbonation = beer.carbonation;

  String get id => _id;

  String get name => _name;

  String get producer => _producer;

  double get rating => _rating;

  double get alcohol => _alcohol;

  double get temperature => _temperature;

  String get beerImageUrl => _beerImageUrl;

  String get style => _style;

  String get color => _color;

  double get carbonation => _carbonation;

}
