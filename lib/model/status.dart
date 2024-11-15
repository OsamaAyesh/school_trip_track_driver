
class Status{

    int id;
    String name;

    Status(
        {required this.id,
            required this.name}
        );

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'name': name,
        };
    }

    static Status fromJson(json) {
        return Status(
            id: json['id'],
            name: json['name'],
        );
    }

}
