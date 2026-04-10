class ManifestShipment {
  const ManifestShipment({
    required this.shipmentsIdRef,
    required this.orderIdRef,
    required this.numberManifest,
    required this.name,
    required this.orderNumber,
    required this.orderDateTime,
  });

  final String shipmentsIdRef;
  final String orderIdRef;
  final String numberManifest;
  final String name;
  final String orderNumber;
  final String orderDateTime;
}
