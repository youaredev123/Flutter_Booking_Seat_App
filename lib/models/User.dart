enum Role { USER, ADMIN, SUPERADMIN }
enum Gender { MALE, FEMALE }

String roleToString(Role role) {
  if (role == Role.ADMIN) {
    return 'admin';
  } else if (role == Role.USER) {
    return 'user';
  } else {
    return 'super_admin';
  }
}

Role roleFromString(String roleStr) {
  if (roleStr == 'admin') return Role.ADMIN;
  if (roleStr == 'user') return Role.USER;
  return Role.SUPERADMIN;
}

String genderToString(Gender gender) {
  if (gender == Gender.FEMALE) return 'female';
  return 'male';
}

Gender genderFromString(String genderStr) {
  if (genderStr == 'female') return Gender.FEMALE;
  return Gender.MALE;
}

class User {
  String id;
  String phoneNumber;
  String name;
  Gender gender;
  String birthday;
  String email;
  Role role;
  String code;
  List<String> ownerClubIds;
  List<String> memberClubIds;

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone_number': phoneNumber,
        'name': name,
        'gender': genderToString(gender),
        'birthday': birthday,
        'email': email,
        'role': roleToString(role),
        'code': code,
        'owner_club_ids': ownerClubIds,
        'member_club_ids': memberClubIds,
      };

  User(this.id, this.role, this.name, this.email, this.phoneNumber, this.gender,
      this.code, this.birthday, this.memberClubIds, this.ownerClubIds);

  User._internalFromJson(Map jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        phoneNumber = jsonMap['phone_number']?.toString() ?? '',
        name = jsonMap['name']?.toString() ?? '',
        gender = genderFromString(jsonMap['gender']?.toString() ?? 'male'),
        birthday = jsonMap['birthday']?.toString() ?? '',
        email = jsonMap['email']?.toString() ?? '',
        role = roleFromString(jsonMap['role']?.toString() ?? 'user'),
        code = jsonMap['code']?.toString() ?? '',
        ownerClubIds = List<String>.from(jsonMap['owner_club_ids']),
        memberClubIds = List<String>.from(jsonMap['member_club_ids']);

  factory User.fromJson(Map jsonMap) => User._internalFromJson(jsonMap);
}
