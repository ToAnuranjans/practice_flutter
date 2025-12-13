// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
  json['street'] as String,
  json['city'] as String,
  json['stateCode'] as String,
  json['countryName'] as String,
  json['zipcode'] as String,
);

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
  'street': instance.street,
  'city': instance.city,
  'stateCode': instance.state,
  'countryName': instance.country,
  'zipcode': instance.pincode,
};
