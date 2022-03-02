import 'Member.dart';

enum ClubType { PRIVATE, PUBLIC }

enum InviteStatus { SENT, ACCEPTED, REJECTED, REVOKED, DONE }

inviteStatusToString(InviteStatus iv) {
  switch (iv) {
    case InviteStatus.SENT:
      return 'sent';
      break;
    case InviteStatus.ACCEPTED:
      return 'accepted';
      break;
    case InviteStatus.REJECTED:
      return 'rejected';
      break;
    case InviteStatus.REVOKED:
      return 'revoked';
      break;
    case InviteStatus.DONE:
      return 'done';
      break;
    default:
      return 'sent';
      break;
  }
}

inviteStatusFromString(String ivStr) {
  switch (ivStr) {
    case 'sent':
      return InviteStatus.SENT;
      break;
    case 'accepted':
      return InviteStatus.ACCEPTED;
      break;
    case 'rejected':
      return InviteStatus.REJECTED;
      break;
    case 'revoked':
      return InviteStatus.REVOKED;
      break;
    case 'done':
      return InviteStatus.DONE;
      break;
    default:
      return InviteStatus.SENT;
      break;
  }
}

class Invite {
  String phoneNumber;
  InviteStatus status;
  Invite(this.phoneNumber, this.status);

  Map<String, dynamic> toJson() =>
      {'phone_number': phoneNumber, 'status': inviteStatusToString(status)};

  Invite._internalFromJson(Map jsonMap)
      : phoneNumber = jsonMap['phone_number']?.toString() ?? '',
        status =
            inviteStatusFromString(jsonMap['status']?.toString() ?? 'sent');
  factory Invite.fromJson(Map jsonMap) => Invite._internalFromJson(jsonMap);
}

String clubTypeToString(ClubType ct) {
  if (ct == ClubType.PRIVATE) return 'private';
  return 'public';
}

ClubType clubTypeFromString(String ctStr) {
  if (ctStr == 'private') return ClubType.PRIVATE;
  return ClubType.PUBLIC;
}

class Club {
  String id;
  String name;
  String address1;
  String address2;
  String zipCode;
  String city;
  String country;

  ClubType type;
  String imageUrl;
  String createdDate;
  List<Member> memberList;
  List<Invite> inviteList;

  Club(
      this.id,
      this.name,
      this.address1,
      this.address2,
      this.zipCode,
      this.city,
      this.country,
      this.type,
      this.imageUrl,
      this.createdDate,
      this.memberList,
      this.inviteList);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address1': address1,
        'address2': address2,
        'zip_code': zipCode,
        'city': city,
        'country': country,
        'type': clubTypeToString(type),
        'image_url': imageUrl,
        'created_date': createdDate,
        'member_list': memberList.map((member) => member.toJson()).toList(),
        'invite_list': inviteList.map((invite) => invite.toJson()).toList()
      };
      
  Club._internalFromJson(Map jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        name = jsonMap['name']?.toString() ?? '',
        address1 = jsonMap['address1']?.toString() ?? '',
        address2 = jsonMap['address2']?.toString() ?? '',
        zipCode = jsonMap['zip_code']?.toString() ?? '',
        city = jsonMap['city']?.toString() ?? '',
        country = jsonMap['country']?.toString() ?? '',
        type = clubTypeFromString(jsonMap['type']?.toString() ?? 'private'),
        imageUrl = jsonMap['image_url']?.toString() ?? '',
        createdDate = jsonMap['created_date']?.toString() ?? '',
        memberList = (jsonMap['member_list'] as List<dynamic>)
                ?.map<Member>((memberJson) => Member.fromJson(memberJson))
                ?.toList() ??
            [],
        inviteList = (jsonMap['invite_list'] as List<dynamic>)
                ?.map<Invite>((inviteJson) => Invite.fromJson(inviteJson))
                ?.toList() ??
            [];

  factory Club.fromJson(Map jsonMap) => Club._internalFromJson(jsonMap);
}
