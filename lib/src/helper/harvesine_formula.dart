import 'dart:math' as math;

double convertToRadiant(double number) => number * (math.pi / 180);
double convertKmToM(double kilometer) => kilometer * 1000;

/// 'Harvesien Formula' use as formula to measure the distance between both points using latitude and longitude
/// Formula :
/// `
///     a = \sin^2(\Delta \phi/1) + \cos\phi_1 \times \cos\phi_2 \times \sin^2(\Delta \lambda)
///     c = atan2(\sqrt{a}, \sqrt{-a})
///     d = 6371 \times c
/// `
/// Returns distance in KM than will be convert into meters
double haversineFormula({
  required double distanceLat,
  required double distanceLong,
  required double currentLat,
  required double currentLon,
}) {
  print(
    "haversineFormula : distanceLong $distanceLong, distanceLat $distanceLat, currentLat $currentLat, currentLon $currentLon",
  );
  int R = 6371;

  double delLat = convertToRadiant(distanceLat - currentLat);
  double delLan = convertToRadiant(distanceLong - currentLon);

  double lat1 = convertToRadiant(currentLat);
  double lat2 = convertToRadiant(distanceLat);

  double a =
      math.pow(math.sin(delLat / 2), 2) +
      math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(delLan / 2), 2);

  a = a.clamp(0, 0.1);

  print("c = 2 * ${math.asin(math.sqrt(a))}, a = $a");
  double c = 2 * math.asin(math.sqrt(a));

  print("Result haversineFormula : ${convertKmToM(R * c)} : $R * $c");
  return convertKmToM(R * c);
}
