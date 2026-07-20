import '../../features/quiz/domain/entities/quiz_set.dart';
import '../../features/quiz_game/domain/entities/quiz_question.dart';

class SystemQuizPresets {
  static final List<QuizSet> quizzes = [
    QuizSet(
      id: 'system_space_explorer',
      title: 'Khám Phá Vũ Trụ',
      description:
          'Du hành qua các hành tinh, ngôi sao và những bí mật ngoài không gian.',
      imageUrl:
          'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?auto=format&fit=crop&w=900&q=80',
      creatorId: 'system',
      isPublic: true,
      createdAt: DateTime(2026, 1, 1),
      questions: const [
        QuizQuestion(
          id: 'space_q1',
          text: 'Hành tinh nào được gọi là “hành tinh đỏ”?',
          options: ['Sao Kim', 'Sao Hỏa', 'Sao Mộc', 'Sao Thổ'],
          correctIndex: 1,
          timeLimit: 20,
          hintText: 'Bề mặt hành tinh này có nhiều oxit sắt.',
        ),
        QuizQuestion(
          id: 'space_q2',
          text: 'Mặt Trời là loại thiên thể nào?',
          options: ['Hành tinh', 'Sao', 'Vệ tinh', 'Sao chổi'],
          correctIndex: 1,
          timeLimit: 20,
        ),
        QuizQuestion(
          id: 'space_q3',
          text: 'Hành tinh lớn nhất trong Hệ Mặt Trời là gì?',
          options: ['Trái Đất', 'Sao Hải Vương', 'Sao Mộc', 'Sao Thủy'],
          correctIndex: 2,
          timeLimit: 20,
        ),
        QuizQuestion(
          id: 'space_q4',
          text: 'Thiên hà chứa Hệ Mặt Trời của chúng ta tên là gì?',
          options: ['Tiên Nữ', 'Ngân Hà', 'Tam Giác', 'Mắt Đen'],
          correctIndex: 1,
          timeLimit: 25,
        ),
        QuizQuestion(
          id: 'space_q5',
          text: 'Vệ tinh tự nhiên của Trái Đất là gì?',
          options: ['Mặt Trăng', 'Titan', 'Europa', 'Phobos'],
          correctIndex: 0,
          timeLimit: 20,
        ),
        QuizQuestion(
          id: 'space_q6',
          text: 'Ai là người đầu tiên đặt chân lên Mặt Trăng?',
          options: [
            'Yuri Gagarin',
            'Neil Armstrong',
            'Buzz Aldrin',
            'John Glenn',
          ],
          correctIndex: 1,
          timeLimit: 25,
        ),
        QuizQuestion(
          id: 'space_q7',
          text: 'Ánh sáng Mặt Trời mất khoảng bao lâu để tới Trái Đất?',
          options: ['8 phút', '1 giờ', '24 giờ', '1 giây'],
          correctIndex: 0,
          timeLimit: 25,
        ),
        QuizQuestion(
          id: 'space_q8',
          text: 'Sao chổi thường có phần đuôi sáng vì lý do gì?',
          options: [
            'Do gió Mặt Trời',
            'Do có động cơ',
            'Do tự phát điện',
            'Do va chạm liên tục',
          ],
          correctIndex: 0,
          timeLimit: 25,
        ),
      ],
    ),
    QuizSet(
      id: 'system_tech_legend',
      title: 'Thần Đồng Công Nghệ',
      description:
          'Thử tài kiến thức về máy tính, internet, AI và lập trình hiện đại.',
      imageUrl:
          'https://images.unsplash.com/photo-1518779578993-ec3579fee39f?auto=format&fit=crop&w=900&q=80',
      creatorId: 'system',
      isPublic: true,
      createdAt: DateTime(2026, 1, 2),
      questions: const [
        QuizQuestion(
          id: 'tech_q1',
          text: 'HTML thường dùng để làm gì?',
          options: [
            'Tạo cấu trúc trang web',
            'Thiết kế vi mạch',
            'Nén video',
            'Quản lý pin',
          ],
          correctIndex: 0,
          timeLimit: 20,
        ),
        QuizQuestion(
          id: 'tech_q2',
          text: 'Flutter chủ yếu dùng ngôn ngữ lập trình nào?',
          options: ['Kotlin', 'Swift', 'Dart', 'Python'],
          correctIndex: 2,
          timeLimit: 20,
        ),
        QuizQuestion(
          id: 'tech_q3',
          text: 'Firebase Authentication thường dùng để làm gì?',
          options: [
            'Đăng nhập người dùng',
            'Vẽ giao diện',
            'Tăng RAM',
            'Biên dịch ảnh',
          ],
          correctIndex: 0,
          timeLimit: 25,
        ),
        QuizQuestion(
          id: 'tech_q4',
          text: 'AI là viết tắt của cụm từ nào?',
          options: [
            'Auto Internet',
            'Artificial Intelligence',
            'App Interface',
            'Android Install',
          ],
          correctIndex: 1,
          timeLimit: 20,
        ),
        QuizQuestion(
          id: 'tech_q5',
          text: 'HTTP thường được dùng trong lĩnh vực nào?',
          options: [
            'Truyền tải dữ liệu web',
            'Đo nhiệt độ CPU',
            'Lưu ảnh offline',
            'Thiết kế loa',
          ],
          correctIndex: 0,
          timeLimit: 25,
        ),
        QuizQuestion(
          id: 'tech_q6',
          text: 'Git thường dùng để làm gì?',
          options: [
            'Quản lý phiên bản mã nguồn',
            'Tăng tốc mạng',
            'Chạy máy ảo',
            'Tạo mật khẩu Wi-Fi',
          ],
          correctIndex: 0,
          timeLimit: 25,
        ),
        QuizQuestion(
          id: 'tech_q7',
          text: 'Trong lập trình, “bug” có nghĩa là gì?',
          options: [
            'Tính năng mới',
            'Lỗi trong chương trình',
            'Giao diện đẹp',
            'Tệp ảnh',
          ],
          correctIndex: 1,
          timeLimit: 20,
        ),
        QuizQuestion(
          id: 'tech_q8',
          text: 'Cloud Firestore thuộc nền tảng nào?',
          options: ['Firebase', 'Photoshop', 'Excel', 'Bluetooth'],
          correctIndex: 0,
          timeLimit: 20,
        ),
        QuizQuestion(
          id: 'tech_q9',
          text: 'Responsive UI nghĩa là gì?',
          options: [
            'Giao diện tự thích nghi màn hình',
            'Chỉ chạy trên web',
            'Không cần thiết kế',
            'Tắt animation',
          ],
          correctIndex: 0,
          timeLimit: 25,
        ),
        QuizQuestion(
          id: 'tech_q10',
          text: 'API thường dùng để làm gì?',
          options: [
            'Kết nối và trao đổi dữ liệu giữa hệ thống',
            'Sạc pin nhanh',
            'Vẽ logo',
            'Xóa bộ nhớ máy',
          ],
          correctIndex: 0,
          timeLimit: 25,
        ),
      ],
    ),
    QuizSet(
      id: 'system_vietnam_history',
      title: 'Sử Việt Hào Hùng',
      description:
          'Ôn lại những dấu mốc, nhân vật và chiến thắng tiêu biểu của lịch sử Việt Nam.',
      imageUrl:
          'https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=900&q=80',
      creatorId: 'system',
      isPublic: true,
      createdAt: DateTime(2026, 1, 3),
      questions: const [
        QuizQuestion(
          id: 'history_q1',
          text: 'Chiến thắng Bạch Đằng năm 938 gắn với vị anh hùng nào?',
          options: ['Ngô Quyền', 'Trần Hưng Đạo', 'Lê Lợi', 'Quang Trung'],
          correctIndex: 0,
          timeLimit: 25,
        ),
        QuizQuestion(
          id: 'history_q2',
          text: 'Ai là người lãnh đạo cuộc khởi nghĩa Lam Sơn?',
          options: ['Lý Thường Kiệt', 'Lê Lợi', 'Nguyễn Trãi', 'Phan Bội Châu'],
          correctIndex: 1,
          timeLimit: 25,
        ),
        QuizQuestion(
          id: 'history_q3',
          text: 'Chiến thắng Điện Biên Phủ diễn ra năm nào?',
          options: ['1945', '1954', '1975', '1986'],
          correctIndex: 1,
          timeLimit: 20,
        ),
        QuizQuestion(
          id: 'history_q4',
          text: 'Vị vua gắn với chiến thắng Ngọc Hồi - Đống Đa là ai?',
          options: ['Gia Long', 'Quang Trung', 'Tự Đức', 'Minh Mạng'],
          correctIndex: 1,
          timeLimit: 25,
        ),
        QuizQuestion(
          id: 'history_q5',
          text: 'Thủ đô nước Việt Nam hiện nay là thành phố nào?',
          options: ['Huế', 'Đà Nẵng', 'Hà Nội', 'TP. Hồ Chí Minh'],
          correctIndex: 2,
          timeLimit: 20,
        ),
        QuizQuestion(
          id: 'history_q6',
          text: 'Ngày Quốc khánh Việt Nam là ngày nào?',
          options: ['30/4', '1/5', '2/9', '20/11'],
          correctIndex: 2,
          timeLimit: 20,
        ),
        QuizQuestion(
          id: 'history_q7',
          text: 'Văn Miếu - Quốc Tử Giám nằm ở đâu?',
          options: ['Hà Nội', 'Hải Phòng', 'Nha Trang', 'Cần Thơ'],
          correctIndex: 0,
          timeLimit: 20,
        ),
        QuizQuestion(
          id: 'history_q8',
          text: 'Ai là tác giả “Bình Ngô đại cáo”?',
          options: ['Nguyễn Du', 'Nguyễn Trãi', 'Hồ Xuân Hương', 'Cao Bá Quát'],
          correctIndex: 1,
          timeLimit: 25,
        ),
      ],
    ),
    QuizSet(
      id: 'system_nature_world',
      title: 'Thế Giới Tự Nhiên',
      description:
          'Khám phá động vật, thực vật, môi trường và các hiện tượng tự nhiên.',
      imageUrl:
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=900&q=80',
      creatorId: 'system',
      isPublic: true,
      createdAt: DateTime(2026, 1, 4),
      questions: const [
        QuizQuestion(
          id: 'nature_q1',
          text: 'Loài động vật nào được mệnh danh là “chúa sơn lâm”?',
          options: ['Voi', 'Hổ', 'Gấu trúc', 'Ngựa vằn'],
          correctIndex: 1,
          timeLimit: 20,
        ),
        QuizQuestion(
          id: 'nature_q2',
          text: 'Cây xanh quang hợp cần khí nào?',
          options: ['Oxy', 'Carbon dioxide', 'Nitơ', 'Heli'],
          correctIndex: 1,
          timeLimit: 25,
        ),
        QuizQuestion(
          id: 'nature_q3',
          text: 'Đại dương lớn nhất thế giới là đại dương nào?',
          options: [
            'Đại Tây Dương',
            'Ấn Độ Dương',
            'Bắc Băng Dương',
            'Thái Bình Dương',
          ],
          correctIndex: 3,
          timeLimit: 25,
        ),
        QuizQuestion(
          id: 'nature_q4',
          text: 'Nguồn năng lượng nào là năng lượng tái tạo?',
          options: ['Than đá', 'Dầu mỏ', 'Năng lượng mặt trời', 'Khí gas'],
          correctIndex: 2,
          timeLimit: 20,
        ),
        QuizQuestion(
          id: 'nature_q5',
          text:
              'Hiện tượng nước bốc hơi rồi rơi xuống thành mưa thuộc chu trình nào?',
          options: [
            'Chu trình nước',
            'Chu trình carbon',
            'Chu trình nitơ',
            'Chu trình đá',
          ],
          correctIndex: 0,
          timeLimit: 25,
        ),
        QuizQuestion(
          id: 'nature_q6',
          text: 'Loài nào sau đây là chim?',
          options: ['Cá voi', 'Chim cánh cụt', 'Dơi', 'Cá heo'],
          correctIndex: 1,
          timeLimit: 20,
        ),
      ],
    ),
  ];

  static QuizSet? findById(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final quiz in quizzes) {
      if (quiz.id == id) return quiz;
    }
    return null;
  }

  static QuizSet? findByTopic(String topic) {
    final normalizedTopic = topic.trim().toLowerCase();
    if (normalizedTopic.isEmpty) return null;
    for (final quiz in quizzes) {
      if (quiz.title.toLowerCase() == normalizedTopic) return quiz;
    }
    return null;
  }
}
