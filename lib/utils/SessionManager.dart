import 'dart:convert';

import 'package:eventbooking/models/SlotBooking.dart';
import 'package:eventbooking/models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DateUtils.dart';

enum Login_Status { NEW_USER, LOGGED_IN, LOGGED_OUT }

const String DateFormat = 'yyyy-MM-dd hh:dd a';

class SessionManager {
  static final String KEY_LOGGEDIN = 'logged_in';
  static final String KEY_PASSWORD = 'key_password';
  static final String KEY_GENDER = 'key_gender';
  static final String KEY_EMAIL = 'key_email';
  static final String KEY_USERNAME = 'key_user_name';
  static final String KEY_PHONENUMBER = 'key_phone_number';
  static final String KEY_USER_ID = 'key_user_id';
  static final String KEY_ROLE = 'key_role';
  static final String KEY_DATE = 'key_date';
  static final String KEY_CODE = 'key_code';
  static SharedPreferences _sharedPrefs;

  static void initialize(SharedPreferences sharedPreferences) {
    _sharedPrefs = sharedPreferences;
  }

  static Login_Status isLogged() {
    var loggedIn = _sharedPrefs.getString(KEY_LOGGEDIN) ?? false;

    if (loggedIn == 'true') {
      return Login_Status.LOGGED_IN;
    } else {
      return Login_Status.LOGGED_OUT;
    }
  }

  static void hasLoggedIn() {
    _sharedPrefs.setString(KEY_LOGGEDIN, 'true');
  }

  static void hasLoggedOut() {
    _sharedPrefs.setString(KEY_LOGGEDIN, 'false');
    handleClearAllSettging();
  }

  static void saveUserInfoToLocal(User userInfo) {
    SessionManager.setUserId(userInfo.id);
    SessionManager.setPhoneNumber(userInfo.phoneNumber);
    SessionManager.setUserName(userInfo.name);
    SessionManager.setGender(userInfo.gender);
    SessionManager.setBirthday(userInfo.birthday);
    SessionManager.setEmail(userInfo.email);
    SessionManager.setRole(userInfo.role);
    SessionManager.setCode(userInfo.code);
    SessionManager.setMemberClubIds(userInfo.memberClubIds);
    SessionManager.setOwnerClubIds(userInfo.ownerClubIds);
  }

  static void handleClearAllSettging() {
    setUserId(null);
    setUserName('');
    setEmail('');
    setRole(Role.USER);
    setCode('');
    setDate('');
    setGender(null);
    setBirthday('');
    setSlotBookingHistory([]);
    setOwnerClubIds([]);
    setMemberClubIds([]);
  }

  static String getUserId() {
    return _sharedPrefs.getString(KEY_USER_ID) ?? '';
  }

  static void setUserId(String userId) {
    _sharedPrefs.setString(KEY_USER_ID, userId);
  }

  static void setPhoneNumber(String phoneNumber) {
    _sharedPrefs.setString(KEY_PHONENUMBER, phoneNumber);
  }

  static String getPhoneNumber() {
    return _sharedPrefs.getString(KEY_PHONENUMBER) ?? '';
  }

  static String getUserName() {
    return _sharedPrefs.getString(KEY_USERNAME) ?? '';
  }

  static void setUserName(String username) {
    _sharedPrefs.setString(KEY_USERNAME, username);
  }

  static String getEmail() {
    return _sharedPrefs.getString(KEY_EMAIL) ?? '';
  }

  static void setEmail(String email) {
    _sharedPrefs.setString(KEY_EMAIL, email);
  }

  static String getCode() {
    return _sharedPrefs.getString(KEY_CODE) ?? '';
  }

  static void setCode(String code) {
    _sharedPrefs.setString(KEY_CODE, code);
  }

  static Role getRole() {
    var roleString = _sharedPrefs.getString(KEY_ROLE) ?? 'user';
    if (roleString == 'admin') {
      return Role.ADMIN;
    } else if (roleString == 'user') {
      return Role.USER;
    } else {
      return Role.SUPERADMIN;
    }
  }

  static void setRole(Role role) {
    var roleString = 'super_admin';
    if (role == Role.ADMIN) {
      roleString = 'admin';
    } else if (role == Role.USER) {
      roleString = 'user';
    }
    _sharedPrefs.setString(KEY_ROLE, roleString);
  }

  static String getDate() {
    return _sharedPrefs.getString(KEY_DATE) ??
        DateUtils.getTimeStringWithFormat(
            dateTime: DateTime.now(), format: DateFormat);
  }

  static void setDate(String date) {
    _sharedPrefs.setString(KEY_DATE, date);
  }

  static Gender getGender() {
    var genderString = _sharedPrefs.getString(KEY_GENDER) ?? '';
    if (genderString == 'male') {
      return Gender.MALE;
    } else if (genderString == 'female') {
      return Gender.FEMALE;
    } else {
      return Gender.MALE;
    }
  }

  static void setGender(Gender gender) {
    var genderString = 'male';
    if (gender == Gender.FEMALE) {
      genderString = 'female';
    }
    _sharedPrefs.setString(KEY_GENDER, genderString);
  }

  static void setOwnerClubIds(List<String> idList) {
    _sharedPrefs.setStringList('owner_club_ids', idList);
  }

  static List<String> getOwnerClubIds() {
    return _sharedPrefs.getStringList('owner_club_ids') ?? [];
  }

  static void setMemberClubIds(List<String> idList) {
    _sharedPrefs.setStringList('member_club_ids', idList);
  }

  static List<String> getMemberClubIds() {
    return _sharedPrefs.getStringList('member_club_ids') ?? [];
  }

  static void setBirthday(String birthday) {
    _sharedPrefs.setString('birthday', birthday);
  }

  static String getBirthday() {
    return _sharedPrefs.getString('birthday') ?? '';
  }

  static void setSlotBookingHistory(List<SlotBooking> slotBookingHistory) {
    List<String> jsonStringList = slotBookingHistory
        .map<String>((slotBooking) => json.encode(slotBooking.toJson()))
        .toList();
    _sharedPrefs.setStringList('slot_booking_history', jsonStringList);
  }

  static List<SlotBooking> getSlotBookingHistory() {
    List<String> jsonStringList =
        _sharedPrefs.getStringList('slot_booking_history');
    if (jsonStringList == null) return [];
    return jsonStringList
        .map<SlotBooking>((str) => SlotBooking.fromJson(json.decode(str)))
        .toList();
  }
}
