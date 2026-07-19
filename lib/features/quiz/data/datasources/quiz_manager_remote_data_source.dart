import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../quiz_game/data/dtos/quiz_question_dto.dart';
import '../dtos/quiz_set_dto.dart';

abstract interface class IQuizManagerRemoteDataSource {
  Future<List<QuizSetDto>> fetchMyQuizzes(String userId);
  Future<List<QuizSetDto>> fetchPublicQuizzes();
  Future<QuizSetDto?> fetchQuizById(String quizId);
  Future<List<QuizQuestionDto>> fetchQuizQuestions(String quizId);
  Future<void> createQuiz(QuizSetDto quizSet, List<QuizQuestionDto> questions);
  Future<void> deleteQuiz(String quizId);
}

class QuizManagerRemoteDataSourceImpl implements IQuizManagerRemoteDataSource {
  final FirebaseFirestore _firestore;

  QuizManagerRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<QuizSetDto>> fetchMyQuizzes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('quizzes')
          .where('creatorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => QuizSetDto.fromFirestore(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Lỗi khi tải danh sách bộ câu hỏi cá nhân từ Firebase.');
    } catch (e) {
      throw AppException('Có lỗi xảy ra: $e');
    }
  }

  @override
  Future<List<QuizSetDto>> fetchPublicQuizzes() async {
    try {
      final snapshot = await _firestore
          .collection('quizzes')
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => QuizSetDto.fromFirestore(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Lỗi khi tải danh sách bộ câu hỏi công khai từ Firebase.');
    } catch (e) {
      throw AppException('Có lỗi xảy ra: $e');
    }
  }

  @override
  Future<QuizSetDto?> fetchQuizById(String quizId) async {
    try {
      final doc = await _firestore.collection('quizzes').doc(quizId).get();
      if (!doc.exists) return null;
      return QuizSetDto.fromFirestore(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Lỗi khi tải chi tiết bộ câu hỏi.');
    } catch (e) {
      throw AppException('Có lỗi xảy ra: $e');
    }
  }

  @override
  Future<List<QuizQuestionDto>> fetchQuizQuestions(String quizId) async {
    try {
      final snapshot = await _firestore
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')
          .get();

      return snapshot.docs
          .map((doc) => QuizQuestionDto.fromFirestore(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Lỗi khi tải câu hỏi của bộ quiz.');
    } catch (e) {
      throw AppException('Có lỗi xảy ra: $e');
    }
  }

  @override
  Future<void> createQuiz(QuizSetDto quizSet, List<QuizQuestionDto> questions) async {
    try {
      final WriteBatch batch = _firestore.batch();
      
      // Determine quiz document reference (create new doc or overwrite existing)
      final quizDocRef = quizSet.id.isEmpty 
          ? _firestore.collection('quizzes').doc() 
          : _firestore.collection('quizzes').doc(quizSet.id);

      // Add quiz doc to batch
      batch.set(quizDocRef, quizSet.toFirestore());

      // Write questions in questions subcollection
      final questionsColRef = quizDocRef.collection('questions');

      // Clear old questions first if editing
      if (quizSet.id.isNotEmpty) {
        final existingQuestions = await questionsColRef.get();
        for (final doc in existingQuestions.docs) {
          batch.delete(doc.reference);
        }
      }

      // Add new questions
      for (final q in questions) {
        final qDocRef = questionsColRef.doc();
        batch.set(qDocRef, q.toFirestore());
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Lỗi khi lưu bộ câu hỏi lên Firebase.');
    } catch (e) {
      throw AppException('Có lỗi xảy ra: $e');
    }
  }

  @override
  Future<void> deleteQuiz(String quizId) async {
    try {
      final quizDocRef = _firestore.collection('quizzes').doc(quizId);
      
      // Delete questions in subcollection first
      final questions = await quizDocRef.collection('questions').get();
      final batch = _firestore.batch();
      
      for (final doc in questions.docs) {
        batch.delete(doc.reference);
      }
      
      batch.delete(quizDocRef);
      await batch.commit();
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Lỗi khi xóa bộ câu hỏi khỏi Firebase.');
    } catch (e) {
      throw AppException('Có lỗi xảy ra: $e');
    }
  }
}
