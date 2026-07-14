import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/app_exception.dart';
import '../dtos/travel_reward_dto.dart';

abstract interface class IRewardRemoteDataSource {
  Future<TravelRewardDto> getRandomReward();
  Future<void> claimReward(String userId, TravelRewardDto reward);
  Future<List<TravelRewardDto>> getUserRewards(String userId);
}

class RewardRemoteDataSourceImpl implements IRewardRemoteDataSource {
  final FirebaseFirestore _firestore;

  RewardRemoteDataSourceImpl(this._firestore);

  @override
  Future<TravelRewardDto> getRandomReward() async {
    try {
      final snapshot = await _firestore.collection('rewards').get();
      if (snapshot.docs.isNotEmpty) {
        final randomIndex = Random().nextInt(snapshot.docs.length);
        final doc = snapshot.docs[randomIndex];
        return TravelRewardDto.fromFirestore(doc.data(), doc.id);
      }

      // Default local pool matching weighted distribution
      // Voucher: 20% hotel, 30% flight (weight 50)
      // Badge: Explorer (weight 25)
      // Coins: 50 coins (weight 15), 100 coins (weight 10)
      final pool = [
        // Hotels
        const TravelRewardDto(id: 'r_hotel_20', type: 'voucher', title: '20% Hotel Voucher', description: 'Save 20% on any premium partner hotel booking.', value: 20),
        const TravelRewardDto(id: 'r_hotel_20_2', type: 'voucher', title: '20% Hotel Voucher', description: 'Save 20% on any premium partner hotel booking.', value: 20),
        // Flights
        const TravelRewardDto(id: 'r_flight_10', type: 'voucher', title: '10% Flight Discount', description: 'Save 10% on your next international flight.', value: 10),
        const TravelRewardDto(id: 'r_flight_10_2', type: 'voucher', title: '10% Flight Discount', description: 'Save 10% on your next international flight.', value: 10),
        const TravelRewardDto(id: 'r_flight_10_3', type: 'voucher', title: '10% Flight Discount', description: 'Save 10% on your next international flight.', value: 10),
        // Badges
        const TravelRewardDto(id: 'r_badge_explorer', type: 'badge', title: 'Explorer Badge', description: 'Special collectible stamp added to your passport!', value: 0),
        const TravelRewardDto(id: 'r_badge_explorer_2', type: 'badge', title: 'Explorer Badge', description: 'Special collectible stamp added to your passport!', value: 0),
        // Coins
        const TravelRewardDto(id: 'r_coins_50', type: 'travelCoins', title: '50 TravelCoins', description: 'Added to your Travel Shop coins balance.', value: 50),
        const TravelRewardDto(id: 'r_coins_100', type: 'travelCoins', title: '100 TravelCoins', description: 'Added to your Travel Shop coins balance.', value: 100),
      ];

      final randomIndex = Random().nextInt(pool.length);
      return pool[randomIndex];
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to load random reward.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Future<void> claimReward(String userId, TravelRewardDto reward) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('wallet')
          .doc(reward.id)
          .set(reward.toFirestore());
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to claim reward.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Future<List<TravelRewardDto>> getUserRewards(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('wallet')
          .get();

      return snapshot.docs
          .map((doc) => TravelRewardDto.fromFirestore(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to fetch user rewards.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
