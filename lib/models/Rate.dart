class Rate {
  String id;
  String eventId;
  String raterId;
  String receiverId;
  int timestamp;
  double mark;

  Rate(this.id, this.eventId, this.raterId, this.receiverId, this.timestamp,
      this.mark);

  Map<String, dynamic> toJson() => {
        'id': id,
        'event_id': eventId,
        'rater_id': raterId,
        'receiver_id': receiverId,
        'timestamp': timestamp,
        'mark': mark
      };

  Rate._internalFromJson(Map jsonMap)
      : id = jsonMap['id'],
        eventId = jsonMap['event_id'],
        raterId = jsonMap['rater_id'],
        receiverId = jsonMap['receiver_id'],
        timestamp = jsonMap['timestamp'],
        mark = jsonMap['time'];

  factory Rate.fromJson(Map jsonMap) => Rate._internalFromJson(jsonMap);
}
