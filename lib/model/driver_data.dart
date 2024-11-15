import 'driver_document.dart';

class DriverData
{
  String? firstName, lastName, phoneNumber, address, email, licenseNumber;
  String? responseMessage;
  List<dynamic>? documents;

  DriverData(
      {
        this.firstName,
        this.lastName,
        this.phoneNumber,
        this.address,
        this.email,
        this.licenseNumber,
        this.documents,
        this.responseMessage,
      });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'address': address,
      'email': email,
      'license_number': licenseNumber,
      'response': responseMessage,
      'documents': documents?.map((p) => p.toJson()).toList(),
    };
  }

  static DriverData fromJson(json) {
    return DriverData(
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      email: json['email'],
      licenseNumber: json['license_number'],
      responseMessage: json['response'],
      documents: json['documents'] != null ? (json['documents'] as List).map((i) => DriverDocument.fromJson(i)).toList() : null,
    );
  }

}