import 'package:masinis_helper/src/dto/dto_base.dart';
import 'package:masinis_helper/src/dto/signal_dto.dart';

class RouteSignalDto extends DtoBase {
  int routerId;
  int signalId;
  int sequenceOrder;

  RouteSignalDto({
    required this.routerId,
    required this.signalId,
    required this.sequenceOrder,
  });

  factory RouteSignalDto.formMap(Map<String, dynamic> map) {
    return RouteSignalDto(
      routerId: map["router_id"],
      signalId: map["signal_id"],
      sequenceOrder: map["sequence_order"],
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    'router_id': routerId,
    'signal_id': signalId,
    'sequence_order': sequenceOrder,
  };
}

class RouteSignalWithSignalDto {
  int? id;
  List<SignalDto> signals;
  String routeNama;
  String kodeRoute;

  RouteSignalWithSignalDto({
    this.id,
    required this.signals,
    required this.routeNama,
    required this.kodeRoute,
  });

  factory RouteSignalWithSignalDto.fromMap(
    Map<String, dynamic> routeMap,
    List<Map<String, dynamic>> signalMap,
  ) => RouteSignalWithSignalDto(
    id: routeMap["id"],
    routeNama: routeMap["nama"],
    kodeRoute: routeMap["kode"],
    signals: signalMap.map((s) => SignalDto.formMap(s)).toList(),
  );
}
