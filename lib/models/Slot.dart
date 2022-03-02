enum SlotStatus{
  Booked,
  Available,
  InProgress,
}

SlotStatus slotStatusFromString(String enumStr) {
  if(enumStr == 'booked') {
    return SlotStatus.Booked;
  } else if (enumStr == 'available') {
    return SlotStatus.Available;
  } else {
    return SlotStatus.InProgress;
  }
}

String slotStatusToString(SlotStatus status) {
  if (status == SlotStatus.Booked) {
    return 'booked';
  } else if (status == SlotStatus.Available) {
    return 'available';
  } else {
    return 'in_progress';
  }
}

class Slot {
  int id;
  SlotStatus status;
  String userId;
  String userName;
  int rate;

  Slot(this.id, this.status, this.userId, this.userName,
      this.rate);

  Map<String, dynamic> toJson() => {
    'id': id,
    'slot_status': slotStatusToString(status),
    'user_id': userId,
    'user_name': userName,
    'rate': rate,
  };

  Slot._internalFromJson(Map jsonMap)
      : id = jsonMap['id']?.toInt() ?? '',
        status = slotStatusFromString(jsonMap['slot_status']?.toString() ?? 'available'),
        userId = jsonMap['user_id']?.toString() ?? '',
        userName = jsonMap['user_name']?.toString() ?? '',
        rate = jsonMap['rate']?.toInt() ?? 0;

  factory Slot.fromJson(Map jsonMap) => Slot._internalFromJson(jsonMap);

}