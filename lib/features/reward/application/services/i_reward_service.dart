import '../../domain/entities/travel_reward.dart';

abstract interface class IRewardService {
  Future<TravelReward> getRandomReward();
  Future<void> claimReward(String userId, TravelReward reward);
  Future<List<TravelReward>> getUserRewards(String userId);
}
