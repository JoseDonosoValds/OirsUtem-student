import 'dart:convert';

Ticket TicketFromJson(String str) =>
    Ticket.fromJson(json.decode(str));

String TicketToJson(Ticket data) => json.encode(data.toJson());

class Ticket {
  String type;
  String subject;
  String message;
  Category category;
  String token;
  String status;
  String? response; // response es opcional
  List<String>? attachedTokens; // attachedTokens es opcional
  DateTime created;
  DateTime updated;

  Ticket({
    required this.type,
    required this.subject,
    required this.message,
    required this.category,
    required this.token,
    required this.status,
    this.response, // opcional
    this.attachedTokens, // opcional
    required this.created,
    required this.updated,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        type: json["type"],
        subject: json["subject"],
        message: json["message"],
        category: Category.fromJson(json["category"]),
        token: json["token"],
        status: json["status"],
        response: json["response"], // Puede ser null si no existe
        attachedTokens: json["attachedTokens"] != null
            ? List<String>.from(json["attachedTokens"].map((x) => x))
            : null, // Si no existe, será null
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
        "response": response, // Se incluirá solo si tiene valor
        "attachedTokens": attachedTokens != null
            ? List<dynamic>.from(attachedTokens!.map((x) => x))
            : null, // Se incluirá solo si tiene valor
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
