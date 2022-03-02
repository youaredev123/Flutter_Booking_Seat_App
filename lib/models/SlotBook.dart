class SlotBook {
  String id;
  String eventId;
  int timestamp;
  int slotId;
  String bookerId;
  String bookerName;
  bool isRated;

  SlotBook(this.id, this.eventId, this.timestamp, this.slotId, this.bookerId,
      this.bookerName, this.isRated);

  Map<String, dynamic> toJson() => {
        'id': id,
        'event_id': eventId,
        'timestamp': timestamp,
        'slot_id': slotId,
        'booker_id': bookerId,
        'booker_name': bookerName,
        'is_rated': isRated
      };

  SlotBook._internalFromJson(Map jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        eventId = jsonMap['event_id']?.toString() ?? '',
        timestamp = jsonMap['timestamp']?.toInt() ?? 0,
        slotId = jsonMap['slot_id']?.toInt() ?? 0,
        bookerId = jsonMap['booker_id']?.toString() ?? '',
        bookerName = jsonMap['booker_name']?.toString() ?? '',
        isRated = jsonMap['is_rated'] ?? false;

  factory SlotBook.fromJson(Map jsonMap) => SlotBook._internalFromJson(jsonMap);
}
