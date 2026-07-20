import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DatabaseSeeder {
  static Future<void> clearOldRooms() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection('rooms').get();
      for (final doc in snapshot.docs) {
        final participants = await doc.reference.collection('participants').get();
        for (final p in participants.docs) {
          await p.reference.delete();
        }
        await doc.reference.delete();
      }
      debugPrint('Cleared all old room documents from Firestore!');
    } catch (e) {
      debugPrint('Error clearing old rooms: $e');
    }
  }

  static Future<void> seedQuizzesIfEmpty() async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Check if we already seeded by looking for our specific quiz document
      final checkDoc = await firestore.collection('quizzes').doc('quiz_flutter_basics').get();
      if (checkDoc.exists) {
        debugPrint('Database is already seeded with mock quizzes.');
        return;
      }

      debugPrint('Seeding database with mock quizzes...');
      final batch = firestore.batch();

      // Seed 1: Flutter & Dart
      final flutterRef = firestore.collection('quizzes').doc('quiz_flutter_basics');
      batch.set(flutterRef, {
        'topic': 'Lập trình Flutter & Dart',
        'title': 'Lập trình Flutter & Dart',
        'description': 'Kiểm tra kiến thức về Flutter framework, widget, state management và ngôn ngữ Dart.',
        'imageUrl': 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=600&q=80',
        'creatorId': 'admin',
        'isPublic': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _seedQuestions(batch, flutterRef.collection('questions'), _getFlutterQuestions());

      // Seed 2: Node.js & Backend
      final nodeRef = firestore.collection('quizzes').doc('quiz_nodejs_basics');
      batch.set(nodeRef, {
        'topic': 'Lập trình Node.js & Backend',
        'title': 'Lập trình Node.js & Backend',
        'description': 'Kiểm tra hiểu biết về Event Loop, Stream, Express, API, Security và cơ sở dữ liệu.',
        'imageUrl': 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=600&q=80',
        'creatorId': 'admin',
        'isPublic': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _seedQuestions(batch, nodeRef.collection('questions'), _getNodeQuestions());

      // Seed 3: Lịch sử Việt Nam
      final historyRef = firestore.collection('quizzes').doc('quiz_history_vietnam');
      batch.set(historyRef, {
        'topic': 'Lịch sử Việt Nam hào hùng',
        'title': 'Lịch sử Việt Nam hào hùng',
        'description': 'Hành trình tìm hiểu các cột mốc lịch sử hào hùng, triều đại phong kiến và các cuộc kháng chiến cứu nước.',
        'imageUrl': 'https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=600&q=80',
        'creatorId': 'admin',
        'isPublic': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _seedQuestions(batch, historyRef.collection('questions'), _getHistoryQuestions());

      // Seed 4: Địa lý & Văn hóa Du lịch Việt Nam
      final travelRef = firestore.collection('quizzes').doc('quiz_travel_vietnam');
      batch.set(travelRef, {
        'topic': 'Văn hóa & Địa lý Du lịch Việt Nam',
        'title': 'Văn hóa & Địa lý Du lịch Việt Nam',
        'description': 'Khám phá danh lam thắng cảnh, ẩm thực đặc trưng và nét đẹp văn hóa của 3 miền đất nước.',
        'imageUrl': 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=600&q=80',
        'creatorId': 'admin',
        'isPublic': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _seedQuestions(batch, travelRef.collection('questions'), _getTravelQuestions());

      await batch.commit();
      debugPrint('Database seeding completed successfully! 🎉');
    } catch (e) {
      debugPrint('Error seeding database: $e');
    }
  }

  static void _seedQuestions(
    WriteBatch batch, 
    CollectionReference questionsCol, 
    List<Map<String, dynamic>> questions,
  ) {
    for (int i = 0; i < questions.length; i++) {
      final docRef = questionsCol.doc('q_${i + 1}');
      batch.set(docRef, questions[i]);
    }
  }

  static List<Map<String, dynamic>> _getFlutterQuestions() {
    return [
      {
        'text': 'Phương thức nào trong Flutter dùng để chạy ứng dụng gốc?',
        'options': ['runApp()', 'main()', 'startApp()', 'initApp()'],
        'correctIndex': 0,
        'timeLimit': 20,
        'hintText': 'Hàm này nhận tham số là một Widget gốc và gắn nó lên màn hình.',
      },
      {
        'text': 'Widget nào dùng để sắp xếp các Widget con theo chiều dọc?',
        'options': ['Row', 'Column', 'ListView', 'Stack'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Đâu KHÔNG phải là một trạng thái quản lý (State Management) phổ biến trong Flutter?',
        'options': ['Provider', 'Bloc', 'Redux', 'Spring'],
        'correctIndex': 3,
        'timeLimit': 20,
        'hintText': 'Spring là một Framework của ngôn ngữ Java.',
      },
      {
        'text': 'Trong Dart, từ khóa nào dùng để khai báo một biến có thể gán giá trị muộn hơn nhưng không thể thay đổi sau khi gán?',
        'options': ['const', 'final', 'late final', 'var'],
        'correctIndex': 2,
        'timeLimit': 20,
      },
      {
        'text': 'Widget nào dùng để lắng nghe các sự kiện chạm, kéo thả từ người dùng?',
        'options': ['GestureDetector', 'Container', 'InkWell', 'Cả A và C đều đúng'],
        'correctIndex': 3,
        'timeLimit': 20,
      },
      {
        'text': 'Khi thiết lập kích thước cho Widget con vượt quá Widget cha, lỗi gì sẽ hiển thị trên màn hình?',
        'options': ['Lỗi Null Pointer', 'Lỗi OverFlow (sọc vàng đen)', 'Lỗi StackOverflow', 'Lỗi Memory Leak'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Từ khóa "mixin" trong Dart có ý nghĩa gì?',
        'options': ['Định nghĩa interface', 'Định nghĩa class trừu tượng', 'Đại diện cho đa kế thừa không thông qua lớp cha', 'Khai báo hằng số'],
        'correctIndex': 2,
        'timeLimit': 20,
      },
      {
        'text': 'Hàm build() của StatelessWidget được gọi khi nào?',
        'options': ['Khi Widget được tạo lần đầu', 'Khi Widget cha thay đổi', 'Khi gọi setState()', 'Cả A và B đều đúng'],
        'correctIndex': 3,
        'timeLimit': 20,
      },
      {
        'text': 'Lớp nào là cha của mọi Widget trong Flutter?',
        'options': ['DiagnosticableTree', 'Widget', 'RenderObject', 'Element'],
        'correctIndex': 0,
        'timeLimit': 20,
        'hintText': 'Đây là lớp cơ sở hỗ trợ ghi nhật ký và chẩn đoán cấu trúc cây.',
      },
      {
        'text': 'Để tối ưu hiệu năng hiển thị danh sách dài vô tận, chúng ta nên dùng Widget nào?',
        'options': ['SingleChildScrollView', 'ListView.builder()', 'Column', 'ListView()'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Hàm initState() thuộc về lớp nào?',
        'options': ['StatelessWidget', 'State', 'Widget', 'BuildContext'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Widget nào dùng để tạo khoảng trống cố định giữa các phần tử?',
        'options': ['Spacer', 'SizedBox', 'Padding', 'Expanded'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Làm thế nào để truyền dữ liệu ngược từ màn hình B về màn hình A khi đóng màn hình B?',
        'options': ['Dùng Navigator.pop(context, data)', 'Dùng SharedPreferences', 'Dùng biến static', 'Không thể truyền dữ liệu ngược'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Từ khóa "async" và "await" trong Dart hoạt động với kiểu dữ liệu nào?',
        'options': ['Stream', 'Future', 'Map', 'Iterable'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Widget Navigator trong Flutter quản lý các màn hình dưới dạng cấu trúc dữ liệu nào?',
        'options': ['Queue', 'Stack (Ngăn xếp)', 'Tree', 'List'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Đối tượng nào đại diện cho vị trí của Widget trên cây Widget?',
        'options': ['State', 'Key', 'BuildContext', 'Element'],
        'correctIndex': 2,
        'timeLimit': 20,
      },
      {
        'text': 'Kiểu dữ liệu nào trong Dart biểu thị một chuỗi bất biến gồm các ký tự UTF-16?',
        'options': ['char', 'String', 'StringBuffer', 'Runes'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Để vẽ các hình dạng đồ họa tùy chỉnh trong Flutter, chúng ta dùng Widget nào?',
        'options': ['CustomPaint', 'Canvas', 'SVG', 'ClipRect'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Trong Flutter, "pubspec.yaml" dùng để làm gì?',
        'options': ['Cấu hình dependency và tài nguyên', 'Viết mã nguồn Java', 'Lưu trữ database', 'Cấu hình định dạng code'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Lệnh nào dùng để cài đặt các package được khai báo trong pubspec.yaml?',
        'options': ['flutter build', 'flutter clean', 'flutter pub get', 'flutter run'],
        'correctIndex': 2,
        'timeLimit': 20,
      },
      {
        'text': 'Hot Reload trong Flutter cập nhật giao diện bằng cách nào?',
        'options': ['Khởi động lại toàn bộ máy ảo', 'Biên dịch lại toàn bộ code', 'Tải lại mã nguồn đã thay đổi vào máy ảo Dart và rebuild widget tree', 'Chạy lại hàm main()'],
        'correctIndex': 2,
        'timeLimit': 20,
      },
      {
        'text': 'Lớp nào trong Flutter cho phép giao tiếp với code native (Java/Swift)?',
        'options': ['NativeChannel', 'MethodChannel', 'PlatformChannel', 'BridgeChannel'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Widget nào dùng để ép buộc kích thước của widget con theo một tỷ lệ khung hình nhất định?',
        'options': ['AspectRatio', 'FractionallySizedBox', 'ConstrainedBox', 'FittedBox'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Kiểu dữ liệu nào đại diện cho một chuỗi các sự kiện bất đồng bộ?',
        'options': ['Future', 'Stream', 'Completer', 'Iterator'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'StatefulWidget có bao nhiêu giai đoạn trong vòng đời (lifecycle) chính thức?',
        'options': ['1', '3', '5', 'Nhiều hơn 5'],
        'correctIndex': 3,
        'timeLimit': 20,
        'hintText': 'Gồm: createState, initState, didChangeDependencies, build, didUpdateWidget, deactivate, dispose...',
      }
    ];
  }

  static List<Map<String, dynamic>> _getNodeQuestions() {
    return [
      {
        'text': 'Node.js hoạt động dựa trên Engine Javascript nào?',
        'options': ['SpiderMonkey', 'Chakra', 'V8', 'JavaScriptCore'],
        'correctIndex': 2,
        'timeLimit': 20,
        'hintText': 'Đây là Engine do Google phát triển cho trình duyệt Chrome.',
      },
      {
        'text': 'Đặc trưng kiến trúc nổi bật nhất của Node.js là gì?',
        'options': ['Đơn luồng, bất đồng bộ và hướng sự kiện', 'Đa luồng đồng bộ', 'Không hỗ trợ network', 'Chỉ chạy được trên hệ điều hành Windows'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Từ khóa "require" trong Node.js dùng để làm gì?',
        'options': ['Khai báo biến', 'Import một module', 'Tải file lên server', 'Xuất bản module'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Lệnh nào dùng để khởi tạo một dự án Node.js mới và tạo file package.json?',
        'options': ['npm start', 'npm install', 'npm init', 'npm run'],
        'correctIndex': 2,
        'timeLimit': 20,
      },
      {
        'text': 'Trong Express.js, middleware là gì?',
        'options': ['Một database', 'Hàm trung gian có quyền truy cập đối tượng request, response và hàm middleware kế tiếp', 'Trình biên dịch mã nguồn', 'Giao diện web'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Thư viện nào phổ biến nhất để băm (hash) mật khẩu trong Node.js?',
        'options': ['bcrypt', 'crypto-js', 'md5', 'sha256'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Hàm nào dùng để đọc nội dung file một cách đồng bộ trong module "fs"?',
        'options': ['fs.readFile()', 'fs.readFileSync()', 'fs.read()', 'fs.syncRead()'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Đối tượng "process" trong Node.js là gì?',
        'options': ['Một hàm xử lý', 'Đối tượng toàn cục cung cấp thông tin và điều khiển tiến trình Node.js hiện tại', 'Lớp kết nối database', 'Một luồng chạy ngầm'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Đối tượng nào trong Node.js dùng để làm việc với dữ liệu nhị phân trực tiếp?',
        'options': ['String', 'Array', 'Buffer', 'Stream'],
        'correctIndex': 2,
        'timeLimit': 20,
      },
      {
        'text': 'Module built-in nào cung cấp các tiện ích xử lý đường dẫn file và thư mục?',
        'options': ['fs', 'path', 'url', 'os'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'npm là viết tắt của từ gì?',
        'options': ['Node Package Manager', 'Node Programming Module', 'Network Process Manager', 'Node Project Manager'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Làm thế nào để lắng nghe một sự kiện tùy chỉnh trong Node.js?',
        'options': ['Sử dụng EventListener', 'Sử dụng EventEmitter', 'Sử dụng EventLoop', 'Sử dụng Callback'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Framework nào được viết bằng TypeScript giúp xây dựng ứng dụng backend Node.js có kiến trúc chặt chẽ (giống Angular)?',
        'options': ['Koa', 'Sails', 'NestJS', 'AdonisJS'],
        'correctIndex': 2,
        'timeLimit': 20,
      },
      {
        'text': 'Trong npm, cờ "--save-dev" hoặc "-D" dùng để làm gì?',
        'options': ['Cài đặt dependency chỉ dùng cho môi trường phát triển', 'Cài đặt global', 'Cập nhật package', 'Gỡ bỏ dependency'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Thư viện nào dùng để nạp các biến môi trường từ file ".env"?',
        'options': ['config', 'dotenv', 'env-loader', 'process-env'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Cơ chế Event Loop có mấy pha chính?',
        'options': ['2 pha', '4 pha', '6 pha', '8 pha'],
        'correctIndex': 2,
        'timeLimit': 20,
        'hintText': 'Gồm: timers, pending callbacks, idle/prepare, poll, check, close callbacks.',
      },
      {
        'text': 'Đâu KHÔNG phải là một module built-in của Node.js?',
        'options': ['http', 'crypto', 'lodash', 'zlib'],
        'correctIndex': 2,
        'timeLimit': 20,
      },
      {
        'text': 'Hàm "setImmediate()" chạy ở pha nào của Event Loop?',
        'options': ['Check', 'Poll', 'Timers', 'Close'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Để chạy các tác vụ nặng (CPU-intensive) mà không làm chặn Event Loop, Node.js cung cấp giải pháp gì?',
        'options': ['Callback', 'Worker Threads', 'Async/Await', 'Promises'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Phương thức HTTP nào an toàn (Safe) và có tính chất idempotent theo đặc tả REST?',
        'options': ['POST', 'GET', 'PATCH', 'Cả B và C'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Trạng thái mã lỗi (Status Code) HTTP nào chỉ ra lỗi "Unauthorized"?',
        'options': ['400', '401', '403', '404'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Trong Node.js, luồng (Stream) có mấy loại chính?',
        'options': ['2 loại', '3 loại', '4 loại', '5 loại'],
        'correctIndex': 2,
        'timeLimit': 20,
        'hintText': 'Gồm: Readable, Writable, Duplex và Transform.',
      },
      {
        'text': 'ODM (Object Document Mapper) phổ biến nhất để kết nối Node.js với MongoDB là gì?',
        'options': ['Sequelize', 'Mongoose', 'Prisma', 'TypeORM'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'JWT (JSON Web Token) gồm có mấy phần phân tách nhau bởi dấu chấm?',
        'options': ['2', '3', '4', '5'],
        'correctIndex': 1,
        'timeLimit': 20,
        'hintText': 'Gồm: Header, Payload và Signature.',
      },
      {
        'text': 'Công cụ nào dùng để tự động khởi động lại ứng dụng Node.js khi phát hiện thay đổi trong mã nguồn?',
        'options': ['nodemon', 'pm2', 'ts-node', 'webpack'],
        'correctIndex': 0,
        'timeLimit': 20,
      }
    ];
  }

  static List<Map<String, dynamic>> _getHistoryQuestions() {
    return [
      {
        'text': 'Chiến thắng Bạch Đằng năm 938 do ai lãnh đạo để kết thúc hơn 1000 năm Bắc thuộc?',
        'options': ['Ngô Quyền', 'Lê Lợi', 'Đinh Bộ Lĩnh', 'Trần Hưng Đạo'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Triều đại phong kiến nào đầu tiên ở Việt Nam đặt tên nước là Đại Cồ Việt?',
        'options': ['Triều Lý', 'Triều Đinh', 'Triều Lê', 'Triều Trần'],
        'correctIndex': 1,
        'timeLimit': 20,
        'hintText': 'Do Đinh Tiên Hoàng đế sáng lập.',
      },
      {
        'text': 'Ai là người viết bản tuyên ngôn độc lập đầu tiên "Nam Quốc Sơn Hà"?',
        'options': ['Nguyễn Trãi', 'Lý Thường Kiệt', 'Trần Hưng Đạo', 'Chu Văn An'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Năm 1010, vua Lý Thái Tổ đã dời đô từ Hoa Lư về đâu?',
        'options': ['Cổ Loa', 'Thăng Long', 'Phú Xuân', 'Tây Đô'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Vương triều nào đã ba lần đánh bại quân xâm lược Nguyên Mông?',
        'options': ['Nhà Lý', 'Nhà Trần', 'Nhà Lê', 'Nhà Nguyễn'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Bản tuyên ngôn độc lập thứ hai của nước ta mang tên gì?',
        'options': ['Nam Quốc Sơn Hà', 'Bình Ngô Đại Cáo', 'Tuyên ngôn Độc lập', 'Hịch Tướng Sĩ'],
        'correctIndex': 1,
        'timeLimit': 20,
        'hintText': 'Do Nguyễn Trãi thừa lệnh Lê Lợi viết sau khi bình định quân Minh.',
      },
      {
        'text': 'Người anh hùng áo vải Tây Sơn đại phá quân Thanh vào dịp Tết Kỷ Dậu 1789 là ai?',
        'options': ['Nguyễn Huệ (Quang Trung)', 'Nguyễn Nhạc', 'Nguyễn Lữ', 'Gia Long'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Triều đại phong kiến cuối cùng trong lịch sử Việt Nam là triều đại nào?',
        'options': ['Nhà Hậu Lê', 'Nhà Tây Sơn', 'Nhà Nguyễn', 'Nhà Mạc'],
        'correctIndex': 2,
        'timeLimit': 20,
      },
      {
        'text': 'Thành phố nào từng là kinh đô của triều đại nhà Nguyễn?',
        'options': ['Hà Nội', 'Huế', 'Đà Nẵng', 'Ninh Bình'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Ngày tháng năm nào Chủ tịch Hồ Chí Minh đọc bản Tuyên ngôn Độc lập khai sinh ra nước Việt Nam Dân chủ Cộng hòa?',
        'options': ['19/08/1945', '02/09/1945', '30/04/1975', '22/12/1944'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Trận Điện Biên Phủ trên không năm 1972 diễn ra ở đâu?',
        'options': ['Hải Phòng', 'Hà Nội và một số tỉnh miền Bắc', 'Quảng Trị', 'Sài Gòn'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Chiến dịch Điện Biên Phủ lừng lẫy năm châu chấn động địa cầu kết thúc thắng lợi vào ngày nào?',
        'options': ['30/04/1954', '07/05/1954', '19/05/1954', '02/09/1954'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Ai là Tổng tư lệnh tối cao chỉ huy chiến dịch Điện Biên Phủ năm 1954?',
        'options': ['Đại tướng Võ Nguyên Giáp', 'Đại tướng Văn Tiến Dũng', 'Chủ tịch Hồ Chí Minh', 'Đồng chí Trường Chinh'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Ngày giải phóng hoàn toàn miền Nam, thống nhất đất nước là ngày nào?',
        'options': ['30/04/1975', '01/05/1975', '19/08/1945', '27/07/1975'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Nhà nước cổ đại đầu tiên trong lịch sử Việt Nam có tên gọi là gì?',
        'options': ['Âu Lạc', 'Vạn Xuân', 'Văn Lang', 'Đại Việt'],
        'correctIndex': 2,
        'timeLimit': 20,
      },
      {
        'text': 'Thành Cổ Loa gắn liền với triều đại của vị vua nào?',
        'options': ['Hùng Vương', 'An Dương Vương', 'Triệu Đà', 'Đinh Bộ Lĩnh'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Khởi nghĩa Hai Bà Trưng chống lại ách đô hộ của nhà Đông Hán nổ ra vào năm nào?',
        'options': ['Năm 40', 'Năm 938', 'Năm 248', 'Năm 542'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Ai là người lãnh đạo cuộc khởi nghĩa Lam Sơn đánh đuổi quân Minh xâm lược?',
        'options': ['Lê Lợi', 'Nguyễn Trãi', 'Trần Nguyên Hãn', 'Lê Thánh Tông'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Thầy giáo được mệnh danh là Vạn thế sư biểu (Người thầy chuẩn mực muôn đời) của Việt Nam?',
        'options': ['Nguyễn Bỉnh Khiêm', 'Chu Văn An', 'Lê Quý Đôn', 'Nguyễn Du'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Vị Trạng nguyên trẻ tuổi nhất trong lịch sử khoa bảng Việt Nam là ai?',
        'options': ['Lương Thế Vinh', 'Nguyễn Hiền', 'Mạc Đĩnh Chi', 'Lê Quý Đôn'],
        'correctIndex': 1,
        'timeLimit': 20,
        'hintText': 'Đỗ Trạng nguyên khi mới 12 tuổi.',
      },
      {
        'text': 'Tập đoàn quân sự họ nào đã xây dựng Lũy Thầy ở Quảng Bình để ngăn chặn quân Đàng Ngoài?',
        'options': ['Họ Trịnh', 'Họ Nguyễn', 'Họ Mạc', 'Họ Hồ'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Thương cảng sầm uất nhất ở Đàng Trong thế kỷ 17 - 18 ngày nay là di sản văn hóa nào?',
        'options': ['Phố cổ Hội An', 'Cố đô Huế', 'Thánh địa Mỹ Sơn', 'Đầm Thị Nại'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Phong trào Đông Du đầu thế kỷ 20 đưa học sinh sang Nhật du học do ai khởi xướng?',
        'options': ['Phan Bội Châu', 'Phan Châu Trinh', 'Huỳnh Thúc Kháng', 'Nguyễn Thái Học'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Đảng Cộng sản Việt Nam được thành lập vào ngày tháng năm nào?',
        'options': ['03/02/1930', '19/05/1941', '22/12/1944', '02/09/1945'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Tên gọi khác của triều đại Nhà Hồ (do Hồ Quý Ly sáng lập) đặt cho nước ta?',
        'options': ['Đại Cồ Việt', 'Đại Ngu', 'Đại Việt', 'Đại Nam'],
        'correctIndex': 1,
        'timeLimit': 20,
        'hintText': 'Chữ "Ngu" ở đây mang nghĩa là sự yên vui, thái bình lâu dài.',
      }
    ];
  }

  static List<Map<String, dynamic>> _getTravelQuestions() {
    return [
      {
        'text': 'Vịnh biển nào của Việt Nam được UNESCO công nhận là Kỳ quan thiên nhiên thế giới mới?',
        'options': ['Vịnh Nha Trang', 'Vịnh Hạ Long', 'Vịnh Lăng Cô', 'Vịnh Xuân Đài'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Thành phố du lịch nào nổi tiếng với các ruộng bậc thang tuyệt đẹp ở vùng Tây Bắc?',
        'options': ['Đà Lạt', 'Nha Trang', 'Sa Pa', 'Mũi Né'],
        'correctIndex': 2,
        'timeLimit': 20,
      },
      {
        'text': 'Đền tháp Chăm nổi tiếng nào nằm ở tỉnh Quảng Nam đã được công nhận là Di sản văn hóa thế giới?',
        'options': ['Tháp Bà Ponagar', 'Thánh địa Mỹ Sơn', 'Tháp Nhạn', 'Tháp Po Klong Garai'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Hang động tự nhiên lớn nhất thế giới nằm ở tỉnh nào của Việt Nam?',
        'options': ['Quảng Ninh', 'Quảng Bình', 'Ninh Bình', 'Cao Bằng'],
        'correctIndex': 1,
        'timeLimit': 20,
        'hintText': 'Đó chính là hang Sơn Đoòng nằm ở Vườn quốc gia Phong Nha - Kẻ Bàng.',
      },
      {
        'text': 'Địa danh du lịch Tràng An nằm ở tỉnh nào?',
        'options': ['Thanh Hóa', 'Ninh Bình', 'Hòa Bình', 'Nam Định'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Đảo nào được mệnh danh là "Đảo Ngọc" lớn nhất của Việt Nam?',
        'options': ['Đảo Cát Bà', 'Đảo Lý Sơn', 'Đảo Phú Quốc', 'Đảo Côn Đảo'],
        'correctIndex': 2,
        'timeLimit': 20,
      },
      {
        'text': 'Nét văn hóa chợ nổi trên sông đặc trưng của vùng nào nước ta?',
        'options': ['Tây Nguyên', 'Đồng bằng sông Cửu Long', 'Duyên hải Nam Trung Bộ', 'Đồng bằng sông Hồng'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Món ăn truyền thống nào của Việt Nam gồm có bánh phở, nước dùng hầm xương bò/gà và thịt thái lát mỏng?',
        'options': ['Bún bò Huế', 'Hủ tiếu Nam Vang', 'Phở', 'Bánh canh'],
        'correctIndex': 2,
        'timeLimit': 20,
      },
      {
        'text': 'Cao nguyên đá Đồng Văn nổi tiếng thuộc tỉnh nào ở cực Bắc Tổ quốc?',
        'options': ['Lào Cai', 'Hà Giang', 'Cao Bằng', 'Yên Bái'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Bán đảo nổi tiếng nào nằm ở Đà Nẵng sở hữu bức tượng Phật Bà Quan Âm cao nhất Việt Nam?',
        'options': ['Bán đảo Sơn Trà', 'Bán đảo Phương Mai', 'Mũi Dinh', 'Bán đảo Đồ Sơn'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Món ăn "Bún chả" nổi tiếng là đặc sản ẩm thực của thành phố nào?',
        'options': ['Hải Phòng', 'Huế', 'Hà Nội', 'Đà Nẵng'],
        'correctIndex': 2,
        'timeLimit': 20,
      },
      {
        'text': 'Hội An từng là thương cảng sầm uất bên dòng sông nào?',
        'options': ['Sông Thu Bồn', 'Sông Hương', 'Sông Hàn', 'Sông Trà Khúc'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Địa danh nào được mệnh danh là "Thành phố sương mù" hay "Thành phố ngàn hoa" ở Tây Nguyên?',
        'options': ['Buôn Ma Thuột', 'Đà Lạt', 'Pleiku', 'Kon Tum'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Đỉnh núi được mệnh danh là "Nóc nhà Đông Dương" nằm trên dãy Hoàng Liên Sơn tên là gì?',
        'options': ['Fansipan', 'Mẫu Sơn', 'Tây Côn Lĩnh', 'Bạch Mộc Lương Tử'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Bãi cát đỏ khổng lồ (Đồi Cát Bay) là biểu tượng du lịch của vùng biển nào?',
        'options': ['Nha Trang', 'Mũi Né (Phan Thiết)', 'Vũng Tàu', 'Quy Nhơn'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Lễ hội Đua ghe Ngo đặc sắc là nét văn hóa truyền thống của đồng bào dân tộc nào ở Nam Bộ?',
        'options': ['Khmer', 'Chăm', 'Hoa', 'Mường'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Nhạc cụ truyền thống độc đáo nào của Việt Nam chỉ có một dây nhưng tạo ra âm điệu vô cùng réo rắt?',
        'options': ['Đàn Nhị', 'Đàn Bầu', 'Đàn Tranh', 'Đàn Nguyệt'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Dòng sông thơ mộng chảy qua lòng thành phố Huế cổ kính có tên là gì?',
        'options': ['Sông Hoài', 'Sông Hương', 'Sông Hàn', 'Sông Lam'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Địa điểm du lịch sinh thái Măng Đen nổi tiếng ở tỉnh nào thuộc vùng Tây Nguyên?',
        'options': ['Lâm Đồng', 'Gia Lai', 'Kon Tum', 'Đắk Lắk'],
        'correctIndex': 2,
        'timeLimit': 20,
      },
      {
        'text': 'Trại giam lịch sử nổi tiếng thời chiến tranh ngày nay là điểm tham quan tâm linh nổi tiếng tại đảo nào?',
        'options': ['Phú Quốc', 'Côn Đảo', 'Cát Bà', 'Lý Sơn'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Nhà thờ Đá cổ nổi tiếng được người Pháp xây dựng nằm ở trung tâm điểm du lịch nào?',
        'options': ['Sa Pa', 'Đà Lạt', 'Tam Đảo', 'Mẫu Sơn'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Di sản thế giới nào của Việt Nam nằm ở tỉnh Cao Bằng giáp ranh biên giới Trung Quốc?',
        'options': ['Động Ngườm Ngao', 'Hồ Ba Bể', 'Thác Bản Giốc', 'Công viên địa chất non nước Cao Bằng'],
        'correctIndex': 3,
        'timeLimit': 20,
        'hintText': 'Đây là Công viên Địa chất toàn cầu được UNESCO công nhận năm 2018.',
      },
      {
        'text': 'Vương quốc hang động thế giới Phong Nha - Kẻ Bàng thuộc tỉnh nào?',
        'options': ['Quảng Trị', 'Quảng Bình', 'Hà Tĩnh', 'Thừa Thiên Huế'],
        'correctIndex': 1,
        'timeLimit': 20,
      },
      {
        'text': 'Lễ hội văn hóa nào lớn nhất được tổ chức định kỳ 2 năm một lần tại cố đô Huế?',
        'options': ['Festival Huế', 'Lễ hội hoa đăng', 'Lễ hội đền Trần', 'Lễ hội Điện Hòn Chén'],
        'correctIndex': 0,
        'timeLimit': 20,
      },
      {
        'text': 'Món bánh tráng phơi sương Trảng Bàng nổi tiếng là đặc sản của tỉnh nào?',
        'options': ['Bình Phước', 'Long An', 'Tây Ninh', 'Đồng Nai'],
        'correctIndex': 2,
        'timeLimit': 20,
      }
    ];
  }
}
