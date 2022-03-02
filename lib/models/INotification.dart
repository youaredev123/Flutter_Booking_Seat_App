class INotification {
  String id;
  String clubId;
  String phoneNumber;
  bool checked;

  INotification(this.id, this.clubId, this.phoneNumber, this.checked);

  Map<String, dynamic> toJson() => {
    'id': id,
    'club_id': clubId,
    'phone_number': phoneNumber,
    'checked': checked
  };
  INotification._internalFromJson(Map jsonMap)
   : id =jsonMap['id'].toString(),
     clubId = jsonMap['club_id'].toString(),
     phoneNumber = jsonMap['phone_number'].toString(),
     checked = jsonMap['checked'] as bool;

  factory INotification.fromJson(Map jsonMap) => INotification._internalFromJson(jsonMap);
}