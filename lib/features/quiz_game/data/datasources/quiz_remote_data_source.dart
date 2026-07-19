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
      // 1. Get the room document
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) return [];

      final data = roomDoc.data();
      final quizId = data?['quizId'] as String?;
      final topic = data?['topic'] as String? ?? '';

      // 2. If room has quizId, fetch questions directly from that quiz
      if (quizId != null && quizId.isNotEmpty) {
        final quizDoc = await _firestore.collection('quizzes').doc(quizId).get();
        if (quizDoc.exists) {
          final questionsSnapshot = await quizDoc.reference.collection('questions').get();
          if (questionsSnapshot.docs.isNotEmpty) {
            return questionsSnapshot.docs
                .map((doc) => QuizQuestionDto.fromFirestore(doc.data(), doc.id))
                .toList();
          }
        }
      }

      // 3. Fallback: Fetch quizzes with the matching topic
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

      // Fallback questions if Firestore is empty or not seeded
      return [
        const QuizQuestionDto(
          id: 'q1',
          text: 'What planet is known as the Red Planet?',
          options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
          correctIndex: 1,
          timeLimit: 20,
          hintText: 'It is the fourth planet from the Sun.',
        ),
        const QuizQuestionDto(
          id: 'q2',
          text: 'Which element has the chemical symbol "O"?',
          options: ['Gold', 'Osmium', 'Oxygen', 'Iron'],
          correctIndex: 2,
          timeLimit: 20,
          hintText: 'It is essential for breathing.',
        ),
        const QuizQuestionDto(
          id: 'q3',
          text: 'Who painted the Mona Lisa?',
          options: ['Vincent van Gogh', 'Pablo Picasso', 'Leonardo da Vinci', 'Michelangelo'],
          correctIndex: 2,
          timeLimit: 20,
          hintText: 'He was an Italian Renaissance polymath.',
        ),
        const QuizQuestionDto(
          id: 'q4',
          text: 'What is the largest ocean on Earth?',
          options: ['Atlantic Ocean', 'Indian Ocean', 'Arctic Ocean', 'Pacific Ocean'],
          correctIndex: 3,
          timeLimit: 20,
          hintText: 'It covers more area than all the land on Earth combined.',
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
