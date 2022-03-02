import 'dart:convert';

enum RateStatus { RATED, NONRATED }

RateStatus rateStatusfromString(rStatusStr) {
  if (rStatusStr == 'rated') return RateStatus.RATED;
  return RateStatus.NONRATED;
}

String rateStatustoString(RateStatus status){
  if(status == RateStatus.RATED) return 'rated';
  return 'nonRated';
}

class RateMark{
  String userId;
  double mark;

  RateMark(this.userId, this.mark);
  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'mark': mark
  };

  RateMark._internalFromJson(Map jsonMap)
      : userId = jsonMap['event_id']?.toString() ?? '',
        mark = jsonMap['mark']?.toDouble() ?? 0.0;
  factory RateMark.fromJson(Map jsonMap) => RateMark._internalFromJson(jsonMap);

}

class SlotBooking {
  String eventId;
  RateStatus rateStatus = RateStatus.NONRATED;
  int timestamp;
  List<RateMark> rateMarkList;

  SlotBooking(this.eventId, this.rateStatus, this.timestamp, this.rateMarkList);

  Map<String, dynamic> toJson() => {
    'event_id': eventId,
    'rate_status': rateStatustoString(rateStatus),
    'timestamp': timestamp,
    'rate_mark_list': rateMarkList.map<String>((rateMark)=>json.encode(rateMark.toJson())).toList()
  };

  SlotBooking._internalFromJson(Map jsonMap)
      : eventId = jsonMap['event_id']?.toString() ?? '',
        rateStatus = rateStatusfromString(jsonMap['rate_status']?.toString() ?? 'nonRated'),
        timestamp = jsonMap['timestamp']?.toInt() ?? 0,
        rateMarkList = (jsonMap['rate_mark_list'] as List<dynamic>).map<RateMark>((str)=> RateMark.fromJson(str)).toList() ??[];
  factory SlotBooking.fromJson(Map jsonMap) => SlotBooking._internalFromJson(jsonMap);

}
