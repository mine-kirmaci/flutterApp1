class AdressComponent{
  final String longName;
  final String shortName;
  final List<String> types;

  AdressComponent({
    required this.longName,
    required this.shortName,
    required this.types
  });

  factory AdressComponent.fromJson(Map<String, dynamic> json){
    return AdressComponent(
        longName: json['long_name'],
        shortName: json['short_name'],
        types: List<String>.from(json['types'])
    );
  }
}