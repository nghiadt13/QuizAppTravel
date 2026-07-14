import '../../domain/entities/travel_reward.dart';
import '../../domain/repositories/i_reward_repository.dart';
import 'i_reward_service.dart';

class RewardServiceImpl implements IRewardService {
  final IRewardRepository _repository;

  RewardServiceImpl(this._repository);

  @override
  Future<TravelReward> getRandomReward() async {
    return _repository.getRandomReward();
  }

  @override
  Future<void> claimReward(String userId, TravelReward reward) async {
    await _repository.claimReward(userId, reward);
  }

  @override
  Future<List<TravelReward>> getUserRewards(String userId) async {
    return _repository.getUserRewards(userId);
  }
}
