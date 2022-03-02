enum BedStatus{
  Booked,
  Available,
  InProgress,
}

BedStatus fromString(String enumStr) {
  if(enumStr == 'booked') {
    return BedStatus.Booked;
  } else if (enumStr == 'available') {
    return BedStatus.Available;
  } else {
    return BedStatus.InProgress;
  }
}

String toString(BedStatus status) {
  if (status == BedStatus.Booked) {
    return 'booked';
  } else if (status == BedStatus.Available) {
    return 'available';
  } else {
    return 'in_progress';
  }
}

class Bed {
  int id;
  BedStatus status;
  String clientId;
  String clientName;

  Bed(this.id, this.status, this.clientId, this.clientName);

  Map<String, dynamic> toJson() => {
    'id': id,
    'bed_status': toString(status),
    'client_id': clientId,
    'client_name': clientName
  };

  Bed._internalFromJson(Map jsonMap)
      : id = jsonMap['id']?.toInt() ?? '',
        status = fromString(jsonMap['bed_status']?.toString() ?? 'available'),
        clientId = jsonMap['client_id']?.toString() ?? '',
        clientName = jsonMap['client_name']?.toString() ?? '';

  factory Bed.fromJson(Map jsonMap) => Bed._internalFromJson(jsonMap);

}