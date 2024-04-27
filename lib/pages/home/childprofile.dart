class Child {
  late final String name;
  final DateTime dob;
  final String gender;

  Child({required this.name, required this.dob, required this.gender});

  // Method to convert a map into a Child object
  factory Child.fromMap(Map<String, dynamic> map) {
  return Child(
  name: map['name'],
  dob: DateTime.parse(map['dob']), // Ensure the date is in a consistent format
  gender: map['gender'],
  );
  }

  // Method to convert a Child object into a map
  Map<String, dynamic> toMap() {
  return {
  'name': name,
  'dob': dob.toIso8601String(), // Convert DateTime to ISO 8601 string
  'gender': gender,
  };
  }
  }


int calculateAge(DateTime dob) {
    final now = DateTime.now();
    final age = now.year - dob.year;
    final month1 = now.month;
    final month2 = dob.month;
    if (month1 < month2) {
      return age - 1;
    } else if (month1 == month2) {
      final day1 = now.day;
      final day2 = dob.day;
      if (day1 < day2) {
        return age - 1;
      }
    }
    return age;
  }

