import 'package:masinis_helper/src/dto/dto_base.dart';

class RouteDto extends DtoBase {
  int? id;
  String nama;
  String kode;
  String deksripsi;

  RouteDto({
    this.id,
    required this.nama,
    required this.kode,
    required this.deksripsi,
  });

  factory RouteDto.formMap(Map<String, dynamic> map) => RouteDto(
    id: map["id"],
    nama: map["nama"],
    kode: map["kode"],
    deksripsi: map["deskripsi"],
  );

  @override
  Map<String, dynamic> toMap() => {'id': id, 'nama': nama, 'kode': kode};
}
