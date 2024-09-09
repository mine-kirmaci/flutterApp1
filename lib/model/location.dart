class Location{
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng
  });

  factory Location.fromJson(Map<String, dynamic> json){
    return Location(
        lat: json['lat'],
        lng: json['lng']
    );
  }
}

class Viewport{
  final Location northeast;
  final Location southwest;

  Viewport({
    required this.northeast,
    required this.southwest
  });

  factory Viewport.fromJson(Map<String, dynamic> json){
    return Viewport(
        northeast: Location.fromJson(json['northeast']),
        southwest: Location.fromJson(json['southwest'])
    );
  }
}

class Geometry{
  final Location location;
  final String locationType;
  final Viewport viewport;

  Geometry({
    required this.location,
    required this.locationType,
    required this.viewport
  });

  factory Geometry.fromJson(Map<String, dynamic> json){
    return Geometry(
        location: Location.fromJson(json['location']),
        locationType: json['location_type'],
        viewport: Viewport.fromJson(json['viewport'])
    );
  }
}