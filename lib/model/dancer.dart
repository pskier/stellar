class Dancer {
  final String id;
  final String firstName;
  final String lastName;
  final int age;
  final String city;
  final String hour;
  final String additionalInfo;

  Dancer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.city,
    required this.hour,
    required this.additionalInfo,
  });

  factory Dancer.fromMap(String id, Map<String, dynamic> data) {
    return Dancer(
      id: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      age: data['age'] ?? 0,
      city: data['city'] ?? '',
      hour: data['hour'] ?? '',
      additionalInfo: data['additionalInfo'] ?? '',
    );
  }
}
