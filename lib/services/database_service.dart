import '../models/bus_model.dart';
import '../models/driver_model.dart';
import '../models/organization_model.dart';
import '../models/student_model.dart';
import '../models/payment_model.dart';
import '../models/attendance_model.dart';
import '../repositories/bus_repository.dart';
import '../repositories/driver_repository.dart';
import '../repositories/organization_repository.dart';
import '../repositories/student_repository.dart';

class DatabaseService {
  final OrganizationRepository _orgRepo = OrganizationRepository();
  final StudentRepository _studentRepo = StudentRepository();
  final DriverRepository _driverRepo = DriverRepository();
  final BusRepository _busRepo = BusRepository();

  Future<List<OrganizationModel>> getOrganizations() {
    return _orgRepo.getOrganizations();
  }

  Stream<StudentModel?> getStudent(String orgId, String uid) {
    return _studentRepo.getStudentStream(orgId, uid);
  }

  Future<DriverModel?> getDriverByBus(String orgId, String busId) {
    return _driverRepo.getDriverByBus(orgId, busId);
  }

  Stream<BusModel?> getBusStream(String orgId, String busId) {
    return _busRepo.getBusStream(orgId, busId);
  }

  Future<List<PaymentModel>> getPayments(String orgId, String studentUid) {
    return _studentRepo.getPayments(orgId, studentUid);
  }

  Future<List<AttendanceModel>> getAttendance(String orgId, String studentUid) {
    return _studentRepo.getAttendance(orgId, studentUid);
  }

  Future<void> updateFcmToken(String orgId, String studentUid, String token) {
    return _studentRepo.updateFcmToken(orgId, studentUid, token);
  }
}
