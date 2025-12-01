import 'package:malinaowaterbilling/features/auth/domain/models/app_user.dart';

class UserModel extends AppUser {
  final String address;
  final String contactNumber;
  final String meterId;
  final String status; // "approved pending rejected "
  final bool isAdmin;

  UserModel({
    required String uid,
    required String name,
    required String email,
    this.address = '',
    this.contactNumber = '',
    this.meterId = '',
    this.status = 'active',
    this.isAdmin = false,
  }) : super(uid: uid, name: name, email: email);

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "address": address,
      "contactNumber": contactNumber,
      "meterId": meterId,
      "status": status,
      "isAdmin": isAdmin,
    };
  }

  // Construct from Firestore map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map["uid"] ?? "",
      name: map["name"] ?? "",
      email: map["email"] ?? "",
      address: map["address"] ?? "",
      contactNumber: map["contactNumber"] ?? "",
      meterId: map["meterId"] ?? "",
      status: map["status"] ?? "active",
      isAdmin: map["isAdmin"] ?? false,
    );
  }
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? address,
    String? contactNumber,
    String? meterId,
    String? status,
    bool? isAdmin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      meterId: meterId ?? this.meterId,
      status: status ?? this.status,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
