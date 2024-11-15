
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_trip_track_driver/gui/widgets/app_bar.dart';
import 'package:school_trip_track_driver/utils/size_config.dart';
import 'package:school_trip_track_driver/utils/app_theme.dart';
import 'package:school_trip_track_driver/view_models/this_application_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../model/driver_document.dart';
import '../languages/language_constants.dart';

class AddEditDocumentScreen extends StatefulWidget {
  final DriverDocument? document;
  final int? documentIndex;
  final ThisApplicationViewModel thisAppModel;
  const AddEditDocumentScreen(this.thisAppModel, {Key? key, this.document, this.documentIndex}) : super(key: key);

  @override
  AddEditDocumentScreenState createState() => AddEditDocumentScreenState();
}

class AddEditDocumentScreenState extends State<AddEditDocumentScreen> {

  final ImagePicker _picker = ImagePicker();

  //key
  final _formKey = GlobalKey<FormState>();

  //controllers
  final TextEditingController _documentNameController =
      TextEditingController();
  final TextEditingController _documentNumberController =
      TextEditingController();
  final TextEditingController _documentExpiryDateController =
      TextEditingController();

  String? documentFileName;

  BuildContext? currentContext;

  @override
  void initState() {
    if (widget.document != null) {
      _documentNameController.text = widget.document!.documentName!;
      _documentNumberController.text = widget.document!.documentNumber!;
      _documentExpiryDateController.text = widget.document!.documentExpiryDate!;
      documentFileName = widget.document!.documentLocalFilePath;
    }
    super.initState();
  }

  @override
  Widget build(context) {
    currentContext = context;
    // form with driver document data and image upload
    return Scaffold(
      appBar: buildAppBar(context, widget.document == null ? (translation(context)?.addDocument ?? 'Add document') : (translation(context)?.editDocument ?? 'Edit document')),
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildDocumentNameField(context),
                    const SizedBox(height: 20),
                    buildDocumentNumberField(context),
                    const SizedBox(height: 20),
                    buildDocumentExpiryDateField(),
                    const SizedBox(height: 20),
                    buildDocumentImageField(),
                    const SizedBox(height: 20),
                    buildSubmitButton(),
                    const SizedBox(height: 20),
                    //delete button
                    if (widget.document != null)
                      buildDeleteButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildDocumentNameField(BuildContext context) {
    return TextFormField(
      controller: _documentNameController,
      decoration: InputDecoration(
        labelText: translation(context)?.documentName ?? 'Document name',
        labelStyle: AppTheme.textSecondaryMedium,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Icon(Icons.description, color: AppTheme.primary),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return translation(context)?.documentNameIsRequired ?? 'Document name is required';
        }
        return null;
      },
    );
  }

  buildDocumentNumberField(BuildContext context) {
    return TextFormField(
      controller: _documentNumberController,
      decoration: InputDecoration(
        labelText: translation(context)?.documentNumber ?? 'Document number',
        labelStyle: AppTheme.textSecondaryMedium,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Icon(Icons.confirmation_num_outlined, color: AppTheme.primary,),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Document number is required';
        }
        return null;
      },
    );
  }

  buildDocumentExpiryDateField() {
    //text field with date picker

    return TextFormField(
      controller: _documentExpiryDateController,
      decoration: InputDecoration(
        labelText: 'Document expiry date',
        labelStyle: AppTheme.textSecondaryMedium,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Icon(Icons.calendar_today, color: AppTheme.primary),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Document expiry date is required';
        }
        return null;
      },
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: currentContext!,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          _documentExpiryDateController.text =
              pickedDate.toString().substring(0, 10);
        }
      },
    );
  }

  buildDocumentImageField() {
    //image upload
    return Column(
      children: [
        Text(
          translation(currentContext!)?.documentImage ?? 'Document image',
          style: TextStyle(
            fontSize: getProportionateScreenWidth(16),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          child: Container(
            height: getProportionateScreenHeight(200),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.veryLightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
            documentFileName != null && checkFileExist(documentFileName!) ?
            Image.file(File(documentFileName!)) :
            Center(
              child: Icon(
                Icons.image,
                size: getProportionateScreenWidth(50),
                color: AppTheme.normalGrey,
              ),
            ),
          ),
          onTap: () async {
            //show bottom sheet with options to choose image from gallery or camera
            showModalBottomSheet(
              context: currentContext!,
              builder: (context) {
                return SizedBox(
                  height: getProportionateScreenHeight(150),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: Text(translation(context)?.camera ?? 'Camera'),
                        onTap: () async {
                          Navigator.pop(context);
                          pickDocumentImage(ImageSource.camera);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: Text(translation(context)?.gallery ?? 'Gallery'),
                        onTap: () async {
                          Navigator.pop(context);
                          pickDocumentImage(ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 40.h,
      child: ElevatedButton(
        // style: ElevatedButton.styleFrom(
        //   backgroundColor: AppTheme.primary,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(5),
        //   ),
        // ),
        onPressed:
        (documentFileName == null) ? null :
            () async {
          if (_formKey.currentState!.validate()) {
            //save document to database
            DriverDocument driverDocument = DriverDocument(
              documentName: _documentNameController.text,
              documentNumber: _documentNumberController.text,
              documentExpiryDate: _documentExpiryDateController.text,
              documentLocalFilePath: documentFileName,
            );
            widget.thisAppModel.saveEditDriverDocument(driverDocument, widget.documentIndex);
            Navigator.pop(currentContext!);
          }
        },
        child: Text(
          translation(currentContext!)?.save ?? 'Save',
          style: AppTheme.textSecondaryMedium,
        ),
      ),
    );
  }

  Future<void> pickDocumentImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    //copy image to app directory
    String cow = await createFolder('driver_documents');
    File file = File(pickedFile!.path);
    String fileName = basename(file.path);
    File newImage = await file.copy('$cow/$fileName');

    setState(() {
      if (kDebugMode) {
        print(newImage.path);
      }
      documentFileName = newImage.path;
    });
  }

  Future<String> createFolder(String cow) async {
    final dir = Directory('${(Platform.isAndroid
        ? await getExternalStorageDirectory() //FOR ANDROID
        : await getApplicationSupportDirectory() //FOR IOS
    )!
        .path}/$cow');
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if ((await dir.exists())) {
      return dir.path;
    } else {
      dir.create();
      return dir.path;
    }
  }

  buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 40.h,
      child: ElevatedButton(
        // style: ElevatedButton.styleFrom(
        //   backgroundColor: AppTheme.normalGrey,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(5),
        //   ),
        // ),
        onPressed: () async {
          // are you sure dialog
          showDialog(
            context: currentContext!,
            builder: (context) {
              return AlertDialog(
                title: const Text('Are you sure?'),
                content: const Text('Do you want to delete this document?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      //delete document from database
                      widget.thisAppModel.deleteDriverDocument(widget.documentIndex);
                      Navigator.pop(currentContext!);
                    },
                    child: const Text('Yes'),
                  ),
                ],
              );
            },
          );
        },
        child: Text(
          'Delete',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  bool checkFileExist(String s) {
    //check if the image file exists
    File file = File(s);
    return file.existsSync();
    //    Image.file(File(s))
  }
}
