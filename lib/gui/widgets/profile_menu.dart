import 'package:flutter/material.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    this.text,
    this.icon,
    this.press,
    this.backColor,
  }) : super(key: key);

  final String? text;
  final Icon? icon;
  final VoidCallback? press;
  final Color? backColor;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 8, top: 12, bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: backColor ?? AppTheme.lightGrey,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: icon
            ),
            const SizedBox(width: 20),
            Expanded(child: Text(text!, style: AppTheme.menu,)),
            //Icon(Icons.arrow_forward_ios, color: AppTheme.grey_40,),
          ],
        ),
      ),
    );
  }
}
