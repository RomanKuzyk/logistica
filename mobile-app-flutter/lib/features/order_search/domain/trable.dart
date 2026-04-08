class Trable {
  const Trable({
    required this.idRef,
    required this.name,
    required this.typeTrables,
  });

  final String idRef;
  final String name;
  final String typeTrables;

  bool get isSelected => idRef.isNotEmpty;
}
