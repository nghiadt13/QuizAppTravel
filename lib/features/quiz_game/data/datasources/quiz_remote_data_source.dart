import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/app_exception.dart';
import '../dtos/quiz_question_dto.dart';

abstract interface class IQuizRemoteDataSource {
  Future<List<QuizQuestionDto>> fetchQuestions(String roomId);
  Future<void> submitAnswer(
    String roomId,
    String userId,
    String questionId,
    Map<String, dynamic> answerData,
  );
  Future<void> updateScore(String roomId, String userId, int totalScore);
}

class QuizRemoteDataSourceImpl implements IQuizRemoteDataSource {
  final FirebaseFirestore _firestore;

  QuizRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<QuizQuestionDto>> fetchQuestions(String roomId) async {
    try {
      // 1. Get the room topic
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      final topic = roomDoc.exists ? (roomDoc.data()?['topic'] ?? '') : '';

      // 2. Fetch quizzes with the matching topic
      final quizQuery = await _firestore
          .collection('quizzes')
          .where('topic', isEqualTo: topic)
          .limit(1)
          .get();

      if (quizQuery.docs.isNotEmpty) {
        final quizDoc = quizQuery.docs.first;
        // Check if questions are inside quizDoc or in subcollection
        final questionsSnapshot = await quizDoc.reference.collection('questions').get();
        if (questionsSnapshot.docs.isNotEmpty) {
          return questionsSnapshot.docs
              .map((doc) => QuizQuestionDto.fromFirestore(doc.data(), doc.id))
              .toList();
        }
      }

      // Fallback Travel questions if Firestore is empty or not seeded
      return [
        const QuizQuestionDto(
          id: 'q1',
          text: 'Which ancient monument is located in Agra, India?',
          options: ['Taj Mahal', 'Colosseum', 'Petra', 'Macchu Picchu'],
          correctIndex: 0,
          timeLimit: 20,
          hintText: 'It is a white marble mausoleum built by Shah Jahan.',
        ),
        const QuizQuestionDto(
          id: 'q2',
          text: 'What is the capital city of Japan?',
          options: ['Kyoto', 'Tokyo', 'Osaka', 'Hiroshima'],
          correctIndex: 1,
          timeLimit: 20,
          hintText: 'It is the most populous metropolitan area in the world.',
        ),
        const QuizQuestionDto(
          id: 'q3',
          text: 'Which country is home to the ancient city of Petra?',
          options: ['Egypt', 'Greece', 'Jordan', 'Turkey'],
          correctIndex: 2,
          timeLimit: 20,
          hintText: 'Its capital is Amman.',
        ),
        const QuizQuestionDto(
          id: 'q4',
          text: 'In which city would you find the Eiffel Tower?',
          options: ['London', 'Berlin', 'Rome', 'Paris'],
          correctIndex: 3,
          timeLimit: 20,
          hintText: 'It is the capital city of France.',
        ),
      ];
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to load quiz questions.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Future<void> submitAnswer(
    String roomId,
    String userId,
    String questionId,
    Map<String, dynamic> answerData,
  ) async {
    try {
      await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(userId)
          .collection('answers')
          .doc(questionId)
          .set(answerData);
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to submit player answer.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Future<void> updateScore(String roomId, String userId, int totalScore) async {
    try {
      await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(userId)
          .update({
        'score': totalScore,
      });
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to update player score.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
