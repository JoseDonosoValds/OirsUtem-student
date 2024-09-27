// To parse this JSON data, do
//
//     final accesos = accesosFromJson(jsonString);

import 'dart:convert';

List<Accesos> accesosFromJson(String str) => List<Accesos>.from(json.decode(str).map((x) => Accesos.fromJson(x)));

String accesosToJson(List<Accesos> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Accesos {
    String ip;
    String userAgent;
    String requestUri;
    DateTime created;

    Accesos({
        required this.ip,
        required this.userAgent,
        required this.requestUri,
        required this.created,
    });

    factory Accesos.fromJson(Map<String, dynamic> json) => Accesos(
        ip: json["ip"],
        userAgent: json["userAgent"],
        requestUri: json["requestUri"],
        created: DateTime.parse(json["created"]),
    );

    Map<String, dynamic> toJson() => {
        "ip": ip,
        "userAgent": userAgent,
        "requestUri": requestUri,
        "created": created.toIso8601String(),
    };
}
