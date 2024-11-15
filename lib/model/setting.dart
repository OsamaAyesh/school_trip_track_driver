
class Setting {
  String? currencyCode;
  bool? showAds;
  bool? simpleMode;
  bool? hideSchools;

  Setting({
    this.currencyCode,
    this.showAds,
    this.simpleMode,
    this.hideSchools,
  });

  Map<String, dynamic> toJson() {
    return {
      'currency_code': currencyCode,
      'allow_ads_in_driver_app': showAds,
      'simple_mode': simpleMode,
      'hide_schools': hideSchools,
    };
  }

  static Setting fromJson(json) {
    return Setting(
      currencyCode: json['currency_code'],
      showAds: json['allow_ads_in_driver_app'] != null
          ? (json['allow_ads_in_driver_app'] == 1 ? true : false)
          : false,
      simpleMode: json['simple_mode'] != null ? (json['simple_mode'] == 1
          ? true
          : false) : false,
      hideSchools: json['hide_schools'] != null ? (json['hide_schools'] == 1
          ? true
          : false) : false,
    );
  }

}
