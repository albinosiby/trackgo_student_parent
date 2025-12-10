class StudentModel {
  final String uid;
  final String fullName;
  final String rollNumber;
  final String batch;
  final String? busId;
  final String? busNumber;
  final String parentUid;
  // Extended Profile Details
  final String? profilePhotoUrl;
  final String? address;
  final String? dob;
  final String? busStop;
  final String? email; // Student/User email
  final double feeAmount;
  final double paid;
  final double due;
  final String? paymentType;

  // Details from Profile Screen
  final String parentName;
  final String parentPhone;
  final String parentEmail;

  StudentModel({
    required this.uid,
    required this.fullName,
    required this.rollNumber,
    required this.batch,
    this.busId,
    this.busNumber,
    required this.parentUid,
    this.profilePhotoUrl,
    this.address,
    this.dob,
    this.busStop,
    this.email,
    this.feeAmount = 0.0,
    this.paid = 0.0,
    this.due = 0.0,
    this.paymentType,
    required this.parentName,
    required this.parentPhone,
    required this.parentEmail,
  });

  factory StudentModel.fromMap(Map<String, dynamic> data, String uid) {
    return StudentModel(
      uid: uid,
      fullName: data['full_name'] ?? 'Student Name',
      rollNumber: data['roll_number'] ?? 'N/A',
      batch: data['batch'] ?? 'N/A',
      busId: data['bus_id'],
      busNumber: data['bus_number'],
      parentUid: data['parent_uid'] ?? '',
      profilePhotoUrl: data['profile_photo_url'],
      address: data['address'],
      dob: data['dob'],
      busStop: data['bus_stop'],
      email: data['email'],
      feeAmount: double.tryParse(data['fee_amount']?.toString() ?? '0') ?? 0.0,
      paid: double.tryParse(data['paid']?.toString() ?? '0') ?? 0.0,
      due: double.tryParse(data['due']?.toString() ?? '0') ?? 0.0,
      paymentType: data['payment_type'],
      parentName: data['parent_name'] ?? 'Parent',
      parentPhone: data['parent_phone'] ?? '',
      parentEmail: data['parent_email'] ?? '',
    );
  }
}
