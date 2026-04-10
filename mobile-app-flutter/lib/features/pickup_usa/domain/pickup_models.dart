class Pickup {
  const Pickup({
    required this.idRef,
    required this.routeIdRef,
    required this.contragentIdRef,
    required this.phone,
    required this.phone2,
    required this.timeFrom,
    required this.timeTo,
    required this.planedTimeFrom,
    required this.planedTimeTo,
    required this.countShipments,
    required this.senderName,
    required this.address,
    required this.city,
    required this.shtat,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.completed,
    required this.onlyPickupNoShipments,
    required this.agentsPickup,
    required this.contragentPickup,
    required this.amount,
  });

  final String idRef;
  final String routeIdRef;
  final String contragentIdRef;
  final String phone;
  final String phone2;
  final String timeFrom;
  final String timeTo;
  final String planedTimeFrom;
  final String planedTimeTo;
  final int countShipments;
  final String senderName;
  final String address;
  final String city;
  final String shtat;
  final double latitude;
  final double longitude;
  final double distance;
  final bool completed;
  final bool onlyPickupNoShipments;
  final bool agentsPickup;
  final bool contragentPickup;
  final double amount;

  String get titleAddress => [shtat, city, address]
      .where((String value) => value.trim().isNotEmpty)
      .join(' ')
      .trim();
}

class PickupShipment {
  const PickupShipment({
    required this.idRef,
    required this.contragentIdRef,
    required this.pickUpIdRef,
    required this.agentIdRef,
    required this.countryIdRef,
    required this.deliveryServiceIdRef,
    required this.countryName,
    required this.deliveryServiceName,
    required this.barcode,
    required this.weight,
    required this.length,
    required this.height,
    required this.width,
    required this.photo,
    required this.amount,
  });

  final String idRef;
  final String contragentIdRef;
  final String pickUpIdRef;
  final String agentIdRef;
  final String countryIdRef;
  final String deliveryServiceIdRef;
  final String countryName;
  final String deliveryServiceName;
  final String barcode;
  final double weight;
  final int length;
  final int height;
  final int width;
  final String photo;
  final double amount;
}

class ContragentUsa {
  const ContragentUsa({
    required this.idRef,
    required this.name,
    required this.code,
    required this.agentName,
    required this.address,
  });

  final String idRef;
  final String name;
  final String code;
  final String agentName;
  final String address;
}

class PickupStatusResult {
  const PickupStatusResult({
    required this.errorCode,
    required this.errorDetail,
    required this.idRef,
  });

  final int errorCode;
  final String errorDetail;
  final String idRef;

  bool get isSuccess => errorCode == 0;
}

class PickupCancelReason {
  const PickupCancelReason({required this.idRef, required this.name});

  final String idRef;
  final String name;
}

class PickupTimeOption {
  const PickupTimeOption({required this.label, required this.value});

  final String label;
  final String value;
}
