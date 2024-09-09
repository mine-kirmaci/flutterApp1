import 'address_component.dart';
import 'geometry.dart';
import 'plus_code.dart';


class Result{
  final List<AdressComponent> addressComponents;
  final String formattedAddress;
  final Geometry geometry;
  final String placeId;
  final PlusCode plusCode;
  final List<String> types;

  Result({
    required this.addressComponents,
    required this.formattedAddress,
    required this.geometry,
    required this.placeId,
    required this.plusCode,
    required this.types
  });

  factory Result.fromJson(Map<String, dynamic> json){
    var addressComponentsJson = json['address_components'] as List;
    var addressComponents = addressComponentsJson.map((e) => AdressComponent.fromJson(e)).toList();

    return Result(
        addressComponents: addressComponents,
        formattedAddress: json['formatted_address'],
        geometry: Geometry.fromJson(json['geometry']),
        placeId: json['place_id'],
        plusCode: PlusCode.fromJson(json['plus_code']),
        types: List<String>.from(json['types'])
    );
  }
}