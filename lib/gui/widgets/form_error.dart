
import 'package:flutter/material.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';

class FormError extends StatelessWidget {
  const FormError({
    Key? key,
    this.errors,
  }) : super(key: key);

  final List<String?>? errors;

  @override
  Widget build(BuildContext context) {
    return Column(

      children: List.generate(
          errors!.length, (index) =>
          formErrorText(context, error: errors?[index])),
    );
  }

  Widget formErrorText(BuildContext context, {String? error}) {
    double cWidth = MediaQuery
        .of(context)
        .size
        .width * 0.7;
    double iconWidth = MediaQuery
        .of(context)
        .size
        .width * 0.10;
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: error != null ?
      Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.error_outline,
            ),
            iconSize: iconWidth,
            onPressed: () {  },
          ),
          SizedBox(
            width: cWidth,
            child: Text(error,
              style: const TextStyle(
                color: AppTheme.colorError,
              ),
            ),
          ),
        ],
      ):Container(),
    );
  }
}
