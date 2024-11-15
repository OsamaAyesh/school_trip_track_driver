
import 'dart:convert';
import 'dart:io';
import 'package:school_trip_track_driver/connection/response/devices_response.dart';
import 'package:school_trip_track_driver/connection/response/users_response.dart';
import 'package:school_trip_track_driver/connection/response/update_bus_location_response.dart';
import 'package:school_trip_track_driver/model/route_details.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:school_trip_track_driver/connection/response/settings_response.dart';
import 'package:school_trip_track_driver/connection/response/notifications_response.dart';
import 'package:school_trip_track_driver/connection/response/auth_response.dart';
import 'package:school_trip_track_driver/connection/response/trips_response.dart';
import 'package:school_trip_track_driver/model/trip.dart';
import 'package:school_trip_track_driver/model/user.dart';

import '../model/driver_data.dart';
import '../utils/config.dart';


class AllApis {
    Future<AuthResponse?> loginViaToken(String token, String deviceName,
        String firebaseToken) async {
        final params = {
            'token': token,
            'device_name': deviceName,
            'fcm_token': firebaseToken
        };

        // check if http or https
        final uri = getFullUrl('api/auth/loginViaToken');

        Response resp = await http.post(
            uri, headers: {HttpHeaders.contentTypeHeader: 'application/json'},
            body: jsonEncode(params))
            .timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);
            if (resp.statusCode == 200) {
                return AuthResponse.fromJson(body);
            } else {
                var error = body["errors"] != null && body["errors"]["authentication"] != null ? body["errors"]["authentication"][0] : "Unexpected error";
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error);
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }
    }

    Future<AuthResponse?> verifyUser(String token, String deviceName) async {

        final uri = getFullUrl('api/auth/verify-user');

        final params = {
            'device_name': deviceName,
        };

        if(Config.localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);
            if (resp.statusCode == 200) {
                return AuthResponse.fromJson(body);
            } else {
                if(body["message"] != null)
                {
                    throw Exception(body["message"]);
                }
                else
                {
                    var error = body["errors"] != null && body["errors"]["authentication"] != null ? body["errors"]["authentication"][0] : "Unexpected error";
                    // If the server did not return a 200 OK response,
                    // then throw an exception.
                    throw Exception(error);
                }
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }
    }

    Future<AuthResponse?> createUser(String name, String token,
        String deviceName, String firebaseToken) async {
        final params = {
            'name': name,
            'token': token,
            'device_name': deviceName,
            'fcm_token': firebaseToken
        };

        final uri = getFullUrl('api/auth/createDriver');

        Response resp = await http.post(
            uri, headers: {HttpHeaders.contentTypeHeader: 'application/json'},
            body: jsonEncode(params))
            .timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try
        {
            var body = jsonDecode(resp.body);
            if (resp.statusCode == 200) {
                return AuthResponse.fromJson(body);
            } else {
                var error = body["errors"] != null && body["errors"]["authentication"] != null ? body["errors"]["authentication"][0] : "Unexpected error";[0];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error);
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }
    }


    Future<AuthResponse> getDriverData(String token) async {
        final uri = getFullUrl('api/drivers/get-driver-info');

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                return AuthResponse.fromJson(body);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }
    }

    Future<String> requestDeleteAccount(String token) async {
        final uri = getFullUrl('api/users/request-delete-driver');

        if(Config.localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(
            Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);

        if (resp.statusCode == 200) {
            // If the server did return a 200 OK response,
            // then parse the JSON.
            return "";
        }
        else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }


    Future<UsersResponse> getStudentsToBePickedUp(String token, int tripID) async {
        final params = {
            'trip_id': tripID.toString(),
        };
        final uri = getFullUrl('api/planned-trips/get-students-to-be-picked-up/$tripID');

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var schools = body;
                // then parse the JSON.
                return UsersResponse.fromJson(schools);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }

    }
    Future<UsersResponse> getAllSchools(String token) async {
        final uri = getFullUrl('api/users/all-schools');

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var schools = body;
                // then parse the JSON.
                return UsersResponse.fromJson(schools);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }

    }

    Future<DevicesResponse> getAllDevices(String token) async {
        final uri = getFullUrl('api/users/devices');

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var devices = body["devices"];
                // then parse the JSON.
                return DevicesResponse.fromJson(devices);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }

    }

    Future<String> deleteDevices(String token, String id,
        String deviceName) async {
        final params = {
            'id': id,
            'device_name': deviceName
        };

        final uri = getFullUrl('api/users/revokeToken', null);

        Response resp = await http.delete(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params)).timeout(
            Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);

        if (resp.statusCode == 200) {
            // If the server did return a 200 OK response,
            // then parse the JSON.
            return "";
        }
        else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    //getSchoolByCode
    Future<DbUser> getSchoolByCode(String token, String? schoolCode) async {
        final uri = getFullUrl('api/users/get-school-by-code/$schoolCode');
        if(Config.localTest) {
            await Future.delayed(const Duration(seconds: 3));
        }
        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var school = body["school"];
                // then parse the JSON.
                return DbUser.fromJson(school);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }

    }


    Future<void> saveDriverData(String token, DriverData driverData, int? schoolId, int submit) async {
        final params = driverData.toJson();
        params["submit"] = submit; //0 - save, 1 - submit
        params["school_id"] = schoolId;
        if(Config.localTest) {
            await Future.delayed(const Duration(seconds: 3));
        }
        // token = token+"11";
        final uri = getFullUrl('api/drivers/save-driver-info');

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode != 200) {
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var body = jsonDecode(resp.body);
                var error = body["errors"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
    }

    Future<TripsResponse> getDriverTrips(String token) async {
        final uri = getFullUrl('api/drivers/get-driver-trips');

        if(Config.localTest)
        {
            await Future.delayed(const Duration(seconds: 2));
        }
        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);

        if (resp.statusCode == 200) {
            // If the server did return a 200 OK response,
            var trips = body["trips"];
            // then parse the JSON.
            return TripsResponse.fromJson(trips);
        }
        else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }


    Future<DbUser> updatePreferredPaymentMethod(
        String? token, int? preferredMethod, String? accountNumber,
        String? routingNumber,
        String? accountHolderName, String? bankName, String? paypalEmail,
        String? instantTransferMobileNo, String? instantTransferMobileNetwork) async {
        final params = {
            'preferred_payment_method': preferredMethod.toString(),
            'account_number': accountNumber.toString(),
            'routing_number': routingNumber.toString(),
            'beneficiary_name': accountHolderName.toString(),
            'beneficiary_address': bankName.toString(),
            'bank_name': bankName.toString(),
            'email': paypalEmail.toString(),
            'phone_number': instantTransferMobileNo.toString(),
            'network': instantTransferMobileNetwork.toString(),
        };
        final uri = getFullUrl('api/drivers/update-preferred-payment-method');

        if(Config.localTest)
            {
                await Future.delayed(const Duration(seconds: 2));
            }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode == 200) {
            // then parse the JSON.
            var body = jsonDecode(resp.body);
            var user = body["user"];
            return DbUser.fromJson(user);
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var body = jsonDecode(resp.body);
            var error = body["errors"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    //getPreferredPaymentMethod
    Future<DbUser> getPreferredPaymentMethod(String? token) async
    {
        final uri = getFullUrl('api/drivers/get-preferred-payment-method');
        if(Config.localTest) {
            await Future.delayed(const Duration(seconds: 3));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                var body = jsonDecode(resp.body);
                var user = body["user"];
                return DbUser.fromJson(user);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    Future<DbUser> updateProfile(String? token, String? address, String? telNumber) async {
        final params = {
            'address': address.toString(),
            'tel_number': telNumber.toString(),
        };
        //token = token+"11";
        final uri = getFullUrl('api/users/updateProfile', null);

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode == 200) {
            // then parse the JSON.
            var body = jsonDecode(resp.body);
            var user = body["user"];
            return DbUser.fromJson(user);
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var body = jsonDecode(resp.body);
            var error = body["errors"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    Future<String> getTerms() async {
        final uri = getFullUrl('api/docs/terms');

        Response resp = await http.get(uri).timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode == 200) {
            // If the server did return a 200 OK response,
            var body = jsonDecode(resp.body);
            var terms = body["terms"];
            // then parse the JSON.
            return terms;
        } else {
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception('Failed to load ResponseInfo ');
        }
    }

    Future<String?> uploadAvatar(String? token, String? avatarLocalFilePath) async {
        final uri = getFullUrl('api/users/upload-avatar');

        File uploadImage = File(avatarLocalFilePath!);
        List<int> imageBytes = uploadImage.readAsBytesSync();
        String avatarBase64 = base64Encode(imageBytes);

        final params = {
            'avatar': avatarBase64
        };

        if(Config.localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode == 200) {
            // then parse the JSON.
            //get avatar_url
            var body = jsonDecode(resp.body);
            var avatarUrl = body["avatar_url"];
            return avatarUrl;
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var body = jsonDecode(resp.body);
            var error = body["errors"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    //Get RouteDetails
    Future<RouteDetails> getRouteDetails(String token, int? id) async {
        final uri = getFullUrl('api/routes/$id');

        if(Config.localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        );
        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                // then parse the JSON.
                return RouteDetails.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    //updateBusLocation
    Future<UpdateBusLocationResponse> updateBusLocation(String token,
        int? tripId, double? lat,
        double? lng, double? speed) async
    {
        final params = {
            'planned_trip_id': tripId.toString(),
            'lat': lat.toString(),
            'lng': lng.toString(),
            'speed': speed.toString(),
        };

        final uri = getFullUrl('api/planned-trips/set-last-position');

        if(Config.localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                // then parse the JSON.
                return UpdateBusLocationResponse.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.
            toString());
        }
    }

    //pickupPassenger
    Future<UpdateBusLocationResponse> pickupPassenger(String token,
        String? ticketNumber, int? tripId,
        double? lat, double? lng, double? speed) async
    {
        final params = {
            'ticket_number': ticketNumber.toString(),
            'planned_trip_id': tripId.toString(),
            'lat': lat.toString(),
            'lng': lng.toString(),
            'speed': speed.toString(),
        };

        final uri = getFullUrl('api/planned-trips/pick-up');

        if (Config.localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                // then parse the JSON.
                return UpdateBusLocationResponse.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch (e) {
            throw Exception(e.toString());
        }
    }

    Future<UpdateBusLocationResponse> dropOffPassengers(String token,
        int? tripId,
        double? lat, double? lng, double? speed) async
    {
        final params = {
            'planned_trip_id': tripId.toString(),
            'lat': lat.toString(),
            'lng': lng.toString(),
            'speed': speed.toString(),
        };

        final uri = getFullUrl('api/planned-trips/drop-off');

        if (Config.localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                // then parse the JSON.
                return UpdateBusLocationResponse.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch (e) {
            throw Exception(e.toString());
        }
    }

    // getTripDetails
    Future<Trip> getPlannedTripDetails(String token, int? id) async {

        final uri = getFullUrl('api/planned-trips/$id');

        if(Config.localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        );
        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var trip = body["trip"];
                // then parse the JSON.
                return Trip.fromJson(trip);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    //start trip
    Future<void> startEndTrip(String token, int? id, int mode) async
    {
        final params = {
            'planned_trip_id': id.toString(),
            'mode': mode.toString(),
        };

        final uri = getFullUrl('api/planned-trips/start-stop');

        if(Config.localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode != 200) {
                if (resp.statusCode == 401 &&
                    resp.reasonPhrase == "Unauthorized") {
                    throw Exception("unauthenticated");
                }
                else {
                    var error = body["message"];
                    // If the server did not return a 200 OK response,
                    // then throw an exception.
                    throw Exception(error.toString());
                }
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    //To be included in the next release

    Future<SettingsResponse> getSettings(String token) async {
        final uri = getFullUrl('api/settings/user', null);

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);

        if (resp.statusCode == 200) {
            // If the server did return a 200 OK response,
            var settings = body["settings"];
            // then parse the JSON.
            return SettingsResponse.fromJson(settings);
        }
        else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    Future<NotificationsResponse> getNotifications(String token) async
    {
        Uri uri = getFullUrl('api/notifications/list-all');

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode == 200) {
            var body = jsonDecode(resp.body);
            // If the server did return a 200 OK response,
            var notifications = body["notifications"];
            // then parse the JSON.
            return NotificationsResponse.fromJson(notifications);
        }
        else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var body = jsonDecode(resp.body);
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }
    Future<String> markNotificationAsSeen(String token, int id) async {
        final params = {
            'id': id.toString(),
        };

        Uri uri = getFullUrl('api/notifications/mark-as-seen');

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);
        if (resp.statusCode == 200) {
            // then parse the JSON.
            return "";
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    Future<String> markNotificationAsSeenDelete(String token, int id,
        int seen) async {
        final params = {
            'id': id.toString(),
        };

        //token = token+"11";
        Uri uri;
        if (seen == 1) {
            uri = getFullUrl('api/notifications/markAsSeen');
        }
        else {
            uri = getFullUrl('api/notifications/markAsDelete');
        }


        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);
        if (resp.statusCode == 200) {
            // then parse the JSON.
            return "";
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    Future<String> markAllNotificationAsSeen(String token) async {
        //token = token+"11";
        Uri uri = getFullUrl('api/notifications/mark-all-as-seen');

        //local test
        if(Config.localTest) {
            await Future.delayed(const Duration(seconds: 2));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },)
            .timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);
        if (resp.statusCode == 200) {
            // then parse the JSON.
            return "";
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    //deleteAllNotifications
    Future<String> deleteAllNotifications(String token) async {
        Uri uri = getFullUrl('api/notifications/delete-all-notifications');

        //local test
        if(Config.localTest) {
            await Future.delayed(const Duration(seconds: 2));
        }

        Response resp = await http.delete(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },)
            .timeout(Duration(seconds: Config.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);
        if (resp.statusCode == 200) {
            // then parse the JSON.
            return "";
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    getFullUrl(String s, [Map<String, String>? params]) {
        Uri uri;
        String webUrl = Config.webUrl;
        String? path;
        //get substring from first / if exists
        if (webUrl.contains("/")) {
            path = "${webUrl.substring(webUrl.indexOf("/"))}/";
            webUrl = webUrl.substring(0, webUrl.indexOf("/"));
        }
        if(path != null) {
            s = path + s;
        }

        if (Config.serverUrl.startsWith("https")) {
            uri = Uri.https(
                webUrl, s, params);
        } else {
            uri = Uri.http(
                webUrl, s, params);
        }
        return uri;
    }
}
