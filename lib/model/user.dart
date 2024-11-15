
class DbUser{

    int? id, role, statusID, schoolID;
    String? name, email, uid, fcmToken, avatar;
    double? rate, wallet;
    String? address, telNumber;
    String? registrationResponse;
    String? notes;

    DbUser? school;

    DbUser(
        {this.id,
            this.name,
            this.email,
            this.uid,
            this.fcmToken,
            this.role,
            this.statusID,
            this.rate,
            this.wallet,
            this.address,
            this.telNumber,
            this.avatar,
            this.schoolID,
            this.school,
            this.notes,
            this.registrationResponse}
        );

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'name': name,
            'email': email,
            'uid': uid,
            'fcm_token': fcmToken,
            'role_id':role,
            'status_id':statusID,
            'rate':rate,
            'wallet':wallet,
            'address': address,
            'tel_number': telNumber,
            'avatar':avatar,
            'school_id':schoolID,
            'school': school?.toJson(),
            'notes': notes,
            'registration_response': registrationResponse,
        };
    }

    static DbUser fromJson(json) {
        return DbUser(
            id: json['id'],
            name: json['name'],
            email: json['email'],
            uid: json['uid'],
            role: json['role_id'],
            statusID: json['status_id'],
            rate: json['rate']!=null? double.parse(json['rate'].toString()):0.0,
            wallet: json['wallet']!=null? double.parse(json['wallet'].toString()):0.0,
            fcmToken: json['fcm_token'],
            address: json['address'],
            telNumber: json['tel_number'],
            avatar: json['avatar'],
            schoolID: json['school_id'],
            notes: json['notes'],
            school: json['school'] != null ? DbUser.fromJson(json['school']) : null,
            registrationResponse: json['registration_response'],
        );
    }

}
