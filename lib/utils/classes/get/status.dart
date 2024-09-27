// To parse this JSON data, do
//
//     final status = statusFromJson(jsonString);

import 'dart:convert';

List<String> statusFromJson(String str) =>
    List<String>.from(json.decode(str).map((x) => x));

String statusToJson(List<String> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x)));
