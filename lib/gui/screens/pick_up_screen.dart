import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:school_trip_track_driver/gui/screens/students_screen.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:school_trip_track_driver/gui/widgets/app_bar.dart';
import 'package:school_trip_track_driver/services/service_locator.dart';
import 'package:school_trip_track_driver/utils/config.dart';
import 'package:school_trip_track_driver/view_models/this_application_view_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:provider/provider.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';

class PickUpScreen extends StatefulWidget {
  final int? tripID;
  final Position? currentLocation;
  const PickUpScreen(this.tripID, this.currentLocation, {super.key});

  @override
  PickUpScreenState createState() => PickUpScreenState();
}

class PickUpScreenState extends State<PickUpScreen> {
  CameraController? controller;
  ThisApplicationViewModel thisAppModel = serviceLocator<
      ThisApplicationViewModel>();

  List<CameraDescription>? _cameras;
  bool cameraReady = false;
  bool? cameraAccessDenied;

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);

  @override
  void initState() {
    super.initState();

    availableCameras().then((value)
    {
      _cameras = value;
      if(_cameras == null || _cameras!.isEmpty)
      {
        return;
      }
      controller = CameraController(
          _cameras![0],
          enableAudio: false,
          imageFormatGroup: Platform.isAndroid
              ? ImageFormatGroup.nv21 // for Android
              : ImageFormatGroup.bgra8888, // for iOS
          ResolutionPreset.max);
      controller?.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {

        });
      }).catchError((Object e) {
        if (e is CameraException) {
          switch (e.code) {
            case 'CameraAccessDenied':
            // Handle access errors here.
            setState(() {
              cameraAccessDenied = true;
            });
              break;
            default:
            // Handle other errors here.
              break;
          }
        }
      });
    });

  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      _showCameraError('Camera is not initialized.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      _showCameraError('A capture is already pending, do nothing.');
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraError(e.description);
      return null;
    }
  }

  void _showCameraError(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message ?? "",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    thisAppModel.pickupPassengerLoadingState.error = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      //show loading spinner
      return loadingScreen();
    }
    else {
      if (cameraAccessDenied == true) {
        return Scaffold(
          appBar: buildAppBar(context, translation(context)?.scanTicket ?? 'Scan Ticket'),
          body: const Center(
            child: Text(
              'Camera access denied',
              style: TextStyle(color: AppTheme.colorError),
            ),
          ),
        );
      }
    }
    return Consumer<ThisApplicationViewModel>(
        builder: (context, thisAppModel, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (thisAppModel.pickupPassengerLoadingState.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    thisAppModel.pickupPassengerLoadingState
                        .error!,
                  ),
                ),
              );
              thisAppModel.pickupPassengerLoadingState.error = null;
            }

            if (thisAppModel.updateBusLocationResponse!
                .countPassengersToBePickedUp == 0) {
              //wait 100 milliseconds before popping the screen
              Future.delayed(const Duration(milliseconds: 500), () {
                dispose();
                Navigator.pop(context);
              });
            }
            // else if (thisAppModel.pickupPassengerLoadingState.error == null &&
            //     thisAppModel.pickupPassengerLoadingState.loadingFinished()) {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     const SnackBar(
            //       content: Text(
            //         "Student picked up successfully",
            //       ),
            //     ),
            //   );
            // }
          });
          return Scaffold(
            appBar: buildAppBar(context, 'Scan Ticket'),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 20,),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("${thisAppModel.updateBusLocationResponse!
                                  .countPassengersToBePickedUp} ${thisAppModel.updateBusLocationResponse!
                                  .countPassengersToBePickedUp==1?"Student":"Students"}", style: AppTheme.textSecondaryLarge,),
                              const SizedBox(width: 10,),
                              InkWell(
                                child: Container(
                                    width: 25.w,
                                    height: 25.w,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: const Icon(Icons.list_sharp, color: AppTheme.secondary, size: 20,)
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            StudentsScreen(
                                              tripID: widget.tripID,
                                            )),
                                  );
                                },
                              )
                            ],
                          ),
                          SizedBox(height: 50.h,),
                          Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text("Place QR code in the middle of the box", style: AppTheme.textSecondarySmall,),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h,),
                  SizedBox(
                    width: 270.w,
                    height: 270.w,
                    child: CameraPreview(controller!),
                  ),
                  SizedBox(height: 10.h,),
                  Center(
                    child: SizedBox(
                      height: 40.h,
                      width: 130.w,
                      child: ElevatedButton(
                        onPressed: () async {
                          final image = await takePicture();

                          if (image == null) {
                            return;
                          }
                          final inputImage = InputImage.fromFilePath(
                              image.path);
                          final List<
                              Barcode> barcodes = await barcodeScanner
                              .processImage(inputImage);
                          if(Config.localTest) {
                            thisAppModel.pickupPassengerLoadingState
                                .error = null;
                            thisAppModel.pickupPassengerEndpoint(
                                "123456789",
                                widget.tripID,
                                widget.currentLocation?.latitude,
                                widget.currentLocation?.longitude,
                                widget.currentLocation?.speed);
                          }
                          else {
                            //make HapticFeedback and beep
                            HapticFeedback.vibrate();
                            // FlutterRingtonePlayer.playNotification();
                            if (barcodes.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No QR code found',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                              return;
                            }
                            else {
                              thisAppModel.pickupPassengerLoadingState
                                  .error = null;
                              thisAppModel.pickupPassengerEndpoint(
                                  barcodes[0].displayValue, //"123456789",
                                  widget.tripID,
                                  widget.currentLocation?.latitude,
                                  widget.currentLocation?.longitude,
                                  widget.currentLocation?.speed);
                            }
                          }
                        },
                        // style: ElevatedButton.styleFrom(
                        //   backgroundColor: AppTheme.primary,
                        //   shape: StadiumBorder()
                        // ),
                        child: thisAppModel.pickupPassengerLoadingState
                            .inLoading() ?
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ) :
                        Text('Scan (${thisAppModel.updateBusLocationResponse!
                            .countPassengersToBePickedUp})', style: AppTheme.textSecondarySmall,),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h,),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Students do not show up? Report below", style: AppTheme.textSecondarySmall,),
                    ),
                  ),
                  SizedBox(height: 10.h,),
                  ElevatedButton(
                    onPressed: () async {
                      showOkCancelDialog(
                          context,
                          thisAppModel,
                          "No Students",
                          "Are you sure you want to mark these students as not show up?",
                          "Yes",
                          "No",
                              () {
                            Navigator.of(context, rootNavigator: true)
                                .pop();
                            thisAppModel.pickupPassengerLoadingState
                                .error = null;
                            thisAppModel.pickupPassengerEndpoint(
                                null,
                                widget.tripID,
                                widget.currentLocation?.latitude,
                                widget.currentLocation?.longitude,
                                widget.currentLocation?.speed);
                          },
                              () {
                            Navigator.of(context, rootNavigator: true)
                                .pop();
                          }
                      );
                    },
                    // style: ElevatedButton.styleFrom(
                    //     backgroundColor: AppTheme.normalGrey,
                    //     shape: const StadiumBorder()
                    // ),
                    child: Padding(
                      padding: EdgeInsets.only(left:20.w, right: 20.w, top: 15.h, bottom: 15.h),
                      child: Text(
                          "Students do not show up",
                          style: AppTheme.textWhiteMedium
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Consumer<ThisApplicationViewModel>(
  //     builder: (context, thisApplicationViewModel, child) {
  //       return Scaffold(
  //           appBar: buildAppBar(context, 'FAQ'),
  //           body: displayHtml(thisApplicationViewModel)
  //       );
  //     },
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: buildAppBar(context, 'Scan Ticket'),
  //     body: Column(
  //       children: <Widget>[
  //         Expanded(
  //           flex: 5,
  //           child: QRView(
  //             key: qrKey,
  //             onQRViewCreated: _onQRViewCreated,
  //           ),
  //         ),
  //         Expanded(
  //           flex: 1,
  //           child: Center(
  //             child: (result != null)
  //                 ? Text(
  //                 'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
  //                 : Text('Scan a code'),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }
  //
  // void _onQRViewCreated(QRViewController controller) {
  //   this.controller = controller;
  //   controller.scannedDataStream.listen((scanData) {
  //     setState(() {
  //       result = scanData;
  //       print("TESSSSST:"+result!.code!);
  //     });
  //   });
  // }
  //
  // @override
  // void dispose() {
  //   controller?.dispose();
  //   super.dispose();
  // }
}