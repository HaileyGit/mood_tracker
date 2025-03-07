# 나쁜 습관 버리기 앱

Flutter와 Firebase를 사용한 나쁜 습관 관리 앱입니다.

## 주요 기능

### 1. 인증
- Firebase Authentication을 사용한 이메일/비밀번호 로그인
- 자동 로그인 지원

### 2. 습관 관리
- 습관 추가/삭제 기능
- 습관별 설명 추가 가능
- Firestore를 사용한 실시간 데이터 동기화

### 3. 일일 기록
- 캘린더 UI로 기록 확인 (table_calendar 패키지 사용)
- 성공/실패 여부 기록
- 이모지로 감정 표현
- 메모 작성 기능
- 날짜별 기록 조회

### 4. UI/UX
- Material Design 3 적용
- 커스텀 테마 (노란색/갈색 계열)
- 반응형 디자인
- 로딩 상태 표시
- 에러 처리

## 사용된 기술

### 상태 관리
- Riverpod
- StateNotifier
- AsyncValue를 통한 로딩/에러 상태 처리

### 라우팅
- go_router를 사용한 네비게이션
- 인증 상태에 따른 라우트 보호

### Firebase
- Authentication
- Firestore
- Firebase Core

### 기타 패키지
- table_calendar
- uuid
- intl

## 프로젝트 구조
```
lib/
├── constants/
│ └── app_colors.dart
├── models/
│ └── habit.dart
├── providers/
│ └── providers.dart
├── repositories/
│ ├── daily_record_repository.dart
│ └── habit_repository.dart
├── routes/
│ └── app_router.dart
├── screens/
│ ├── auth_screen.dart
│ ├── home_screen.dart
│ └── habit_list_screen.dart
├── view_models/
│ ├── auth_view_model.dart
│ ├── daily_record_view_model.dart
│ └── habit_view_model.dart
└── main.dart
```

## 아키텍처

- MVVM 패턴 적용
- Repository 패턴으로 데이터 액세스 계층 분리
- ViewModel을 통한 비즈니스 로직 처리
- Provider를 통한 의존성 주입