import 'dart:convert';

import 'package:mobile_app_flutter/core/api/api_client.dart';
import 'package:mobile_app_flutter/features/pickup_usa/domain/pickup_models.dart';

class PickupRepository {
  PickupRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  static const List<PickupCancelReason> cancelReasons = <PickupCancelReason>[
    PickupCancelReason(
      idRef: '0x8a9f0afa66d752d711e85907f1caa1c0',
      name: 'Can not do it in time',
    ),
    PickupCancelReason(
      idRef: '0x8a9f0afa66d752d711e8590807923950',
      name: 'No seat in the car',
    ),
    PickupCancelReason(
      idRef: '0x8a9f0afa66d752d711e859083a818fa1',
      name: 'There is nobody at the address',
    ),
    PickupCancelReason(
      idRef: '0x8a9f0afa66d752d711e8590812bd4361',
      name: 'There is nobody at the address',
    ),
  ];

  static const List<PickupTimeOption> timeOptions = <PickupTimeOption>[
    PickupTimeOption(label: '06am - 08am', value: '06'),
    PickupTimeOption(label: '07am - 09am', value: '07'),
    PickupTimeOption(label: '08am - 10am', value: '08'),
    PickupTimeOption(label: '09am - 11am', value: '09'),
    PickupTimeOption(label: '10am - 12am', value: '10'),
    PickupTimeOption(label: '11am - 01pm', value: '11'),
    PickupTimeOption(label: '12am - 02pm', value: '12'),
    PickupTimeOption(label: '01pm - 03pm', value: '13'),
    PickupTimeOption(label: '02pm - 04pm', value: '14'),
    PickupTimeOption(label: '03pm - 05am', value: '15'),
    PickupTimeOption(label: '04pm - 06pm', value: '16'),
    PickupTimeOption(label: '05pm - 07pm', value: '17'),
    PickupTimeOption(label: '06pm - 08pm', value: '18'),
    PickupTimeOption(label: '07pm - 09pm', value: '19'),
    PickupTimeOption(label: '08pm - 10pm', value: '20'),
    PickupTimeOption(label: '09pm - 11pm', value: '21'),
  ];

  Future<List<Pickup>> fetchPickups(String courierIdRef) async {
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'MK_COURIER_USA_LIST_PICKUP',
      parameter: courierIdRef,
    );
    return items.map(_pickupFromApi).toList();
  }

  Future<List<PickupShipment>> fetchPickupShipments(String pickUpIdRef) async {
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'MK_COURIER_USA_LIST_PICKUP_SHIPMENTS',
      parameter: pickUpIdRef,
    );
    return items.map(_pickupShipmentFromApi).toList();
  }

  Future<List<ContragentUsa>> searchContragentsByPhone(String phone) async {
    final String cleaned = _cleanPhone(phone);
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'LIST_CONTRAGENT_ON_PHONE_USA',
      parameter: "'$cleaned'",
    );
    return items.map(_contragentFromApi).toList();
  }

  Future<PickupStatusResult> createPickupOnRoute({
    required String courierIdRef,
    required String contragentIdRef,
  }) async {
    final String payload = jsonEncode(<String, Object?>{
      'CourierIdRef': courierIdRef,
      'ContragentIdRef': contragentIdRef,
    });
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'CREATE_PICKUP_ON_ROUTE',
      parameter: payload,
    );
    return _resultFromItems(items);
  }

  Future<PickupStatusResult> registerNewContragentByPhone(String phone) async {
    final String payload = jsonEncode(<String, Object?>{
      'openid': 'PHONE',
      'email': _cleanPhone(phone),
      'Name': '',
      'openidtype': false,
      'agentIdRef': '0x8b9c0afa66d752d711e80656f6ac58c2',
      'coupon': '',
      'site': 'US',
    });
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'REGISTERED_CONTRAGENT_OPENID',
      parameter: payload,
    );
    return _resultFromItems(items);
  }

  Future<void> sendSms({required String phone, required String text}) async {
    String normalizedPhone = phone.trim();
    if (!normalizedPhone.startsWith('+')) {
      normalizedPhone = '+$normalizedPhone';
    }
    final String payload = jsonEncode(<String, Object?>{
      'PHONE': normalizedPhone,
      'SMSTEXT': text,
    });
    await _apiClient.execute(function: 'SMS', parameter: payload);
  }

  Future<PickupStatusResult> changePickupStatus({
    required String idRef,
    required String mode,
    required String status,
    required List<String> incoming,
    required List<String> outcoming,
    required double money,
  }) async {
    final String payload = jsonEncode(<String, Object?>{
      'IdRef': idRef,
      'status': status,
      'mode': mode,
      'incoming': incoming.join(', '),
      'outcoming': outcoming.join(', '),
      'money': money,
    });
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'CHANGE_STATUS2',
      parameter: payload,
    );
    return _resultFromItems(items);
  }

  Future<PickupStatusResult> finishContragentPickup({
    required Pickup pickup,
    required List<PickupShipment> outcoming,
    required double money,
    required double moneyOfPickup,
  }) async {
    final String payload = jsonEncode(<String, Object?>{
      'PickUpIdRef': pickup.idRef,
      'ContragentIdRef': pickup.contragentIdRef,
      'OutcomingShipments':
          outcoming.map((PickupShipment item) => item.idRef).join(', '),
      'MoneyOfPickup': moneyOfPickup,
      'Money': money,
    });
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'PICKUPUSA_FINISH_CONTRAGENT',
      parameter: payload,
    );
    return _resultFromItems(items);
  }

  Future<PickupStatusResult> setPickupTime({
    required String idRef,
    required String selectedHour,
  }) async {
    final String payload = '{"IdRef":"$idRef", "mode":"$selectedHour"}';
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'SET_TIME_STATUS_PICKUP',
      parameter: payload,
    );
    return _resultFromItems(items);
  }

  static Pickup _pickupFromApi(Map<String, dynamic> row) {
    return Pickup(
      idRef: _asString(row['IdRef']),
      routeIdRef: _asString(row['RouteIdRef']),
      contragentIdRef: _asString(row['ContragentIdRef']),
      phone: _asString(row['Phone']),
      phone2: _asString(row['Phone2']),
      timeFrom: _asString(row['TimeFrom']),
      timeTo: _asString(row['TimeTo']),
      planedTimeFrom: _asString(row['PlanedTimeFrom']),
      planedTimeTo: _asString(row['PlanedTimeTo']),
      countShipments: _asInt(row['CountShipments']),
      senderName: _asString(row['SenderName']),
      address: _asString(row['Address']),
      city: _asString(row['City']),
      shtat: _asString(row['Shtat']),
      latitude: _asDouble(row['Latitude']),
      longitude: _asDouble(row['Longitude']),
      distance: _asDouble(row['Distance']),
      completed: _asBool(row['Completed']),
      onlyPickupNoShipments: _asBool(row['OnlyPickupNoShipments']),
      agentsPickup: _asBool(row['AgentsPickup']),
      contragentPickup: _asBool(row['ContragentPickup']),
      amount: _asDouble(row['Amount']),
    );
  }

  static PickupShipment _pickupShipmentFromApi(Map<String, dynamic> row) {
    return PickupShipment(
      idRef: _asString(row['IdRef']),
      contragentIdRef: _asString(row['ContragentIdRef']),
      pickUpIdRef: _asString(row['PickUpIdRef']),
      agentIdRef: _asString(row['AgentIdRef']),
      countryIdRef: _asString(row['CountryIdRef']),
      deliveryServiceIdRef: _asString(row['DeliveryServiceIdRef']),
      countryName: _asString(row['CountryName']),
      deliveryServiceName: _asString(row['DeliveryServiceName']),
      barcode: _asString(row['Barcode']),
      weight: _asDouble(row['Weight']),
      length: _asInt(row['Length']),
      height: _asInt(row['Height']),
      width: _asInt(row['Width']),
      photo: _asString(row['Photo']),
      amount: _asDouble(row['Amount']),
    );
  }

  static ContragentUsa _contragentFromApi(Map<String, dynamic> row) {
    return ContragentUsa(
      idRef: _asString(row['IdRef']),
      name: _asString(row['Name']),
      code: _asString(row['Code']),
      agentName: _asString(row['AgentName']),
      address: _asString(row['Address']),
    );
  }

  static PickupStatusResult _resultFromItems(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const PickupStatusResult(errorCode: 0, errorDetail: '', idRef: '');
    }
    final Map<String, dynamic> row = items.first;
    return PickupStatusResult(
      errorCode: _asInt(row['Error']),
      errorDetail: _asString(row['ErrorsDetail']),
      idRef: _asString(row['IdRef']),
    );
  }

  static String _cleanPhone(String value) =>
      value.replaceAll(RegExp(r'[^0-9]'), '');
  static String _asString(Object? value) => value?.toString() ?? '';
  static int _asInt(Object? value) =>
      int.tryParse(value?.toString() ?? '') ?? 0;
  static double _asDouble(Object? value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;
  static bool _asBool(Object? value) {
    if (value is bool) return value;
    final String normalized = value?.toString().toLowerCase() ?? '';
    return normalized == 'true' || normalized == '1';
  }
}
