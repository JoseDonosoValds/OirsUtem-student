// enviar datos put
//     final ticketTokenTicket = ticketTokenTicketFromJson(jsonString);

import 'dart:convert';

TicketTokenTicket ticketTokenTicketFromJson(String str) => TicketTokenTicket.fromJson(json.decode(str));

String ticketTokenTicketToJson(TicketTokenTicket data) => json.encode(data.toJson());

class TicketTokenTicket {
    String type;
    String subject;
    String message;

    TicketTokenTicket({
        required this.type,
        required this.subject,
        required this.message,
    });

    factory TicketTokenTicket.fromJson(Map<String, dynamic> json) => TicketTokenTicket(
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
//     final ticketTokenTicketResponse = ticketTokenTicketResponseFromJson(jsonString);

TicketTokenTicketResponse ticketTokenTicketResponseFromJson(String str) => TicketTokenTicketResponse.fromJson(json.decode(str));

String ticketTokenTicketResponseToJson(TicketTokenTicketResponse data) => json.encode(data.toJson());

class TicketTokenTicketResponse {
    bool success;
    String token;
    String detail;
    DateTime date;

    TicketTokenTicketResponse({
        required this.success,
        required this.token,
        required this.detail,
        required this.date,
    });

    factory TicketTokenTicketResponse.fromJson(Map<String, dynamic> json) => TicketTokenTicketResponse(
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

