import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../utils/event.dart';

class HFGlobalState with ChangeNotifier, DiagnosticableTreeMixin {
  int _rootPageIndex = 0;
  int get rootPageIndex => _rootPageIndex;

  void setRootPage(newIndex) {
    _rootPageIndex = newIndex;
    notifyListeners();
  }

  var _calendarSelectedDay = DateTime.parse(
      '${DateFormat('yyyy-MM-dd').format(DateTime.now())} 00:00:00.000Z');
  get calendarSelectedDay => _calendarSelectedDay;

  void setCalendarSelectedDay(state) {
    _calendarSelectedDay = state;
    notifyListeners();
  }

  var _splashScreenState = SplashScreens.splash;
  get splashScreenState => _splashScreenState;

  void setSplashScreenState(state) {
    _splashScreenState = state;
    notifyListeners();
  }

  var _rootScreenState = RootScreens.home;
  get rootScreenState => _rootScreenState;

  void setRootScreenState(state) {
    _rootScreenState = state;
    notifyListeners();
  }

  var _userAccessLevel = accessLevels.client;
  get userAccessLevel => _userAccessLevel;

  void setUserAccessLevel(level) {
    switch (level) {
      case 3:
        _userAccessLevel = accessLevels.client;
        break;
      case null:
        _userAccessLevel = accessLevels.trainer;
        break;
      default:
        _userAccessLevel = accessLevels.trainer;
    }

    notifyListeners();
  }

  var _userDisplayName = 'Fullname';
  get userDisplayName => _userDisplayName;

  void setUserDisplayName(name) {
    _userDisplayName = name;
    notifyListeners();
  }

  var _userFirstName = '';
  get userFirstName => _userFirstName;

  void setUserFirstName(name) {
    _userFirstName = name;
    notifyListeners();
  }

  var _userLastName = '';
  get userLastName => _userLastName;

  void setUserLastName(name) {
    _userLastName = name;
    notifyListeners();
  }

  var _userBirthday = '';
  get userBirthday => _userBirthday;

  void setUserBirthday(name) {
    _userBirthday = name;
    notifyListeners();
  }

  var _userHeight = '';
  get userHeight => _userHeight;

  void setUserHeight(name) {
    _userHeight = name;
    notifyListeners();
  }

  var _userWeight = '';
  get userWeight => _userWeight;

  void setUserWeight(name) {
    _userWeight = name;
    notifyListeners();
  }

  var _userLocations = [];
  get userLocations => _userLocations;

  void setUserLocations(name) {
    _userLocations = name;
    notifyListeners();
  }

  var _userEmail = '';
  get userEmail => _userEmail;

  void setUserEmail(email) {
    _userEmail = email;
    notifyListeners();
  }

  var _userImage = '';
  get userImage => _userImage;

  void setUserImage(imageUrl) {
    _userImage = imageUrl;
    notifyListeners();
  }

  var _userBackgroundImage = '';
  get userBackgroundImage => _userBackgroundImage;

  void setUserBackgroundImage(imageUrl) {
    _userBackgroundImage = imageUrl;
    notifyListeners();
  }

  var _userNewAccount = false;
  get userNewAccount => _userNewAccount;

  void setUserNewAccount(newAccount) {
    _userNewAccount = newAccount;
    notifyListeners();
  }

  var _inputFieldFocused = false;
  get inputFieldFocused => _inputFieldFocused;

  void setInputFieldFocused(focused) {
    _inputFieldFocused = focused;
    notifyListeners();
  }

  var _userSubscriptionTier = '';
  get userSubscriptionTier => _userSubscriptionTier;

  void setUserSubscriptionTier(tier) {
    _userSubscriptionTier = tier;
    notifyListeners();
  }

  var _userId = '';
  get userId => _userId;

  void setUserId(id) {
    _userId = id;
    notifyListeners();
  }

  var _userIsAdmin = false;
  get userIsAdmin => _userIsAdmin;

  void setUserIsAdmin(isAdmin) {
    _userIsAdmin = isAdmin;
    notifyListeners();
  }

  var _userTrainerId = '';
  get userTrainerId => _userTrainerId;

  void setUserTrainerId(id) {
    _userTrainerId = id;
    notifyListeners();
  }

  var _userIntro = '';
  get userIntro => _userIntro;

  void setUserIntro(id) {
    _userIntro = id;
    notifyListeners();
  }

  var _userEducation = '';
  get userEducation => _userEducation;

  void setUserEducation(id) {
    _userEducation = id;
    notifyListeners();
  }

  var _userAvailable = false;
  get userAvailable => _userAvailable;

  void setUserAvailable(id) {
    _userAvailable = id;
    notifyListeners();
  }

  var _userName = '';
  get userName => _userName;

  void setUserName(name) {
    _userName = name;
    notifyListeners();
  }

  var _userLoggedIn = false;
  get userLoggedIn => _userLoggedIn;

  void setUserLoggedIn(isLoggedIn) {
    _userLoggedIn = isLoggedIn;
    notifyListeners();
  }

  Map<DateTime, List<Event>> _calendarEvents = {};
  Map<DateTime, List<Event>> get calendarEvents => _calendarEvents;

  void setCalendarDays(Map<DateTime, List<Event>> days) {
    _calendarEvents = days;
    notifyListeners();
  }

  String _calendarLastUpdated = 'never';
  String get calendarLastUpdated => _calendarLastUpdated;

  void setCalendarLastUpdated(date) {
    _calendarLastUpdated = date;

    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('rootPageIndex', rootPageIndex));
  }
}

enum SplashScreens {
  splash,
  login,
  reset,
  loggedIn,
  findTrainer,
}

enum RootScreens {
  login,
  welcome,
  home,
  calendar,
  chat,
  settings,
}

enum accessLevels {
  admin,
  trainer,
  client,
}
