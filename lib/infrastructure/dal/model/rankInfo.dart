class RankInfo {
  final int currentRank;
  final int totalParticipants;
  final int pointsToNextRank;
  final String? rankTitle;

  RankInfo({
    required this.currentRank,
    required this.totalParticipants,
    required this.pointsToNextRank,
    this.rankTitle,
  });

  factory RankInfo.fromJson(Map<String, dynamic> json) {
    return RankInfo(
      currentRank: json['current_rank'] ?? 0,
      totalParticipants: json['total_participants'] ?? 0,
      pointsToNextRank: json['points_to_next_rank'] ?? 0,
      rankTitle: json['rank_title'],
    );
  }
}
