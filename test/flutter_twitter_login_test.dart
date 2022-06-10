import 'package:flutter/services.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$TwitterLogin', () {
    const MethodChannel channel = const MethodChannel(
      'com.roughike/flutter_twitter_login',
    );

    const sesson = const {
      'username': 'test_user_name',
      'userId': 'abc123',
      'token': 'test_access_token',
      'secret': 'test_secret',
    };

    const loggedInResponse = const {
      'status': 'loggedIn',
      'session': sesson,
    };

    const tokenAndSecret = const {
      'consumerKey': 'consumer_key',
      'consumerSecret': 'consumer_secret',
    };

    const errorResponse = const {
      'status': 'error',
      'errorMessage': 'test error message',
    };

    final List<MethodCall> log = [];
    late TwitterLogin sut;

    void setMethodCallResponse(Map<String, dynamic>? response) {
      channel.setMockMethodCallHandler((MethodCall methodCall) {
        log.add(methodCall);
        return new Future.value(response);
      });
    }

    void expectSessionParsedCorrectly(TwitterSession session) {
      expect(session.username, 'test_user_name');
      expect(session.userId, 'abc123');
      expect(session.token, 'test_access_token');
      expect(session.secret, 'test_secret');
    }

    setUp(() {
      sut = new TwitterLogin(
        consumerKey: 'consumer_key',
        consumerSecret: 'consumer_secret',
      );

      log.clear();
    });

    test('can not call constructor with empty key or secret', () {
      expect(() => new TwitterLogin(consumerKey: 'key', consumerSecret: ''),
          throwsA(anything));
      expect(() => new TwitterLogin(consumerKey: '', consumerSecret: 'secret'),
          throwsA(anything));
    });

    test('get isSessionActive - false when currentSession is null', () async {
      setMethodCallResponse(null);

      final bool isSessionActive = await sut.isSessionActive;
      expect(isSessionActive, isFalse);
      expect(log, [
        isMethodCall(
          'getCurrentSession',
          arguments: tokenAndSecret,
        ),
      ]);
    });

    test('get isSessionActive - true when currentSession is not null',
        () async {
      setMethodCallResponse(sesson);

      final bool isSessionActive = await sut.isSessionActive;
      expect(isSessionActive, isTrue);
      expect(log, [
        isMethodCall(
          'getCurrentSession',
          arguments: tokenAndSecret,
        ),
      ]);
    });

    test('get currentSession - handles null response gracefully', () async {
      setMethodCallResponse(null);

      final TwitterSession? session = await sut.currentSession;
      expect(session, isNull);
      expect(log, [
        isMethodCall(
          'getCurrentSession',
          arguments: tokenAndSecret,
        ),
      ]);
    });

    test('get currentSession - parses session correctly', () async {
      setMethodCallResponse(sesson);

      final session = await sut.currentSession;
      expectSessionParsedCorrectly(session!);
      expect(log, [
        isMethodCall(
          'getCurrentSession',
          arguments: tokenAndSecret,
        ),
      ]);
    });

    test('authorize - calls the right method', () async {
      setMethodCallResponse(loggedInResponse);

      await sut.authorize();

      expect(log, [
        isMethodCall(
          'authorize',
          arguments: tokenAndSecret,
        ),
      ]);
    });

    test('authorize - user logged in', () async {
      setMethodCallResponse(loggedInResponse);

      final TwitterLoginResult result = await sut.authorize();

      expect(result.status, TwitterLoginStatus.loggedIn);
      expectSessionParsedCorrectly(result.session!);
    });

    test('authorize - cancelled by user', () async {
      setMethodCallResponse({
        'status': 'error',
        'errorMessage': 'Authorization failed, request was canceled.',
      });

      final TwitterLoginResult androidResult = await sut.authorize();
      expect(androidResult.status, TwitterLoginStatus.cancelledByUser);

      setMethodCallResponse({
        'status': 'error',
        'errorMessage': 'User cancelled authentication.',
      });

      final TwitterLoginResult iosResult = await sut.authorize();
      expect(iosResult.status, TwitterLoginStatus.cancelledByUser);
    });

    test('authorize - error', () async {
      setMethodCallResponse(errorResponse);

      final TwitterLoginResult result = await sut.authorize();
      expect(result.status, TwitterLoginStatus.error);
    });

    test('logout', () async {
      setMethodCallResponse(null);

      await sut.logOut();

      expect(log, [
        isMethodCall(
          'logOut',
          arguments: tokenAndSecret,
        )
      ]);
    });

    test('access token equality test', () {
      final TwitterSession first = new TwitterSession.fromMap(sesson);
      final TwitterSession second = new TwitterSession.fromMap(sesson);

      expect(first, equals(second));
    });

    test('access token from and to Map', () async {
      final TwitterSession session = new TwitterSession.fromMap(sesson);

      expectSessionParsedCorrectly(session);
      expect(
        session.toMap(),
        {
          'username': 'test_user_name',
          'userId': 'abc123',
          'token': 'test_access_token',
          'secret': 'test_secret',
        },
      );
    });
  });
}
