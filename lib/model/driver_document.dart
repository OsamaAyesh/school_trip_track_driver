import 'dart:convert';
import 'dart:io';

class DriverDocument
{
  int? id;
  String? documentName, documentNumber, documentExpiryDate;
  String? documentLocalFilePath, documentRemoteFilePath;
  
  DriverDocument({this.id, this.documentName, this.documentNumber,
    this.documentExpiryDate, this.documentLocalFilePath, this.documentRemoteFilePath});

  Map<String, dynamic> toJson() {
    File uploadImage = File(documentLocalFilePath!);
    List<int> imageBytes = uploadImage.readAsBytesSync();
    String imageBase64 = base64Encode(imageBytes);
    return {
      'id': id,
      'document_name': documentName,
      'document_number': documentNumber,
      'expiry_date': documentExpiryDate,
      'local_file_path': documentLocalFilePath,
      'remote_file_path': documentRemoteFilePath,
      'document_image': imageBase64,
    };
  }

  static DriverDocument fromJson(json) {
    return DriverDocument(
      id: json['id'],
      documentName: json['document_name'],
      documentNumber: json['document_number'],
      documentExpiryDate: json['expiry_date'],
      documentLocalFilePath: json['local_file_path'],
      documentRemoteFilePath: json['remote_file_path'],
    );
  }
}