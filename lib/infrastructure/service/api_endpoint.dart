import 'package:path/path.dart' as p;

class ApiEndPoints {
  // Avoid self instance
  ApiEndPoints._();

  // https://qa02.lead.academy/api/v1/
  // static const String baseURL = 'http://192.168.2.125:9017/wah/';
  // static const String baseURL = 'http://195.35.24.112:9018/wah/';
  // static const String baseURL = 'http://195.35.24.112:9017/wah/';
  static const String baseURL = 'http://192.168.1.147:9017/wah/';
  // 192.168.1.147
  // static const String baseURL = 'http://192.168.1.147:3000/';
  static const String apiVersion = 'api/';

  static const String baseURL2 = 'http://192.168.1.147:9017/wah/';
  // static const String baseURL2 = 'http://195.35.24.112:9018/wah/';
  // static const String baseURL2 = 'http://195.35.24.112:9017/wah/';
  // static const String baseURL2 = 'http://192.168.2.125:9017/wah/';
  // static const String baseURL2 = 'http://192.168.2.125:3000/';
  // static const String apiVersion2 = 'api/v1/';
  static String apiEndpoint = p.join(baseURL, apiVersion);
  static String apiEndpoint2 = p.join(baseURL2);

  static final HomeModule homeModule = HomeModule();
  static final AuthModule authModule = AuthModule();
  static final QuizModule quizModule = QuizModule();
  static final TaskModule taskModule = TaskModule();
  // static final TrackModule trackModule = TrackModule();
  // static final ClassReportModule classReportModule = ClassReportModule();
  // static final PaymentModule paymentModule = PaymentModule();
  // static final ProfileDashboardModule profileDashboardModule = ProfileDashboardModule();
  // static final ProfileModule profileModule = ProfileModule();
  // static final ClassModule classModule = ClassModule();
}

class HomeModule {
  static final String _baseURL = ApiEndPoints.apiEndpoint;
  final String homeData = p.join(_baseURL, 'home');
  final String getDate = p.join(_baseURL, 'trial-class-schedule-date');
  final String getTime = p.join(_baseURL, 'trial-class-schedule-time');
  final String getUpcomingTrialClasses = p.join(
    _baseURL,
    'upcoming-trial-classes',
  );
  final String registrationTrialClass = p.join(_baseURL, 'registration');
}

class AuthModule {
  static final String _baseURL = ApiEndPoints.apiEndpoint;
  final String login = p.join(_baseURL, 'wahUser/login');
  // final String login = p.join(_baseURL, 'login');
  final String login2 = p.join(_baseURL, 'wahUser/login2');
  final String registration = p.join(_baseURL, 'registration');
  final String parent = p.join(_baseURL, 'parent');

  String login3 (String uName, String uPass) => p.join(_baseURL, 'wahUser/login?email_address=$uName&password=$uPass');
}

class QuizModule {
  static final String _baseURL = ApiEndPoints.apiEndpoint2;
  // final String login = p.join(_baseURL, 'wahUser/login');
  final String getQuizList = p.join(_baseURL, 'exam/list');
  final String getQuizSet = p.join(_baseURL, 'exam/getSet');
  final String generateQuizSet = p.join(_baseURL, 'set/generate_quiz_set');
  final String subjectGroup = p.join(_baseURL, 'set/get_subject_group');
  final String subjectWiseQuestions = p.join(_baseURL, 'set/generate_subject_group_sets');


  final String getQuestionSet = p.join(_baseURL, 'set/get_questions_by_set');
  String getQuestionSetUrl(dynamic setId) =>
      p.join(_baseURL, 'set/get_questions_by_set/$setId');
}

class TaskModule {
  static final String _baseURL = ApiEndPoints.apiEndpoint2;
  final String pointAdd = p.join(_baseURL, 'tranDetails/save');
  final String balance = p.join(_baseURL, 'tranDetails/balance');
}
