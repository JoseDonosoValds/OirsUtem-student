// To parse this JSON data, do
//
//     final types = typesFromJson(jsonString);

import 'dart:convert';

List<String> typesFromJson(String str) => List<String>.from(json.decode(str).map((x) => x));

String typesToJson(List<String> data) => json.encode(List<dynamic>.from(data.map((x) => x)));
