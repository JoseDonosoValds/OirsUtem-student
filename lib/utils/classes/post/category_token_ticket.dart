// To parse this JSON data, do
//
//     final CategoryTokenTicketPost = CategoryTokenTicketPostFromJson(jsonString);

import 'dart:convert';

CategoryTokenTicketPost categoryTokenTicketPostFromJson(String str) => CategoryTokenTicketPost.fromJson(json.decode(str));

String categoryTokenTicketPostToJson(CategoryTokenTicketPost data) => json.encode(data.toJson());

class CategoryTokenTicketPost {
    String type;
    String subject;
    String message;

    CategoryTokenTicketPost({
        required this.type,
        required this.subject,
        required this.message,
    });

    factory CategoryTokenTicketPost.fromJson(Map<String, dynamic> json) => CategoryTokenTicketPost(
        type: json["type"],
        subject: json["subject"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "subject": subject,
        "message": message,
    };
}

// To parse this JSON data, do
//
//     final CategoryTokenTicketPostResponse = CategoryTokenTicketPostResponseFromJson(jsonString); código 201, lo demás parse status.


CategoryTokenTicketPostResponse categoryTokenTicketPostResponseFromJson(String str) => CategoryTokenTicketPostResponse.fromJson(json.decode(str));

String categoryTokenTicketPostResponseToJson(CategoryTokenTicketPostResponse data) => json.encode(data.toJson());

class CategoryTokenTicketPostResponse {
    bool success;
    String token;
    String detail;
    DateTime date;

    CategoryTokenTicketPostResponse({
        required this.success,
        required this.token,
        required this.detail,
        required this.date,
    });

    factory CategoryTokenTicketPostResponse.fromJson(Map<String, dynamic> json) => CategoryTokenTicketPostResponse(
        success: json["success"],
        token: json["token"],
        detail: json["detail"],
        date: DateTime.parse(json["date"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "token": token,
        "detail": detail,
        "date": date.toIso8601String(),
    };
}
