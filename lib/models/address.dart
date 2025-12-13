import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address {
  String street;
  String city;
  @JsonKey(name: 'stateCode')
  String state;
  @JsonKey(name: 'countryName')
  String country;
  @JsonKey(name: 'zipcode')
  String pincode;

  Address(this.street, this.city, this.state, this.country, this.pincode);

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);
}
