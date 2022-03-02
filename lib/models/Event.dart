import 'Slot.dart';

enum EventStatus {
  OPENED,
  LOCKED,
  CANCELLED,
}

String eventStatustoString(EventStatus eventStatus) {
  if (eventStatus == EventStatus.LOCKED) {
    return 'locked';
  } else if (eventStatus == EventStatus.CANCELLED) {
    return 'cancelled';
  } else {
    return 'opened';
  }
}

EventStatus eventStatusfromString(String eventStatusStr) {
  if (eventStatusStr == 'locked') {
    return EventStatus.LOCKED;
  } else if (eventStatusStr == 'cancelled') {
    return EventStatus.CANCELLED;
  } else {
    return EventStatus.OPENED;
  }
}

class Event {
  String id;
  String code;
  String name;
  String clubId;
  String ownerId;
  String ownerName;
  String createdDate;
  String createdTime;
  EventStatus eventStatus;
  List<Slot> slotList;
  int timestamp;
  List<String> autoRateArray;

  Event(
      this.id,
      this.code,
      this.name,
      this.clubId,
      this.ownerId,
      this.ownerName,
      this.createdDate,
      this.createdTime,
      this.eventStatus,
      this.slotList,
      this.timestamp,
      this.autoRateArray);

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'club_id': clubId,
        'owner_id': ownerId,
        'owner_name': ownerName,
        'created_date': createdDate,
        'created_time': createdTime,
        'event_status': eventStatustoString(eventStatus),
        'slot_list': slotList.map<Map>((slot) => slot.toJson()).toList(),
        'timestamp': timestamp,
        'auto_rate_array': autoRateArray
      };

  Event._internalFromJson(Map jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        code = jsonMap['code']?.toString() ?? '',
        name = jsonMap['name']?.toString() ?? '',
        clubId = jsonMap['club_id']?.toString() ?? '',
        ownerId = jsonMap['owner_id']?.toString() ?? '',
        ownerName = jsonMap['owner_name']?.toString() ?? '',
        createdDate = jsonMap['created_date']?.toString() ?? '',
        createdTime = jsonMap['created_time']?.toString() ?? '',
        slotList = (jsonMap['slot_list'] as List<dynamic>)
            .map<Slot>((data) => Slot.fromJson(data))
            .toList(),
        eventStatus = (eventStatusfromString(jsonMap['event_status'])),
        timestamp = jsonMap['timestamp'] ?? 0,
        autoRateArray = (jsonMap['auto_rate_array'] as List<dynamic>)
            .map<String>((data) => data.toString())
            .toList();

  factory Event.fromJson(Map jsonMap) => Event._internalFromJson(jsonMap);
}
