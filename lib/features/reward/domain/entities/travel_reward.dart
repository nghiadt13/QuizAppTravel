enum RewardType {
  voucher,
  badge,
  travelCoins,
}

class TravelReward {
  final String id;
  final RewardType type;
  final String title;
  final String description;
  final int value; // coins amount or discount percentage
  final String? iconUrl;

  const TravelReward({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.value,
    this.iconUrl,
  });
}
