enum UserRole { participant, admin }

enum AttendanceStatus { onTime, late, empty, permission }

enum AccessState { checking, notAccepted, serviceError, expired, allowed }

enum AttendanceStage { checkIn, checkOut, completed }

enum LocationCheckState {
  checking,
  valid,
  outsideArea,
  inaccurate,
  permissionDenied,
  serviceDisabled,
  mockLocation,
  noInternet,
  alreadyRecorded,
}

enum AttendanceType { checkIn, checkOut }

enum PermissionType { sick, personal }

enum AttachmentSource { gallery, camera }

class Participant {
  final String name;
  final String email;
  final String institution;
  final String activity;
  final String supervisor;
  final String startDate;
  final String endDate;
  final String placement;
  final String status;

  const Participant({
    required this.name,
    required this.email,
    required this.institution,
    required this.activity,
    required this.supervisor,
    required this.startDate,
    required this.endDate,
    required this.placement,
    required this.status,
  });
}

class AttendanceRecord {
  final String date;
  final String checkIn;
  final String checkOut;
  final AttendanceStatus status;
  final String note;

  const AttendanceRecord({
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    this.note = '',
  });

  bool get hasCheckIn => checkIn != '-';

  bool get hasCheckOut => checkOut != '-';
}

class AdminParticipant {
  final String name;
  final String activity;
  final String institution;
  final String checkIn;
  final String checkOut;
  final AttendanceStatus status;

  const AdminParticipant({
    required this.name,
    required this.activity,
    required this.institution,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });

  bool get hasCheckedIn => checkIn != '-';

  bool get hasCheckedOut => checkOut != '-';
}

class AttendanceDetail {
  final String participantName;
  final String date;
  final String checkIn;
  final String checkOut;
  final AttendanceStatus status;
  final String location;
  final String locationStatus;
  final String note;

  const AttendanceDetail({
    required this.participantName,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.location,
    required this.locationStatus,
    this.note = '',
  });
}

class PermissionRecord {
  final String id;
  final PermissionType type;
  final String startDate;
  final String endDate;
  final String description;
  final String attachmentName;
  final String attachmentPath;
  final bool hasAttachment;

  const PermissionRecord({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.description,
    this.attachmentName = '',
    this.attachmentPath = '',
    this.hasAttachment = false,
  });
}

class LocationCheckResult {
  final LocationCheckState state;
  final String message;
  final String detail;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final double? distance;

  const LocationCheckResult({
    required this.state,
    required this.message,
    this.detail = '',
    this.latitude,
    this.longitude,
    this.accuracy,
    this.distance,
  });
}

class CorrectionRecord {
  final String id;
  final String participantName;
  final String date;
  final String beforeCheckIn;
  final String afterCheckIn;
  final String beforeCheckOut;
  final String afterCheckOut;
  final String reason;
  final String correctedBy;
  final String correctedAt;

  const CorrectionRecord({
    required this.id,
    required this.participantName,
    required this.date,
    required this.beforeCheckIn,
    required this.afterCheckIn,
    required this.beforeCheckOut,
    required this.afterCheckOut,
    required this.reason,
    required this.correctedBy,
    required this.correctedAt,
  });
}

class AttendanceSummary {
  final int totalParticipants;
  final int checkedIn;
  final int notCheckedIn;
  final int late;
  final int permissionRecorded;

  const AttendanceSummary({
    required this.totalParticipants,
    required this.checkedIn,
    required this.notCheckedIn,
    required this.late,
    required this.permissionRecorded,
  });
}

class AttachmentData {
  final String name;
  final String path;
  final AttachmentSource source;

  const AttachmentData({
    required this.name,
    required this.path,
    required this.source,
  });
}
