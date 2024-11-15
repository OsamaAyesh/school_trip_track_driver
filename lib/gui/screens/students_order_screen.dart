import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/trip.dart';
import '../../services/service_locator.dart';
import '../../utils/app_theme.dart';
import '../../utils/config.dart';
import '../../view_models/this_application_view_model.dart';
import '../languages/language_constants.dart';
import '../widgets/app_bar.dart';

class StudentsOrderScreen extends StatefulWidget {
  final Trip? trip;
  final bool? isMorning;
  const StudentsOrderScreen({super.key, this.trip, this.isMorning});

  @override
  StudentsOrderScreenState createState() => StudentsOrderScreenState();
}

class StudentsOrderScreenState extends State<StudentsOrderScreen> {

  List? plannedTripDetail;
  bool? isAutomatic;
  ThisApplicationViewModel thisApplicationModel = serviceLocator<ThisApplicationViewModel>();

  @override
  void initState() {
    double? lat, lng;
    plannedTripDetail = [];
    widget.trip?.plannedTripDetail?.forEach((element) {
      element.distanceFromStart = null;
      plannedTripDetail?.add(element);
    });
    isAutomatic = widget.trip?.autoOrder;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      thisApplicationModel.getCurrentLocation().then((value) {
        setState(() {
          lat = value.latitude;
          lng = value.longitude;
          //update distanceFromStart for each stop
          for (var i = 0; i < plannedTripDetail!.length; i++) {
            plannedTripDetail?[i].distanceFromStart =
                thisApplicationModel.calculateDistance(
                    lat!, lng!,
                    double.parse(plannedTripDetail?[i].stop.lat ?? '0'),
                    double.parse(plannedTripDetail?[i].stop.lng ?? '0')) / 1000;
          }
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, translation(context)?.orderStudents ??  'Order Students'),
      body: Center(
        child: Column(
          //switch to allow automatic sorting of students or manual sorting
          children: [
            SizedBox(height: 20.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info, color: AppTheme.primary,),
                SizedBox(width: 10.w,),
                Text(translation(context)?.orderStudentsMessage ??  'You can order students manually or automatically', style: AppTheme.textSecondarySmall, textAlign: TextAlign.center,)
              ],
            ),
            SizedBox(height: 20.h,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 8.w,),
                        Text(translation(context)?.manual ??  'Manual', style: AppTheme.textSecondaryMedium,),
                        Switch(
                          value: isAutomatic ?? false,
                          onChanged: (value) {
                            setState(() {
                              //switch to allow automatic sorting of students or manual sorting
                              isAutomatic = value;
                            });
                          },
                          activeTrackColor: AppTheme.primary,
                          activeColor: AppTheme.secondary,
                        ),
                        Text(translation(context)?.automatic ??  'Automatic', style: AppTheme.textSecondaryMedium,),
                      ],
                    ),
                    SizedBox(height: 5.h,),
                    isAutomatic == true ?
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(translation(context)?.automaticOrderMessage ??  'Students will be ordered automatically', style: AppTheme.textPrimarySmall,),
                    ) :
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(translation(context)?.manualOrderMessage ??  'You can order students manually by dragging and dropping them below', style: AppTheme.textPrimarySmall,),
                    ),
                    SizedBox(height: 10.h,),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h,),
            widget.isMorning == false && isAutomatic == true ?
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(translation(context)?.lastStop ??  'Last Stop', style: AppTheme.textSecondaryMedium,),
                      SizedBox(height: 5.h,),
                      Text(plannedTripDetail?.last.stop.name?? '', style: AppTheme.textGreySmall,),
                      Text(plannedTripDetail?.last.stop.address ?? '', style: AppTheme.textGreySmall,),
                    ],
                  ),
                  //edit icon
                  IconButton(
                    icon: Container(
                      height: 30.h,
                      width: 30.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.secondary,
                      ),
                        child: const Icon(Icons.edit, color: Colors.white)
                    ),
                    onPressed: () {
                      //show bottom sheet to edit last stop
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: 300.h,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(translation(context)?.chooseLastStop ??  'Choose Last Stop', style: AppTheme.textSecondaryMedium,),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: AppTheme.primary,),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                //list of stops
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: plannedTripDetail!.length-1,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Text(plannedTripDetail?[index+1].stop.name ?? ''),
                                        subtitle: Text(plannedTripDetail?[index+1].stop.address ?? ''),
                                        onTap: () {
                                          //set last stop
                                          setState(() {
                                            //switch last stop with the selected stop
                                            var temp = plannedTripDetail?.last;
                                            plannedTripDetail?.last = plannedTripDetail?[index+1];
                                            plannedTripDetail?[index+1] = temp;
                                          });
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ): const SizedBox(),
            isAutomatic == null || isAutomatic == false ?
            Expanded(
              child: ReorderableListView.builder(
                itemCount: plannedTripDetail!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    key: Key('$index'),
                    title: Text(plannedTripDetail?[index].stop.name ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5.h,),
                        Text(plannedTripDetail?[index].stop.address ?? ''),
                        SizedBox(height: 5.h,),
                        //distance
                        plannedTripDetail?[index].distanceFromStart != null ?
                        Text('${plannedTripDetail?[index].distanceFromStart.toStringAsFixed(2)} km away', style: AppTheme.textGreySmall,) : const SizedBox(),
                      ],
                    ),
                    trailing: const Icon(Icons.drag_handle),
                  );
                },
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = plannedTripDetail?.removeAt(oldIndex);
                    plannedTripDetail?.insert(newIndex, item);
                  });
                },
              ),
            ): const SizedBox(),
            SizedBox(height: 20.h,),
          ],
        ),
      ),
      //floating action button to save the order
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.trip?.plannedTripDetail = plannedTripDetail;
          widget.trip?.autoOrder = isAutomatic;
          //save the order
          Navigator.pop(context);
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.save, color: Colors.white,),
      ),
    );
  }
}