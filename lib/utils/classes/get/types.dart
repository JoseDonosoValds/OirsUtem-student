// To parse this JSON data, do
//
//     final types = typesFromJson(jsonString);

import 'dart:convert';

List<Types> typesFromJson(String str) =>
    List<Types>.from(json.decode(str).map((x) => Types.fromJson(x)));

String typesToJson(List<Types> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Types {
  String token;
  String name;
  String description;

  Types({
    required this.token,
    required this.name,
    required this.description,
  });

  factory Types.fromJson(Map<String, dynamic> json) => Types(
        token: json["token"],
        name: json["name"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "name": name,
        "description": description,
      };
}
