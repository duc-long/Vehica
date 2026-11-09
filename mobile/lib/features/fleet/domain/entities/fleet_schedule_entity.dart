class VehicleScheduleSlot {
  final String id;
  final String bookingCode;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String customerName;

  const VehicleScheduleSlot({
    required this.id,
    required this.bookingCode,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.customerName,
  });

  factory VehicleScheduleSlot.fromJson(Map<String, dynamic> json) {
    return VehicleScheduleSlot(
      id: json['id']?.toString() ?? '',
      bookingCode: json['bookingCode']?.toString() ?? '',
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ?? DateTime.now(),
      status: json['status']?.toString() ?? 'PENDING',
      customerName: json['customerName']?.toString() ?? 'Khách hàng',
    );
  }
}

class VehicleScheduleQuery {
  final String vehicleId;
  final DateTime startDate;
  final DateTime endDate;

  const VehicleScheduleQuery({
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleScheduleQuery &&
          runtimeType == other.runtimeType &&
          vehicleId == other.vehicleId &&
          startDate.year == other.startDate.year &&
          startDate.month == other.startDate.month &&
          startDate.day == other.startDate.day &&
          endDate.year == other.endDate.year &&
          endDate.month == other.endDate.month &&
          endDate.day == other.endDate.day;

  @override
  int get hashCode =>
      vehicleId.hashCode ^
      startDate.year.hashCode ^
      startDate.month.hashCode ^
      startDate.day.hashCode ^
      endDate.year.hashCode ^
      endDate.month.hashCode ^
      endDate.day.hashCode;
}

