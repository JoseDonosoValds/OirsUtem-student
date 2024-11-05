import 'dart:convert';

ErrorStatus errorStatusFromJson(String str) => ErrorStatus.fromJson(json.decode(str));

String errorStatusToJson(ErrorStatus data) => json.encode(data.toJson());

class ErrorStatus {
    String type;
    String title;
    int status;
    String detail;
    String instance;
    Properties? properties; // Cambiado para permitir null

    ErrorStatus({
        required this.type,
        required this.title,
        required this.status,
        required this.detail,
        required this.instance,
        this.properties, // Cambiado para ser opcional
    });

    factory ErrorStatus.fromJson(Map<String, dynamic> json) => ErrorStatus(
        type: json["type"],
        title: json["title"],
        status: json["status"],
        detail: json["detail"],
        instance: json["instance"],
        properties: json["properties"] != null ? Properties.fromJson(json["properties"]) : null, // Manejo de null
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "title": title,
        "status": status,
        "detail": detail,
        "instance": instance,
        if (properties != null) "properties": properties!.toJson(), // Solo añadir si no es null
    };
}

class Properties {
    AdditionalProp? additionalProp1;
    AdditionalProp? additionalProp2;
    AdditionalProp? additionalProp3;

    Properties({
        this.additionalProp1,
        this.additionalProp2,
        this.additionalProp3,
    });

    factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        additionalProp1: json["additionalProp1"] != null ? AdditionalProp.fromJson(json["additionalProp1"]) : null,
        additionalProp2: json["additionalProp2"] != null ? AdditionalProp.fromJson(json["additionalProp2"]) : null,
        additionalProp3: json["additionalProp3"] != null ? AdditionalProp.fromJson(json["additionalProp3"]) : null,
    );

    Map<String, dynamic> toJson() => {
        if (additionalProp1 != null) "additionalProp1": additionalProp1!.toJson(),
        if (additionalProp2 != null) "additionalProp2": additionalProp2!.toJson(),
        if (additionalProp3 != null) "additionalProp3": additionalProp3!.toJson(),
    };
}

class AdditionalProp {
    AdditionalProp();

    factory AdditionalProp.fromJson(Map<String, dynamic> json) => AdditionalProp();

    Map<String, dynamic> toJson() => {};
}
