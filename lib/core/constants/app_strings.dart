import 'package:flutter/material.dart';

import '../../features/settings/data/settings_state.dart';

class AppStrings {
  const AppStrings(this.language);

  final AppLanguage language;

  bool get isHindi => language == AppLanguage.hindi;

  String get calculator => isHindi ? 'कैलकुलेटर' : 'Calculator';
  String get converter => isHindi ? 'कन्वर्टर' : 'Converter';
  String get tools => isHindi ? 'टूल्स' : 'Tools';
  String get history => isHindi ? 'इतिहास' : 'History';
  String get settings => isHindi ? 'सेटिंग्स' : 'Settings';
  String get preview => isHindi ? 'परिणाम' : 'Preview';
  String get scientific => isHindi ? 'वैज्ञानिक' : 'Scientific';
  String get standard => isHindi ? 'मानक' : 'Standard';
  String get noHistory => isHindi ? 'अभी कोई इतिहास नहीं' : 'No history yet';
  String get searchHistory => isHindi ? 'इतिहास खोजें' : 'Search history';
  String get clearAll => isHindi ? 'सब हटाएँ' : 'Clear all';
  String get copied => isHindi ? 'कॉपी किया गया' : 'Copied to clipboard';
  String get deg => 'DEG';
  String get rad => 'RAD';
  String get memory => isHindi ? 'मेमोरी' : 'Memory';
  String get appearance => isHindi ? 'रूप' : 'Appearance';
  String get accentColor => isHindi ? 'एसेंट रंग' : 'Accent color';
  String get haptics => isHindi ? 'हैप्टिक फीडबैक' : 'Haptic feedback';
  String get sound => isHindi ? 'ध्वनि' : 'Sound effects';
  String get precision => isHindi ? 'दशमलव सटीकता' : 'Decimal precision';
  String get numberFormat => isHindi ? 'संख्या प्रारूप' : 'Number format';
  String get languageLabel => isHindi ? 'भाषा' : 'Language';
  String get indian => isHindi ? 'भारतीय' : 'Indian';
  String get international => isHindi ? 'अंतरराष्ट्रीय' : 'International';
  String get english => 'English';
  String get hindi => 'हिन्दी';
  String get system => isHindi ? 'सिस्टम' : 'System';
  String get light => isHindi ? 'लाइट' : 'Light';
  String get dark => isHindi ? 'डार्क' : 'Dark';
  String get amoled => 'AMOLED';
  String get from => isHindi ? 'से' : 'From';
  String get to => isHindi ? 'तक' : 'To';
  String get swap => isHindi ? 'बदलें' : 'Swap';
  String get enterValue => isHindi ? 'मान दर्ज करें' : 'Enter value';
  String get result => isHindi ? 'परिणाम' : 'Result';
  String get delete => isHindi ? 'हटाएँ' : 'Delete';
}
