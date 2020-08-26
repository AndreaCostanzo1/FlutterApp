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
  final int _likes;
  final int _searches;
  final Map<String, dynamic> _ratingsByRate;
  final int _totalRatings;

  Beer.nullBeer()
      : _id = '',
        _name = '',
        _producer = '',
        _rating = 0,
        _alcohol = 0,
        _temperature = 0,
        _beerImageUrl = '',
        _style = '',
        _color = '',
        _carbonation = 0,
        _likes = 0,
        _searches = 0,
        _ratingsByRate = Map(),
        _totalRatings = 0;

  Beer.fromSnapshot(Map<String, dynamic> snapshot)
      : _id = snapshot['id'],
        _name = snapshot['name'],
        _producer = snapshot['producer'],
        _rating = ((snapshot['rating'] ?? 0).toDouble() * 10).round() / 10,
        _alcohol = (snapshot['alcohol'] ?? 0.0).toDouble(),
        _temperature = (snapshot['temperature'] ?? 0).toDouble(),
        _beerImageUrl = snapshot['imageUrl'],
        _style = snapshot['style'],
        _color = snapshot['color'],
        _carbonation = (snapshot['carbonation'] ?? 0.0).toDouble(),
        _likes = snapshot['likes'],
        _searches = snapshot['searches'],
        _ratingsByRate = snapshot['ratings_by_rate'],
        _totalRatings = snapshot['total_ratings'];

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
        _carbonation = beer.carbonation,
        _searches = beer.searches,
        _likes = beer.likes,
        _ratingsByRate = beer.ratingsByRate
            .map((key, value) => MapEntry(key.toString(), value)),
        _totalRatings = beer.totalRatings;

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

  int get searches => _searches;

  int get likes => _likes;

  Map<int, int> get ratingsByRate =>
      _ratingsByRate.map((key, value) => MapEntry(int.parse(key), value));

  int get totalRatings => _totalRatings;

  @override
  String toString() {
    return this.toJson().toString();
  }

  Map<String, dynamic> toJson() {
    return Map.from({
      'id': _id,
      'name': _name,
      'producer': _producer,
      'rating': _rating.toString(),
      'alcohol': _alcohol.toString(),
      'temperature': _temperature.toString(),
      'beerImageUrl': _beerImageUrl,
      'style': _style,
      'color': _color,
      'carbonation': _carbonation,
      'searches': _searches,
      'likes': _likes,
    });
  }
}
