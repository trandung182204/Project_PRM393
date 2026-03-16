import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bai1/config/api_config.dart';
import 'package:bai1/models/club.dart';
import 'package:bai1/models/student_club_member.dart';

class ClubService {
  Future<List<Club>> getClubs() async {
    final response = await http.get(Uri.parse(ApiConfig.getClubs));

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Club.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load clubs');
    }
  }

  Future<List<Club>> getPendingClubs() async {
    final response = await http.get(Uri.parse(ApiConfig.pendingClubs));

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Club.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load pending clubs');
    }
  }

  Future<List<Club>> getAllClubs() async {
    final response = await http.get(Uri.parse(ApiConfig.allClubs));

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Club.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load all clubs');
    }
  }

  Future<bool> createClub(Map<String, dynamic> clubData) async {
    final response = await http.post(
      Uri.parse(ApiConfig.getClubs),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(clubData),
    );
    return response.statusCode == 200;
  }

  Future<bool> proposeClub(Map<String, dynamic> clubData) async {
    final response = await http.post(
      Uri.parse(ApiConfig.proposeClub),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(clubData),
    );
    return response.statusCode == 200;
  }

  Future<bool> approveClub(int id) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.getClubs}/$id/approve"),
    );
    return response.statusCode == 200;
  }

  Future<bool> deactivateClub(int id) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.getClubs}/$id/deactivate"),
    );
    return response.statusCode == 200;
  }

  Future<bool> updateClub(int id, Map<String, dynamic> clubData) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.getClubs}/$id"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(clubData),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteClub(int id) async {
    final response = await http.delete(Uri.parse("${ApiConfig.getClubs}/$id"));
    return response.statusCode == 200;
  }

  // ==================== MEMBER MANAGEMENT ====================

  Future<bool> joinClub(int clubId, int studentId) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.getClubs}/$clubId/join?studentId=$studentId"),
    );
    return response.statusCode == 200;
  }

  Future<List<StudentClubMember>> getMembers(int clubId) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.getClubs}/$clubId/members"),
    );

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((m) => StudentClubMember.fromJson(m)).toList();
    } else {
      throw Exception('Failed to load members');
    }
  }

  Future<List<StudentClubMember>> getPendingMembers(int clubId) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.getClubs}/$clubId/members/pending"),
    );

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((m) => StudentClubMember.fromJson(m)).toList();
    } else {
      throw Exception('Failed to load pending members');
    }
  }

  Future<bool> approveMember(int clubId, int studentId) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.getClubs}/$clubId/members/$studentId/approve"),
    );
    return response.statusCode == 200;
  }

  Future<bool> rejectMember(int clubId, int studentId) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.getClubs}/$clubId/members/$studentId/reject"),
    );
    return response.statusCode == 200;
  }

  Future<bool> assignRole(int clubId, int studentId, String role) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.getClubs}/$clubId/members/$studentId/role"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"role": role}),
    );
    return response.statusCode == 200;
  }

  Future<bool> leaveClub(int clubId, int studentId) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.getClubs}/$clubId/members/$studentId/leave"),
    );
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> getMyStatus(int clubId, int studentId) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.getClubs}/$clubId/my-status?studentId=$studentId"),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get membership status');
    }
  }
}
