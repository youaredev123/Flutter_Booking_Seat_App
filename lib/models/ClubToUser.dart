import 'package:eventbooking/models/Club.dart';
import 'package:eventbooking/models/Member.dart';

enum CRole { ADMIN, USER, NONE }

cRoleToString(CRole cRole) {
  if (cRole == CRole.ADMIN) return 'admin';
  if(cRole == CRole.USER) return 'user';
  return 'none';
}

cRoleFromString(String cRoleStr) {
  if (cRoleStr == 'admim') return CRole.ADMIN;
  if(cRoleStr == 'user') return CRole.USER;
  return CRole.NONE;
}

class ClubToUser {
  String id;
  String clubId;
  String userId;
  String phoneNumber;
  CRole cRole;
  MemberStatus memberStatus;
  InviteStatus inviteStatus;
  bool checked;


  ClubToUser(this.id, this.clubId, this.userId, this.phoneNumber, this.cRole,
      this.memberStatus, this.inviteStatus, this.checked);

  ClubToUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clubId = json['club_id'];
    userId = json['user_id'];
    phoneNumber = json['phone_number'];
    cRole = cRoleFromString(json['crole'] as String);
    memberStatus = memberStatusFromString(json['member_status'] as String);
    inviteStatus = inviteStatusFromString(json['invite_status'] as String);
    checked = json['checked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['club_id'] = this.clubId;
    data['user_id'] = this.userId;
    data['phone_number'] = this.phoneNumber;
    data['crole'] = cRoleToString(this.cRole);
    data['member_status'] = memberStatusToString(this.memberStatus);
    data['invite_status'] = inviteStatusToString(this.inviteStatus);
    data['checked'] = this.checked;
    return data;
  }
}

//class RoleNId{
//  String id;
//  CRole cRole;
//
//  RoleNId(this.id, this.cRole);
//  Map<String, dynamic> toJson(){
//
//  }
//}