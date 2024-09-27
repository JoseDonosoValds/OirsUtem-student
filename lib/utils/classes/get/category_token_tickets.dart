// To parse this JSON data, do
//
//     final categoryTicketPostResponse = categoryTicketPostResponseFromJson(jsonString);

import 'dart:convert';

CategoryTicketPostResponse categoryTicketPostResponseFromJson(String str) => CategoryTicketPostResponse.fromJson(json.decode(str));

String categoryTicketPostResponseToJson(CategoryTicketPostResponse data) => json.encode(data.toJson());

class CategoryTicketPostResponse {
    String type;
    String subject;
    String message;
    Category category;
    String token;
    String status;
    String response;
    List<String> attachedTokens;
    DateTime created;
    DateTime updated;

    CategoryTicketPostResponse({
        required this.type,
        required this.subject,
        required this.message,
        required this.category,
        required this.token,
        required this.status,
        required this.response,
        required this.attachedTokens,
        required this.created,
        required this.updated,
    });

    factory CategoryTicketPostResponse.fromJson(Map<String, dynamic> json) => CategoryTicketPostResponse(
        type: json["type"],
        subject: json["subject"],
        message: json["message"],
        category: Category.fromJson(json["category"]),
        token: json["token"],
        status: json["status"],
        response: json["response"],
        attachedTokens: List<String>.from(json["attachedTokens"].map((x) => x)),
        created: DateTime.parse(json["created"]),
        updated: DateTime.parse(json["updated"]),
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "subject": subject,
        "message": message,
        "category": category.toJson(),
        "token": token,
        "status": status,
        "response": response,
        "attachedTokens": List<dynamic>.from(attachedTokens.map((x) => x)),
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
    };
}

class Category {
    String token;
    String name;
    String description;

    Category({
        required this.token,
        required this.name,
        required this.description,
    });

    factory Category.fromJson(Map<String, dynamic> json) => Category(
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
