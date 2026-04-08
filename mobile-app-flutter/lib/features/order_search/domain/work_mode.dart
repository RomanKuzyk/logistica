enum WorkMode {
  receive,
  unpack,
  reprint,
  details,
  manifest;

  String get title => switch (this) {
        WorkMode.receive => 'Прийняти замовлення',
        WorkMode.unpack => 'Розпакувати',
        WorkMode.reprint => 'Передрукувати',
        WorkMode.details => 'Деталі замовлення (PL)',
        WorkMode.manifest => 'Формування маніфесту',
      };
}
