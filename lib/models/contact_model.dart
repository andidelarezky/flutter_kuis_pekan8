class Contact {
  final int? id;
  final String name;
  final String phone;

  Contact({
    this.id,
    required this.name,
    required this.phone,
  });

  // Mengubah objek Contact menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }

  // Mengubah Map menjadi objek Contact
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int,
      name: map['name'] as String,
      phone: map['phone'] as String,
    );
  }
}