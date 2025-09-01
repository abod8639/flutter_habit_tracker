// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// ``
  String get drawer {
    return Intl.message('', name: 'drawer', desc: '', args: []);
  }

  /// `Theme Color`
  String get drawerTheme {
    return Intl.message('Theme Color', name: 'drawerTheme', desc: '', args: []);
  }

  /// `Rate`
  String get drawerReat {
    return Intl.message('Rate', name: 'drawerReat', desc: '', args: []);
  }

  /// `Setting`
  String get drawerSetting {
    return Intl.message('Setting', name: 'drawerSetting', desc: '', args: []);
  }

  /// `Theme Setting`
  String get themepagetitle {
    return Intl.message(
      'Theme Setting',
      name: 'themepagetitle',
      desc: '',
      args: [],
    );
  }

  /// `Custom Theme`
  String get themepage {
    return Intl.message('Custom Theme', name: 'themepage', desc: '', args: []);
  }

  /// `Habit Summary`
  String get Summary {
    return Intl.message('Habit Summary', name: 'Summary', desc: '', args: []);
  }

  /// `Habit Statistics`
  String get ratepagetitle {
    return Intl.message(
      'Habit Statistics',
      name: 'ratepagetitle',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get total {
    return Intl.message('Total', name: 'total', desc: '', args: []);
  }

  /// `Completed`
  String get completed {
    return Intl.message('Completed', name: 'completed', desc: '', args: []);
  }

  /// `Habit Success`
  String get success {
    return Intl.message('Habit Success', name: 'success', desc: '', args: []);
  }

  /// `Today Progress`
  String get today {
    return Intl.message('Today Progress', name: 'today', desc: '', args: []);
  }

  /// `Monthly Progress`
  String get monthly {
    return Intl.message(
      'Monthly Progress',
      name: 'monthly',
      desc: '',
      args: [],
    );
  }

  /// `weekly Progress`
  String get weekly {
    return Intl.message('weekly Progress', name: 'weekly', desc: '', args: []);
  }

  /// `Habit State`
  String get hambitstate {
    return Intl.message('Habit State', name: 'hambitstate', desc: '', args: []);
  }

  /// `Pending`
  String get pending {
    return Intl.message('Pending', name: 'pending', desc: '', args: []);
  }

  /// `No habits tracked yet`
  String get isEmpty {
    return Intl.message(
      'No habits tracked yet',
      name: 'isEmpty',
      desc: '',
      args: [],
    );
  }

  /// `No habit data available`
  String get BarChartisEmpty {
    return Intl.message(
      'No habit data available',
      name: 'BarChartisEmpty',
      desc: '',
      args: [],
    );
  }

  /// `No habits to display`
  String get PieChartisEmpty {
    return Intl.message(
      'No habits to display',
      name: 'PieChartisEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Not enough data to display trends`
  String get TrendCharisEmpty {
    return Intl.message(
      'Not enough data to display trends',
      name: 'TrendCharisEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get Completed {
    return Intl.message('Completed', name: 'Completed', desc: '', args: []);
  }

  /// `Incomplete`
  String get Incomplete {
    return Intl.message('Incomplete', name: 'Incomplete', desc: '', args: []);
  }

  /// `Completed`
  String get TooltipItemCompleted {
    return Intl.message(
      'Completed',
      name: 'TooltipItemCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Go do it now`
  String get TooltipItem {
    return Intl.message(
      'Go do it now',
      name: 'TooltipItem',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get SettingPageTitle {
    return Intl.message(
      'Settings',
      name: 'SettingPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get Appearance {
    return Intl.message('Appearance', name: 'Appearance', desc: '', args: []);
  }

  /// `Change app theme and color`
  String get Changeapptheme {
    return Intl.message(
      'Change app theme and color',
      name: 'Changeapptheme',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get Notifications {
    return Intl.message(
      'Notifications',
      name: 'Notifications',
      desc: '',
      args: [],
    );
  }

  /// `Daily Reminder`
  String get DailyReminder {
    return Intl.message(
      'Daily Reminder',
      name: 'DailyReminder',
      desc: '',
      args: [],
    );
  }

  /// `Set a daily reminder for your habits`
  String get SetDailyReminder {
    return Intl.message(
      'Set a daily reminder for your habits',
      name: 'SetDailyReminder',
      desc: '',
      args: [],
    );
  }

  /// `Backup Data`
  String get BackupData {
    return Intl.message('Backup Data', name: 'BackupData', desc: '', args: []);
  }

  /// `Export your habit data`
  String get Exportyourhabitdata {
    return Intl.message(
      'Export your habit data',
      name: 'Exportyourhabitdata',
      desc: '',
      args: [],
    );
  }

  /// `Restore Data`
  String get RestoreData {
    return Intl.message(
      'Restore Data',
      name: 'RestoreData',
      desc: '',
      args: [],
    );
  }

  /// `Import previously exported data`
  String get Importpreviouslyexporteddata {
    return Intl.message(
      'Import previously exported data',
      name: 'Importpreviouslyexporteddata',
      desc: '',
      args: [],
    );
  }

  /// `Languig`
  String get lan {
    return Intl.message('Languig', name: 'lan', desc: '', args: []);
  }

  /// `Clear All Data`
  String get ClearAllData {
    return Intl.message(
      'Clear All Data',
      name: 'ClearAllData',
      desc: '',
      args: [],
    );
  }

  /// `Delete all habits and settings`
  String get Deleteallhabitsandsettings {
    return Intl.message(
      'Delete all habits and settings',
      name: 'Deleteallhabitsandsettings',
      desc: '',
      args: [],
    );
  }

  /// `Coming Soon`
  String get ComingSoon {
    return Intl.message('Coming Soon', name: 'ComingSoon', desc: '', args: []);
  }

  /// `Restore feature will be available in future updates`
  String get Restorefeaturewillbeavailableinfutureupdates {
    return Intl.message(
      'Restore feature will be available in future updates',
      name: 'Restorefeaturewillbeavailableinfutureupdates',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get About {
    return Intl.message('About', name: 'About', desc: '', args: []);
  }

  /// `This app made by dexter `
  String get Appversionandinformation {
    return Intl.message(
      'This app made by dexter ',
      name: 'Appversionandinformation',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get Cancel {
    return Intl.message('Cancel', name: 'Cancel', desc: '', args: []);
  }

  /// `Add`
  String get Add {
    return Intl.message('Add', name: 'Add', desc: '', args: []);
  }

  /// `The field can't be empty :)`
  String get Thefieldcanybeempty {
    return Intl.message(
      'The field can\'t be empty :)',
      name: 'Thefieldcanybeempty',
      desc: '',
      args: [],
    );
  }

  /// `Add new Habit...`
  String get Addnewhabit {
    return Intl.message(
      'Add new Habit...',
      name: 'Addnewhabit',
      desc: '',
      args: [],
    );
  }

  /// `Edit This Habit`
  String get EditThisHabit {
    return Intl.message(
      'Edit This Habit',
      name: 'EditThisHabit',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get Error {
    return Intl.message('Error', name: 'Error', desc: '', args: []);
  }

  /// `Delete Habit`
  String get DeleteHabit {
    return Intl.message(
      'Delete Habit',
      name: 'DeleteHabit',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this habit?`
  String get areyousureyouwanttothishabit {
    return Intl.message(
      'Are you sure you want to delete this habit?',
      name: 'areyousureyouwanttothishabit',
      desc: '',
      args: [],
    );
  }

  /// `Click here`
  String get defaultHabits1 {
    return Intl.message(
      'Click here',
      name: 'defaultHabits1',
      desc: '',
      args: [],
    );
  }

  /// `<== Swipe left to edit`
  String get defaultHabits2 {
    return Intl.message(
      '<== Swipe left to edit',
      name: 'defaultHabits2',
      desc: '',
      args: [],
    );
  }

  /// `Swipe right to delete ==>`
  String get defaultHabits3 {
    return Intl.message(
      'Swipe right to delete ==>',
      name: 'defaultHabits3',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
