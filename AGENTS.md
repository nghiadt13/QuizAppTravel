# Flutter Clean Architecture & MVVM (Feature-First) Guidelines

Tài liệu này hướng dẫn cách phát triển tính năng mới trong dự án **QuizAppTravel** tuân thủ đúng chuẩn kiến trúc **Clean Architecture + MVVM** theo định hướng **Feature-First (Module hóa)**.

---

## 1. Cấu trúc một Feature (Module)

Mỗi tính năng mới (ví dụ: `weather`) phải được tạo riêng một thư mục con nằm trong `lib/features/` với cấu trúc 3 lớp như sau:

```text
lib/features/weather/
├── domain/                      # LỚP NGHIỆP VỤ (Core Business Logic)
│   ├── entities/                # Thực thể dữ liệu thuần túy dùng trên giao diện
│   └── repositories/            # Các Interface (Lớp trừu tượng) định nghĩa các hàm gọi dữ liệu
│
├── data/                        # LỚP DỮ LIỆU (Implementation & Data Handling)
│   ├── datasource/              # Trực tiếp kết nối Firebase Firestore / API / Local Storage
│   ├── dtos/                    # Data Transfer Objects dùng để parse JSON từ Firebase/API
│   ├── mappers/                 # Lớp ánh xạ chuyển đổi qua lại giữa DTO và Entity
│   └── repositories/            # Hiện thực hóa (Implement) các Interface của domain
│
└── presentation/                # LỚP GIAO DIỆN (UI & ViewModels)
    ├── views/                   # Các màn hình chính (Screens/Pages) của tính năng
    ├── viewmodels/              # ViewModel quản lý State và Business Logic của giao diện
    └── widgets/                 # Các Widget nhỏ tái sử dụng riêng cho tính năng này
```

---

## 2. Quy tắc hoạt động của các tầng trong MVVM

### A. Tầng Domain (Độc lập 100%)
* **Nhiệm vụ**: Chứa logic nghiệp vụ cốt lõi của ứng dụng.
* **Quy tắc nghiêm ngặt**: **KHÔNG** import bất kỳ thư viện bên ngoài nào (như `cloud_firestore`, `dio`) hay thư viện UI (`flutter/material.dart`). Tầng này chỉ chứa code Dart thuần túy.
* **Thành phần**:
  * **Entity**: Lớp dữ liệu tối giản dùng để hiển thị lên màn hình.
  * **Repository Interface**: Khai báo danh sách các hàm mà tầng UI cần dùng (ví dụ: `Future<List<Weather>> getWeatherList()`).

### B. Tầng Data (Phụ thuộc vào Domain & Thư viện ngoài)
* **Nhiệm vụ**: Lấy dữ liệu thô, biến đổi và cung cấp cho Domain.
* **Quy tắc**: Thích ứng với các dịch vụ bên ngoài (Firebase, API). Nếu đổi từ Firebase sang API REST, ta chỉ sửa đổi ở tầng này.
* **Thành phần**:
  * **DTO (Data Transfer Object)**: Định nghĩa cấu trúc dữ liệu thô nhận về từ Firebase (ví dụ: `WeatherDto.fromFirestore(doc)`).
  * **Mapper**: Hàm chuyển đổi `WeatherDto` thành `Weather` (Entity) trước khi đẩy lên tầng trên.
  * **DataSource**: Lớp giao tiếp trực tiếp với Firebase (sử dụng `FirebaseFirestore.instance`).
  * **Repository Implementation**: Nhận vào `DataSource` thông qua Dependency Injection và thực hiện ghi đè hàm của Repository Interface ở tầng Domain.

### C. Tầng Presentation (Phụ thuộc vào Domain & State Management)
* **Nhiệm vụ**: Hiển thị dữ liệu lên màn hình và nhận tương tác từ người dùng.
* **Thành phần**:
  * **ViewModel**: Kế thừa `ChangeNotifier` (của Provider). Nhận dữ liệu từ Repository (Domain), cập nhật trạng thái (`notifyListeners()`) để giao diện vẽ lại.
  * **View (Screen)**: Widget giao diện lắng nghe trạng thái từ ViewModel để hiển thị và gọi hàm của ViewModel khi người dùng thao tác.

---

## 3. Các bước thêm mới một tính năng (Ví dụ: `weather`)

Khi cần thêm chức năng thời tiết (`weather`), hãy thực hiện lần lượt theo quy trình sau:

### Bước 1: Tạo cấu trúc thư mục
Tạo đầy đủ cấu trúc thư mục của feature `weather` như sơ đồ ở phần 1.

### Bước 2: Tạo Entity ở Domain
Tạo `lib/features/weather/domain/entities/weather.dart`:
```dart
class Weather {
  final String cityName;
  final double temperature;
  final String condition;

  Weather({required this.cityName, required this.temperature, required this.condition});
}
```

### Bước 3: Tạo Repository Interface ở Domain
Tạo `lib/features/weather/domain/repositories/i_weather_repository.dart`:
```dart
import '../entities/weather.dart';

abstract class IWeatherRepository {
  Future<Weather> getWeather(String city);
}
```

### Bước 4: Tạo DTO ở Data
Tạo `lib/features/weather/data/dtos/weather_dto.dart`:
```dart
class WeatherDto {
  final String city;
  final double temp;
  final String desc;

  WeatherDto({required this.city, required this.temp, required this.desc});

  factory WeatherDto.fromFirestore(Map<String, dynamic> json) {
    return WeatherDto(
      city: json['city'] ?? '',
      temp: (json['temp'] ?? 0.0).toDouble(),
      desc: json['desc'] ?? '',
    );
  }
}
```

### Bước 5: Tạo Mapper ở Data
Tạo `lib/features/weather/data/mappers/weather_mapper.dart`:
```dart
import '../../domain/entities/weather.dart';
import '../dtos/weather_dto.dart';

class WeatherMapper {
  static Weather toEntity(WeatherDto dto) {
    return Weather(
      cityName: dto.city,
      temperature: dto.temp,
      condition: dto.desc,
    );
  }
}
```

### Bước 6: Tạo DataSource ở Data
Tạo `lib/features/weather/data/datasource/weather_remote_data_source.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../dtos/weather_dto.dart';

class WeatherRemoteDataSource {
  final FirebaseFirestore _firestore;

  WeatherRemoteDataSource(this._firestore);

  Future<WeatherDto> fetchWeather(String city) async {
    final doc = await _firestore.collection('weather').doc(city).get();
    if (!doc.exists) throw Exception('City not found');
    return WeatherDto.fromFirestore(doc.data()!);
  }
}
```

### Bước 7: Tạo Repository Implementation ở Data
Tạo `lib/features/weather/data/repositories/weather_repository_impl.dart`:
```dart
import '../../domain/entities/weather.dart';
import '../../domain/repositories/i_weather_repository.dart';
import '../datasource/weather_remote_data_source.dart';
import '../mappers/weather_mapper.dart';

class WeatherRepositoryImpl implements IWeatherRepository {
  final WeatherRemoteDataSource _remoteDataSource;

  WeatherRepositoryImpl(this._remoteDataSource);

  @override
  Future<Weather> getWeather(String city) async {
    final dto = await _remoteDataSource.fetchWeather(city);
    return WeatherMapper.toEntity(dto);
  }
}
```

### Bước 8: Đăng ký Dependency Injection
Khai báo tính năng mới trong [lib/core/di.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/core/di.dart):
```dart
import '../features/weather/data/datasource/weather_remote_data_source.dart';
import '../features/weather/data/repositories/weather_repository_impl.dart';
import '../features/weather/domain/repositories/i_weather_repository.dart';
import '../features/weather/presentation/viewmodels/weather_view_model.dart';

Future<void> setupDependencies() async {
  // ... Các service cũ
  
  // ==========================================
  // Feature: Weather
  // ==========================================
  // Data Source
  getIt.registerLazySingleton<WeatherRemoteDataSource>(() => WeatherRemoteDataSource(getIt()));
  
  // Repository
  getIt.registerLazySingleton<IWeatherRepository>(() => WeatherRepositoryImpl(getIt()));

  // ViewModel
  getIt.registerFactory(() => WeatherViewModel(getIt()));
}
```

### Bước 9: Viết ViewModel ở Presentation
Tạo `lib/features/weather/presentation/viewmodels/weather_view_model.dart`:
```dart
import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/i_weather_repository.dart';

class WeatherViewModel extends ChangeNotifier {
  final IWeatherRepository _repository;
  
  WeatherViewModel(this._repository);

  Weather? _weather;
  Weather? get weather => _weather;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchWeather(String city) async {
    _isLoading = true;
    notifyListeners();

    try {
      _weather = await _repository.getWeather(city);
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### Bước 10: Viết View ở Presentation
Tạo giao diện nhận tương tác, dùng `ChangeNotifierProvider` hoặc `context.watch<WeatherViewModel>()` để cập nhật trạng thái.

---

## 4. Các lưu ý quan trọng cho Agent/Developer
1. **Dependency Injection**: Luôn luôn sử dụng `getIt<T>()` để lấy các instance, tuyệt đối không dùng `new` trực tiếp cho Repository hay DataSource.
2. **Import Cleanliness**: Không import bất kỳ file nào từ lớp `data` hay `presentation` vào lớp `domain`. Lớp `domain` phải hoàn toàn độc lập.
3. **DTOs vs Entities**: Luôn chuyển đổi DTO thành Entity bằng Mapper trước khi dữ liệu đi ra khỏi lớp `data`. Tầng UI không được phép tương tác trực tiếp với DTO.
