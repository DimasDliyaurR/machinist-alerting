import 'package:masinis_helper/src/core/app_constant.dart';
import 'package:masinis_helper/src/dto/dto_base.dart';

class SignalDto extends DtoBase {
  final int? id;
  final TipeSignal tipe;
  final String latitude;
  final String longitude;
  final String nama;

  SignalDto({
    this.id,
    required this.tipe,
    required this.latitude,
    required this.longitude,
    required this.nama,
  });

  factory SignalDto.formMap(Map<String, dynamic> map) {
    return SignalDto(
      id: map["id"],
      tipe: TipeSignal.values.byName(map["tipe"] as String),
      nama: map["nama"],
      latitude: map["latitude"],
      longitude: map["longitude"],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'tipe': tipe.name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
