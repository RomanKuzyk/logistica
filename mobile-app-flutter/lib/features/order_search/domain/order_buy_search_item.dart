class OrderBuySearchItem {
  const OrderBuySearchItem({
    required this.idRef,
    required this.isCod,
    required this.orderNumber,
    required this.number,
    required this.firstName,
    required this.lastName,
    required this.zipCode,
    required this.city,
    required this.email,
    required this.street,
    required this.phoneNumber,
    required this.company,
    required this.summaCod,
    required this.waybill,
    required this.orderDate,
    required this.processOfficePlAction,
    required this.link,
    required this.nameOrders,
    required this.summaPayPl,
    required this.count,
  });

  final String idRef;
  final bool isCod;
  final String orderNumber;
  final String number;
  final String firstName;
  final String lastName;
  final String zipCode;
  final String city;
  final String email;
  final String street;
  final String phoneNumber;
  final String company;
  final double summaCod;
  final String waybill;
  final String orderDate;
  final String processOfficePlAction;
  final String link;
  final String nameOrders;
  final double summaPayPl;
  final int count;

  String get displayNumber => orderNumber.isNotEmpty ? orderNumber : number;

  String get customerName {
    final String fullName = '$firstName $lastName'.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    return company;
  }

  String get subtitle {
    final List<String> parts = <String>[
      if (waybill.isNotEmpty) 'Waybill: $waybill',
      if (city.isNotEmpty) city,
      if (nameOrders.isNotEmpty) nameOrders,
    ];
    return parts.join(' • ');
  }
}
