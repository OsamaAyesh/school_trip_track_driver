class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;

  Language(this.id, this.flag, this.name, this.languageCode);

  static List<Language> languageList() {
    return <Language>[
      Language(1, "🇺🇸", "English", "en"),
      Language(2, "🇫🇷", "Français", "fr"),
      //german
      Language(3, "🇩🇪", "Deutsche", "de"),
      // spanish
      Language(4, "🇪🇸", "Español", "es"),
      // // italian
      // Language(5, "🇮🇹", "Italiano", "it"),
      // // portuguese
      Language(5, "🇵🇹", "Português", "pt"),
      Language(6, "🇸🇦", "اَلْعَرَبِيَّةُ", "ar"),
      // Language(7, "🇮🇳", "हिंदी", "hi")
    ];
  }
}
