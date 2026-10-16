class VitalsData {
  final DateTime ts;
  final double hr;
  final double spo2;
  final int steps;
  final double temp;
  final double respRate;
  final double accelMag;
  final String activity;

  const VitalsData({
    required this.ts,
    required this.hr,
    required this.spo2,
    required this.steps,
    required this.temp,
    required this.respRate,
    required this.accelMag,
    required this.activity,
  });

  factory VitalsData.initial() => VitalsData(
    ts: DateTime.now(),
    hr: 72.0,
    spo2: 98.0,
    steps: 1240,
    temp: 36.6,
    respRate: 16.0,
    accelMag: 1.0,
    activity: 'resting',
  );

  factory VitalsData.fromJson(Map<String, dynamic> json) {
    return VitalsData(
      ts: DateTime.tryParse(json['ts']?.toString() ?? '') ?? DateTime.now(),
      hr: (json['hr'] as num?)?.toDouble() ?? 72.0,
      spo2: (json['spo2'] as num?)?.toDouble() ?? 98.0,
      steps: (json['steps'] as num?)?.toInt() ?? 0,
      temp: (json['temp'] as num?)?.toDouble() ?? 36.5,
      respRate: (json['resp_rate'] as num?)?.toDouble() ?? 16.0,
      accelMag: (json['accel_mag'] as num?)?.toDouble() ?? 1.0,
      activity: json['activity']?.toString() ?? 'resting',
    );
  }

  String get activityLabel {
    switch (activity.toLowerCase()) {
      case 'sleeping':
        return 'Tidur';
      case 'walking':
        return 'Jalan Santai';
      case 'exercising':
        return 'Aktivitas / Olahraga';
      case 'resting':
      default:
        return 'Istirahat';
    }
  }

  bool get isTachycardia => hr > 110;
  bool get isBradycardia => hr < 50;
  bool get isHypoxia => spo2 < 94;
  bool get isFever => temp >= 37.8;
}

class AlertItem {
  final String id;
  final String elderId;
  final String type;
  final String severity; // critical | warning | info
  final String message;
  final Map<String, dynamic> payload;
  final String source;
  final DateTime ts;
  bool acknowledged;

  AlertItem({
    required this.id,
    required this.elderId,
    required this.type,
    required this.severity,
    required this.message,
    this.payload = const {},
    this.source = 'rule',
    required this.ts,
    this.acknowledged = false,
  });

  factory AlertItem.fromJson(Map<String, dynamic> json) {
    return AlertItem(
      id: json['id']?.toString() ?? '',
      elderId: json['elder_id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      severity: json['severity']?.toString() ?? 'info',
      message: json['message']?.toString() ?? '',
      payload: (json['payload'] as Map<String, dynamic>?) ?? {},
      source: json['source']?.toString() ?? 'rule',
      ts: DateTime.tryParse(json['ts']?.toString() ?? '') ?? DateTime.now(),
      acknowledged: json['acknowledged'] == true,
    );
  }

  bool get isCritical => severity == 'critical';
  bool get isFall => type == 'fall_suspected';
  bool get isSos => type == 'sos_manual';

  String get title {
    if (isFall) return 'Jatuh Terdeteksi (Auto-SOS)';
    if (isSos) return 'Panggilan Darurat SOS!';
    switch (type) {
      case 'hr_high':
        return 'Detak Jantung Tinggi (Takikardia)';
      case 'hr_low':
        return 'Detak Jantung Rendah (Bradikardia)';
      case 'spo2_low':
        return 'Saturasi Oksigen Rendah (Hipoksia)';
      case 'temp_high':
        return 'Suhu Tubuh Tinggi (Demam)';
      case 'bp_high':
        return 'Lonjakan Tekanan Darah';
      case 'glucose_low':
        return 'Kadar Gula Darah Rendah';
      case 'geofence_exit':
        return 'Keluar dari Zona Aman (Wander)';
      default:
        return 'Peringatan Kesehatan';
    }
  }
}

class ElderSummary {
  final String id;
  final String name;
  final List<String> conditions;
  final String linkCode;
  final String? doctorName;
  final String? phone;
  final double homeLat;
  final double homeLng;
  final double geofenceM;

  const ElderSummary({
    required this.id,
    required this.name,
    this.conditions = const [],
    required this.linkCode,
    this.doctorName,
    this.phone,
    this.homeLat = -6.2349,
    this.homeLng = 106.9896,
    this.geofenceM = 150.0,
  });

  factory ElderSummary.fromJson(Map<String, dynamic> json) {
    return ElderSummary(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Lansia',
      conditions: (json['conditions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      linkCode: json['link_code']?.toString() ?? '',
      doctorName: json['doctor_name']?.toString(),
      phone: json['phone']?.toString(),
      homeLat: (json['home_lat'] as num?)?.toDouble() ?? -6.2349,
      homeLng: (json['home_lng'] as num?)?.toDouble() ?? 106.9896,
      geofenceM: (json['geofence_m'] as num?)?.toDouble() ?? 150.0,
    );
  }
}

class LocationData {
  final double lat;
  final double lng;
  final double distanceFromHomeM;
  final bool insideGeofence;

  const LocationData({
    required this.lat,
    required this.lng,
    required this.distanceFromHomeM,
    required this.insideGeofence,
  });

  factory LocationData.initial() => const LocationData(
    lat: -6.2349,
    lng: 106.9896,
    distanceFromHomeM: 0,
    insideGeofence: true,
  );

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      lat: (json['lat'] as num?)?.toDouble() ?? -6.2349,
      lng: (json['lng'] as num?)?.toDouble() ?? 106.9896,
      distanceFromHomeM:
          (json['distance_from_home_m'] as num?)?.toDouble() ?? 0.0,
      insideGeofence: json['inside_geofence'] != false,
    );
  }
}

class MeasurementData {
  final String kind;
  final double value1;
  final double? value2;
  final String? context;
  final DateTime ts;

  const MeasurementData({
    required this.kind,
    required this.value1,
    this.value2,
    this.context,
    required this.ts,
  });

  factory MeasurementData.fromJson(Map<String, dynamic> json) {
    return MeasurementData(
      kind: json['kind']?.toString() ?? 'bp',
      value1: (json['value1'] as num?)?.toDouble() ?? 120.0,
      value2: (json['value2'] as num?)?.toDouble(),
      context: json['context']?.toString(),
      ts: DateTime.tryParse(json['ts']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String get displayString {
    if (kind == 'bp' && value2 != null) {
      return '${value1.toInt()}/${value2!.toInt()} mmHg';
    } else if (kind == 'glucose') {
      return '${value1.toInt()} mg/dL';
    }
    return '${value1.toInt()}';
  }
}
