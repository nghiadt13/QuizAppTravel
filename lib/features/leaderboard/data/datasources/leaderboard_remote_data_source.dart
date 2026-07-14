import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/app_exception.dart';
import '../dtos/leaderboard_entry_dto.dart';
import '../dtos/leaderboard_metadata_dto.dart';

abstract interface class ILeaderboardRemoteDataSource {
  Future<List<LeaderboardEntryDto>> fetchEntries(
    String period, {
    required int limit,
    String? lastUserId,
  });
  Future<LeaderboardEntryDto?> fetchUserRank(String period, String userId);
  Stream<LeaderboardEntryDto?> watchUserRank(String period, String userId);
  Future<void> updateScore(String period, String userId, int scoreChange);
  Future<LeaderboardMetadataDto> fetchPeriodMetadata(String period);
  Future<int> fetchRankForScore(String period, int score);
}

class LeaderboardRemoteDataSourceImpl implements ILeaderboardRemoteDataSource {
  final FirebaseFirestore _firestore;

  LeaderboardRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<LeaderboardEntryDto>> fetchEntries(
    String period, {
    required int limit,
    String? lastUserId,
  }) async {
    try {
      final collectionRef = _firestore
          .collection('leaderboard')
          .doc(period)
          .collection('entries');

      Query query = collectionRef.orderBy('totalScore', descending: true);

      if (lastUserId != null) {
        final lastDoc = await collectionRef.doc(lastUserId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.limit(limit).get();
      
      if (snapshot.docs.isEmpty && lastUserId == null) {
        // Fallback default mock rankings if Firestore is empty
        return [
          LeaderboardEntryDto(userId: 'u1', displayName: 'Linh Explorer', totalScore: 12450, gamesPlayed: 32, lastPlayed: DateTime.now()),
          LeaderboardEntryDto(userId: 'u2', displayName: 'Alex Voyager', totalScore: 10200, gamesPlayed: 28, lastPlayed: DateTime.now()),
          LeaderboardEntryDto(userId: 'u3', displayName: 'Minh GlobeTrotter', totalScore: 9850, gamesPlayed: 25, lastPlayed: DateTime.now()),
          LeaderboardEntryDto(userId: 'u4', displayName: 'Sophia Nomad', totalScore: 8400, gamesPlayed: 20, lastPlayed: DateTime.now()),
          LeaderboardEntryDto(userId: 'u5', displayName: 'John Wayfarer', totalScore: 7150, gamesPlayed: 18, lastPlayed: DateTime.now()),
        ];
      }

      return snapshot.docs
          .map((doc) => LeaderboardEntryDto.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to fetch leaderboard entries.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Future<LeaderboardEntryDto?> fetchUserRank(String period, String userId) async {
    try {
      final doc = await _firestore
          .collection('leaderboard')
          .doc(period)
          .collection('entries')
          .doc(userId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return LeaderboardEntryDto.fromFirestore(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to fetch user rank.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Stream<LeaderboardEntryDto?> watchUserRank(String period, String userId) {
    return _firestore
        .collection('leaderboard')
        .doc(period)
        .collection('entries')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return LeaderboardEntryDto.fromFirestore(doc.data()!, doc.id);
    });
  }

  @override
  Future<void> updateScore(String period, String userId, int scoreChange) async {
    try {
      final docRef = _firestore
          .collection('leaderboard')
          .doc(period)
          .collection('entries')
          .doc(userId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) {
          transaction.set(docRef, {
            'displayName': 'Traveler',
            'totalScore': scoreChange,
            'gamesPlayed': 1,
            'lastPlayed': FieldValue.serverTimestamp(),
          });
        } else {
          final data = doc.data()!;
          final currentScore = data['totalScore'] ?? 0;
          final currentGames = data['gamesPlayed'] ?? 0;
          transaction.update(docRef, {
            'totalScore': currentScore + scoreChange,
            'gamesPlayed': currentGames + 1,
            'lastPlayed': FieldValue.serverTimestamp(),
          });
        }
      });
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to update score in transaction.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Future<LeaderboardMetadataDto> fetchPeriodMetadata(String period) async {
    try {
      final doc = await _firestore.collection('leaderboard').doc(period).get();
      if (!doc.exists || doc.data() == null) {
        return const LeaderboardMetadataDto();
      }
      return LeaderboardMetadataDto.fromFirestore(doc.data()!);
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to fetch period metadata.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Future<int> fetchRankForScore(String period, int score) async {
    try {
      final snapshot = await _firestore
          .collection('leaderboard')
          .doc(period)
          .collection('entries')
          .where('totalScore', isGreaterThan: score)
          .get();
      return snapshot.docs.length + 1;
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to calculate user rank.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
