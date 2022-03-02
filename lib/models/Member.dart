import 'User.dart';

enum MemberStatus{
  ACTIVE, INACTIVE
}

String memberStatusToString(MemberStatus ms){
  if(ms == MemberStatus.ACTIVE) return 'active';
  return 'inactive';
}

MemberStatus memberStatusFromString(String msStr){
  if(msStr == 'active') return MemberStatus.ACTIVE;
  return MemberStatus.INACTIVE;
}

class Member{
  String memberId;
  String name;
  String phoneNumber;
  MemberStatus status;
  Role role;
  Member(this.memberId, this.name, this.phoneNumber, this.status, this.role);

  Map<String, dynamic> toJson() => {
    'member_id': memberId,
    'name': name,
    'phone_number': phoneNumber,
    'status': memberStatusToString(status),
    'role': roleToString(role)
  };

  Member._internalFromJson(Map jsonMap){
    memberId = jsonMap['member_id']?.toString() ?? '';
    name = jsonMap['name']?.toString() ?? '';
    phoneNumber = jsonMap['phone_number']?.toString() ?? '';
    status = memberStatusFromString(jsonMap['status']?.toString() ?? 'active');
    role = roleFromString(jsonMap['role']?.toString() ?? 'user');
  }
  factory Member.fromJson(Map jsonMap) => Member._internalFromJson(jsonMap);
}
