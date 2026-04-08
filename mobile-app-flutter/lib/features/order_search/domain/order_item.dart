class OrderItem {
  const OrderItem({
    required this.idRef,
    required this.orderNumber,
    required this.orderDate,
    required this.number,
    required this.title,
    required this.linkPhoto,
    required this.link,
    required this.customRoute,
    required this.deliveryType,
    required this.count,
    required this.manager,
  });

  final String idRef;
  final String orderNumber;
  final String orderDate;
  final String number;
  final String title;
  final String linkPhoto;
  final String link;
  final String customRoute;
  final String deliveryType;
  final int count;
  final String manager;
}
