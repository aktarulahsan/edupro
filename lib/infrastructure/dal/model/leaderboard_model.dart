class LeaderboardResponse {
  final List<LeaderboardUser> topUsers;
  final LeaderboardUser currentUser;

  LeaderboardResponse({
    required this.topUsers,
    required this.currentUser,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    var topUsersList = json['topUsers'] as List? ?? [];
    List<LeaderboardUser> topUsers = topUsersList
        .map((e) => LeaderboardUser.fromJson(e as Map<String, dynamic>))
        .toList();

    return LeaderboardResponse(
      topUsers: topUsers,
      currentUser: LeaderboardUser.fromJson(json['currentUser'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class LeaderboardUser {
  final int rank;
  final int studentId;
  final String name;
  final String email;
  final int score;

  LeaderboardUser({
    required this.rank,
    required this.studentId,
    required this.name,
    required this.email,
    required this.score,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      rank: json['rank'] ?? 0,
      studentId: json['studentId'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      score: json['score'] ?? 0,
    );
  }
}
