import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_trip_track_driver/gui/screens/schools_screen.dart';
import 'package:school_trip_track_driver/model/user.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:im_stepper/stepper.dart';
import 'package:provider/provider.dart';

import '../../services/service_locator.dart';
import '../../view_models/this_application_view_model.dart';
import '../languages/language_constants.dart';
import '../widgets/animated_app_bar.dart';
import '../widgets/form_error.dart';
import 'add_edit_document_screen.dart';

class DriverInformationEntryScreen extends StatefulWidget {
  const DriverInformationEntryScreen({super.key});

  @override
  DriverInformationEntryScreenState createState() => DriverInformationEntryScreenState();
}

class DriverInformationEntryScreenState extends State<DriverInformationEntryScreen> {

  ThisApplicationViewModel thisApplicationViewModel =  serviceLocator<ThisApplicationViewModel>();
  int activeStep = 0;
  int upperBound = 1;
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  TextEditingController? _firstNameController,
      _lastNameController, _emailController,
      _phoneNumberController, _addressController, _licenseController, _schoolController, _schoolCodeController;

  List<String> errors = [];

  String? responseMessage;

  @override
  void initState() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
    _licenseController = TextEditingController();
    _schoolController = TextEditingController();
    _schoolCodeController = TextEditingController();

    loadDriverDataToGui(thisApplicationViewModel);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThisApplicationViewModel>(
        builder: (context, thisAppModel, child) {
          if(thisAppModel.saveDriverDataLoadingState.loadError == 1) {
            errors.clear();
            if(thisAppModel.saveDriverDataLoadingState.error != null) {
              errors.add(
                  thisAppModel.saveDriverDataLoadingState.error!);
            }
          }
          if(thisAppModel.settings?.hideSchools == true) {
            if (thisAppModel.getSchoolByCodeLoadingState.loadingFinished()) {
              if (thisAppModel.getSchoolByCodeLoadingState.error != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showErrorToast(
                      context, thisAppModel.getSchoolByCodeLoadingState.error!);
                  thisAppModel.getSchoolByCodeLoadingState.error = null;
                  _schoolController!.text = "";
                });
              }
              else {
                if (thisAppModel.currentUser?.school != null) {
                  _schoolController!.text =
                      thisAppModel.currentUser?.school?.name ?? "";
                }
                else {
                  _schoolController!.text = "";
                }
              }
            }
          }
          return Scaffold(
            appBar: AnimatedAppBar(
              translation(context)?.driverInformation ?? 'Driver Information',
              false,
              addPadding: false,
            ),
            floatingActionButton: activeStep == upperBound ?
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: FloatingActionButton(
                onPressed: () {
                  //navigate to AddDocumentScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddEditDocumentScreen(thisAppModel)),
                  );
                },
                backgroundColor: AppTheme.secondary,
                child: const Icon(Icons.add),
              ),
            ) : null,
            body: Column(
              children: [
                NumberStepper(
                  numbers: const [
                    1,
                    2,
                  ],
                  numberStyle: const TextStyle(
                    color: AppTheme.secondary,
                  ),
                  // backgroundColor: AppTheme.primary,
                  enableNextPreviousButtons: false,
                  activeStepBorderWidth: 2,
                  activeStepBorderColor: AppTheme.primary,
                  activeStep: activeStep,

                  // This ensures step-tapping updates the activeStep.
                  onStepReached: (index) {
                    setState(() {
                      activeStep = index;
                    });
                  },
                ),
                header(),
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: wizardBody(thisAppModel),
                    )
                ),
                errors.isNotEmpty ? FormError(errors: errors) : Container(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      activeStep != 0 ?
                      previousButton(): saveButton(thisAppModel),
                      activeStep == 0 && responseMessage != null && responseMessage!.isNotEmpty ?
                      showMessageButton(responseMessage!) : Container(),
                      nextButton(thisAppModel),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
    );
  }


  /// Returns the next button.
  Widget nextButton(ThisApplicationViewModel thisAppModel) {
    return ElevatedButton(
      onPressed: () {
        // Increment activeStep, when the next button is tapped. However, check for upper bound.
        if (activeStep < upperBound) {
          setState(() {
            errors.clear();
          });
          if (_formKeys[activeStep].currentState == null ||
              _formKeys[activeStep].currentState!.validate()) {
            updateDriverData(thisAppModel);
            setState(() {
              activeStep++;
            });
          }
        }
        else if (activeStep == upperBound) {
          updateDriverData(thisAppModel);
          //call saveDriverDataEndpoint
          thisAppModel.saveDriverDataEndpoint(1);
        }
      },
      // style: ElevatedButton.styleFrom(
      //   backgroundColor: AppTheme.primary,
      //   alignment: AlignmentDirectional.centerEnd,
      // ),
      child: activeStep != upperBound ?
      Align(
        alignment: Alignment.center,
        child: Row(
          children: [
            Text(translation(context)?.next ?? 'Next',
                style: AppTheme.textSecondarySmall),
            Icon(Icons.arrow_forward, color: AppTheme.secondary,),
          ],
        ),
      ) :
      (thisAppModel.saveDriverDataLoadingState.inLoading() ?
      const CircularProgressIndicator(
        color: Colors.white,
      ) :
      Align(
        alignment: Alignment.center,
        child: Row(
          children: [
            Text(translation(context)?.submit ?? 'Submit',
                style: AppTheme.textSecondarySmall),
            Icon(Icons.arrow_forward, color: AppTheme.secondary,),
          ],
        ),
      ))
    );
  }

  /// Returns the save and exit button.
  Widget saveButton(ThisApplicationViewModel thisAppModel) {
    return activeStep < upperBound ? ElevatedButton(
      // style: ElevatedButton.styleFrom(
      //   backgroundColor: AppTheme.primary,
      // ),
      onPressed: () {
        setState(() {
          errors.clear();
        });
        if (_formKeys[activeStep].currentState == null || _formKeys[activeStep].currentState!.validate()) {
          // Increment activeStep, when the next button is tapped. However, check for upper bound.
          if (activeStep < upperBound) {
            updateDriverData(thisAppModel);
            //call saveDriverDataEndpoint
            thisAppModel.saveDriverDataEndpoint(0);
          }
        }
      },
      child: thisAppModel.saveDriverDataLoadingState.inLoading() ?
      const CircularProgressIndicator(
        color: Colors.white,
      ) :
      Center(child: Text(translation(context)?.save ?? 'Save',
          style: AppTheme.textSecondarySmall)),
    ) : Container();
  }

  /// Returns the previous button.
  Widget previousButton() {
    return activeStep == 0 ?
    Container() :
    ElevatedButton(
      // style: ElevatedButton.styleFrom(
      //   backgroundColor: AppTheme.primary,
      // ),
      onPressed: () {
        // Decrement activeStep, when the previous button is tapped. However, check for lower bound i.e., must be greater than 0.
        if (activeStep > 0) {
          setState(() {
            activeStep--;
          });
        }
      },
      child: Center(child: Text(translation(context)?.previous ?? 'Previous',
          style: AppTheme.textSecondarySmall)),
    );
  }

  Widget wizardBody(ThisApplicationViewModel thisAppModel) {
    switch (activeStep) {
      case 0:
        return driverInformation(thisAppModel);

      case 1:
        return legalDocuments(thisAppModel);
    }
    return Container();
  }

  /// Returns the header wrapping the header text.
  Widget header() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              headerText(),
              style: AppTheme.textSecondaryMedium,
            ),
          ),
        ],
      ),
    );
  }

  // Returns the header text based on the activeStep.
  String headerText() {
    switch (activeStep) {
      case 0:
        return translation(context)?.basicInformation ?? 'Basic information';
      case 1:
        return translation(context)?.legalDocuments ?? 'Legal documents';

    }
    return '';
  }

  Widget driverInformation(ThisApplicationViewModel thisAppModel) {
    // contains name, address, phone number, email, and password
    return SingleChildScrollView(
      child: Form(
        key: _formKeys[activeStep],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: translation(context)?.firstName ?? 'First Name',
                  ),
                  validator: (value) {
                    return validateText(value!, "first name");
                  }
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: translation(context)?.lastName ?? 'Last Name',
                  ),
                  validator: (value) {
                    return validateText(value!, "last name");
                  }
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: translation(context)?.address ?? 'Address',
                  ),
                  validator: (value) {
                    return validateText(value!, "address");
                  }
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: translation(context)?.email ?? 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    //validate email
                    if (value == null || value.isEmpty) {
                      return translation(context)?.pleaseEnterYourEmail ??
                          'Please enter email';
                    }
                    if (!value.contains('@') || !value.contains('.') ||
                        value.length < 5) {
                      return translation(context)?.pleaseEnterValidEmail ??
                          'Please enter a valid email';
                    }
                    return null;
                  }
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: translation(context)?.phoneNumber ?? 'Phone Number',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  //validate phone number
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.length <= 5 || int.tryParse(value) == null) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _licenseController,
                  decoration: InputDecoration(
                    labelText: translation(context)?.driverLicense ?? 'Driver\'s License Number',
                  ),
                  validator: (value) {
                    return validateText(value!, "driver's license number");
                  }
              ),
            ),
            // school name
            thisAppModel.getSchoolByCodeLoadingState
                .inLoading() ?
            const CircularProgressIndicator():
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    controller: _schoolController,
                    decoration: InputDecoration(
                      labelText: translation(context)?.school ?? 'School',
                    ),
                    readOnly: true,
                    onTap: () async {
                      if (thisAppModel.settings?.hideSchools == false) {
                        // go to schools screen
                        final DbUser? res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SchoolsScreen(schoolID: thisAppModel.currentUser
                                    ?.schoolID),
                          ),
                        );
                        if (res != null) {
                          //set schoolID
                          thisAppModel.currentUser?.schoolID = res.id;
                          //set school name
                          _schoolController!.text = res.name ?? "";
                        }
                      }
                      else {
                        showSchoolCodeBottomSheet(thisAppModel);
                      }
                    },
                    validator: (value) {
                      return validateText(value!, "school name");
                    }
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget legalDocuments(ThisApplicationViewModel thisAppModel) {
    // table that contains the legal documents
    return Padding(
      padding: const EdgeInsets.only(bottom: 64.0),
      child: ListView.builder(
          itemCount: thisAppModel.driverData.documents?.length ?? 0,
          itemBuilder: (context, index) {
            return InkWell(
              child: Card(
                  child: ListTile(
                    title: Text(
                        thisAppModel.driverData.documents?[index].documentName ??
                            ""),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(thisAppModel.driverData.documents?[index]
                            .documentNumber ?? ""),
                        Text(thisAppModel.driverData.documents?[index]
                            .documentExpiryDate ?? ""),
                      ],
                    ),
                  ),
              ),
              onTap: () {
                //open AddEditDocumentScreen with the document data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditDocumentScreen(
                      thisAppModel,
                      document: thisAppModel.driverData.documents?[index],
                      documentIndex: index,
                    ),
                  ),
                );
              },
            );
          }
      ),
    );
  }

  Widget finalizeAndSubmit() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Vehicle Inspection',
          ),
        ),
      ],
    );
  }

  String? validateText(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return translation(context)?.fieldIsRequired ?? 'Field is required';
    }
    return null;
  }

  void updateDriverData(ThisApplicationViewModel thisAppModel) {
    thisAppModel.driverData.firstName = _firstNameController!.text;
    thisAppModel.driverData.lastName = _lastNameController!.text;
    thisAppModel.driverData.email = _emailController!.text;
    thisAppModel.driverData.phoneNumber = _phoneNumberController!.text;
    thisAppModel.driverData.licenseNumber = _licenseController!.text;
    thisAppModel.driverData.address = _addressController!.text;
  }

  void loadDriverDataToGui(ThisApplicationViewModel thisAppModel) {
    _firstNameController!.text = thisAppModel.driverData.firstName ?? "";
    _lastNameController!.text = thisAppModel.driverData.lastName ?? "";
    _emailController!.text = thisAppModel.driverData.email ?? "";
    _phoneNumberController!.text = thisAppModel.driverData.phoneNumber ?? "";
    _addressController!.text = thisAppModel.driverData.address ?? "";
    _licenseController!.text = thisAppModel.driverData.licenseNumber ?? "";
    _schoolController!.text = thisAppModel.currentUser?.school?.name ?? "";
    responseMessage = thisAppModel.currentUser?.registrationResponse ?? "";
  }

  showMessageButton(String s) {
    //button when clicked show message s
    return ElevatedButton(
      onPressed: () {
        //show dialog with message s
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Response"),
              content: Text(s),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
      // style: ElevatedButton.styleFrom(
      //   backgroundColor: Colors.red,
      //   alignment: Alignment.center,
      // ),
      child: const Align(
        alignment: Alignment.center,
        child: Row(
          children: [
            Text('Response'),
          ],
        ),
      ),
    );
  }

  void showSchoolCodeBottomSheet(ThisApplicationViewModel thisAppModel) {
    //show a bottom sheet to enter a school code
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom+20, left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _schoolCodeController,
                decoration: const InputDecoration(
                  labelText: 'School Code',
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  //apply promo code
                  //(String? promoCode, int? plannedTripID, double? price, BuildContext context)
                  if(_schoolCodeController!.text.isNotEmpty) {
                    thisAppModel.getSchoolByCodeEndpoint(
                        _schoolCodeController?.text);
                    //dismiss the bottom sheet
                    Navigator.of(context).pop();
                  }
                },
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: AppTheme.secondary,
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                // ),
                child: Text(
                  translation(context)?.add ?? 'Add',
                  style: AppTheme.textWhiteMedium,
                ),
              ),
            ],
          ),
        );
      },
      isScrollControlled: true,
      showDragHandle: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
      ),
    );
  }

  void showErrorToast(BuildContext context, String s) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(s),
      duration: const Duration(seconds: 3),
    ));
  }
}