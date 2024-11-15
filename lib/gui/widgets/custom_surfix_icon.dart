import 'package:flutter/material.dart';
import 'package:school_trip_track_driver/utils/size_config.dart';

class CustomSuffixIcon extends StatelessWidget {
  const CustomSuffixIcon({
    Key? key,
    this.svgIcon,
  }) : super(key: key);

  final Icon? svgIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        getProportionateScreenWidth(10),
        getProportionateScreenWidth(10),
        getProportionateScreenWidth(10),
        getProportionateScreenWidth(10),
      ),
      child: IconButton(icon: svgIcon!,
        iconSize: getProportionateScreenWidth(18),
        onPressed: () {  },
      ),
    );
  }
}
