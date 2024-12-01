// To parse this JSON data, do
//
//     final categoryTicketTypes = categoryTicketTypesFromJson(jsonString);

import 'dart:convert';

CategoryTicketTypes categoryTicketTypesFromJson(String str) => CategoryTicketTypes.fromJson(json.decode(str));

String categoryTicketTypesToJson(CategoryTicketTypes data) => json.encode(data.toJson());

class CategoryTicketTypes {
    String token;
    String name;
    String description;

    CategoryTicketTypes({
        required this.token,
        required this.name,
        required this.description,
    });

    factory CategoryTicketTypes.fromJson(Map<String, dynamic> json) => CategoryTicketTypes(
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
