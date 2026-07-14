class RecordDto {
  final int? id;
  final String latitude;
  final String longitude;
  final String nama;

  const RecordDto({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.nama,
  });

  factory RecordDto.fromMap(Map<String, dynamic> map) {
    return RecordDto(
      id: map["id"],
      nama: map["nama"],
      latitude: map["latitude"],
      longitude: map["longitude"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
