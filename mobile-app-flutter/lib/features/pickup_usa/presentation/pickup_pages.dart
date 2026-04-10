import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/core/api/api_exceptions.dart';
import 'package:mobile_app_flutter/features/auth/domain/auth_user.dart';
import 'package:mobile_app_flutter/features/pickup_usa/data/pickup_repository.dart';
import 'package:mobile_app_flutter/features/pickup_usa/domain/pickup_models.dart';
import 'package:mobile_app_flutter/shared/widgets/legacy_alert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class PickupListPage extends StatefulWidget {
  const PickupListPage({
    super.key,
    required this.services,
    required this.user,
  });

  final AppServices services;
  final AuthUser user;

  @override
  State<PickupListPage> createState() => _PickupListPageState();
}

class _PickupListPageState extends State<PickupListPage> {
  late final PickupRepository _repository;
  bool _loading = true;
  List<Pickup> _pickups = const <Pickup>[];

  @override
  void initState() {
    super.initState();
    _repository = PickupRepository(apiClient: widget.services.apiClient);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final List<Pickup> pickups =
          await _repository.fetchPickups(widget.user.userId);
      if (!mounted) return;
      setState(() {
        _pickups = pickups;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      await showLegacyAlertDialog(context,
          title: 'Errors', message: 'Error : ${error.message}');
    }
  }

  Future<void> _openCreatePickup() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PickupCreatePage(
          services: widget.services,
          user: widget.user,
        ),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _openPickup(Pickup pickup) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PickupDetailPage(
          services: widget.services,
          pickup: pickup,
          user: widget.user,
        ),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _openTimeSelection(Pickup pickup) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PickupTimeSelectionPage(
          services: widget.services,
          pickup: pickup,
        ),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Pickup USA'),
        actions: <Widget>[
          IconButton(
            onPressed: _openCreatePickup,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _pickups.length,
              itemBuilder: (BuildContext context, int index) {
                final Pickup pickup = _pickups[index];
                return InkWell(
                  onTap: () => _openPickup(pickup),
                  child: Container(
                    color:
                        index.isEven ? const Color(0xFFEDEDF1) : Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                pickup.shtat,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              pickup.distance > 0
                                  ? pickup.distance.toStringAsFixed(2)
                                  : '',
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => _openTimeSelection(pickup),
                              child: const Text('Time'),
                            ),
                          ],
                        ),
                        Text(pickup.city),
                        Text(pickup.address),
                        Text(pickup.senderName),
                        const SizedBox(height: 8),
                        Text('Pickup: ${pickup.timeFrom} - ${pickup.timeTo}'),
                        Text(
                            'Courier: ${pickup.planedTimeFrom} - ${pickup.planedTimeTo}'),
                        const SizedBox(height: 8),
                        Text(
                          pickup.amount > 0
                              ? 'Price pickup : \$ ${pickup.amount.toStringAsFixed(2)}'
                              : 'Price pickup - Free',
                          style: TextStyle(
                            color:
                                pickup.amount > 0 ? Colors.red : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class PickupTimeSelectionPage extends StatefulWidget {
  const PickupTimeSelectionPage({
    super.key,
    required this.services,
    required this.pickup,
  });

  final AppServices services;
  final Pickup pickup;

  @override
  State<PickupTimeSelectionPage> createState() =>
      _PickupTimeSelectionPageState();
}

class _PickupTimeSelectionPageState extends State<PickupTimeSelectionPage> {
  late final PickupRepository _repository;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _repository = PickupRepository(apiClient: widget.services.apiClient);
  }

  Future<void> _submit(PickupTimeOption option) async {
    setState(() => _busy = true);
    try {
      final PickupStatusResult result = await _repository.setPickupTime(
        idRef: widget.pickup.idRef,
        selectedHour: option.value,
      );
      if (!mounted) return;
      if (!result.isSuccess) {
        await showLegacyAlertDialog(context,
            title: 'Errors', message: 'Error : ${result.errorDetail}');
        return;
      }
      Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (!mounted) return;
      await showLegacyAlertDialog(context,
          title: 'Errors', message: 'Error : ${error.message}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Time'),
      ),
      body: ListView.builder(
        itemCount: PickupRepository.timeOptions.length,
        itemBuilder: (BuildContext context, int index) {
          final PickupTimeOption item = PickupRepository.timeOptions[index];
          return ListTile(
            enabled: !_busy,
            title: Text(item.label),
            onTap: () => _submit(item),
          );
        },
      ),
    );
  }
}

class PickupCreatePage extends StatefulWidget {
  const PickupCreatePage({
    super.key,
    required this.services,
    required this.user,
  });

  final AppServices services;
  final AuthUser user;

  @override
  State<PickupCreatePage> createState() => _PickupCreatePageState();
}

class _PickupCreatePageState extends State<PickupCreatePage> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final String cleaned =
        _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length < 10) {
      await showLegacyAlertDialog(context,
          title: 'Errors', message: 'Phone number is incorrect, please fix !');
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ContragentSelectionPage(
          services: widget.services,
          user: widget.user,
          phone: '+1$cleaned',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Create pickup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                hintText: 'Phone',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _search,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1877F2),
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(),
              ),
              child: const Text('Go'),
            ),
          ],
        ),
      ),
    );
  }
}

class ContragentSelectionPage extends StatefulWidget {
  const ContragentSelectionPage({
    super.key,
    required this.services,
    required this.user,
    required this.phone,
  });

  final AppServices services;
  final AuthUser user;
  final String phone;

  @override
  State<ContragentSelectionPage> createState() =>
      _ContragentSelectionPageState();
}

class _ContragentSelectionPageState extends State<ContragentSelectionPage> {
  late final PickupRepository _repository;
  bool _loading = true;
  List<ContragentUsa> _items = const <ContragentUsa>[];

  @override
  void initState() {
    super.initState();
    _repository = PickupRepository(apiClient: widget.services.apiClient);
    _load();
  }

  Future<void> _load() async {
    try {
      final List<ContragentUsa> items =
          await _repository.searchContragentsByPhone(widget.phone);
      if (!mounted) return;
      if (items.isEmpty) {
        setState(() => _loading = false);
        await _askCreateNew();
        return;
      }
      setState(() {
        _items = items;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      await showLegacyAlertDialog(context,
          title: 'Errors', message: 'Error : ${error.message}');
    }
  }

  Future<void> _askCreateNew() async {
    final bool? shouldCreate = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Warning'),
        content: const Text('Client not found. Continue ?'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ok')),
        ],
      ),
    );
    if (shouldCreate == true && mounted) {
      await _createNewContragentAndPickup();
    }
  }

  Future<void> _createNewContragentAndPickup() async {
    final PickupStatusResult contragent =
        await _repository.registerNewContragentByPhone(widget.phone);
    if (!contragent.isSuccess) {
      if (!mounted) return;
      await showLegacyAlertDialog(context,
          title: 'Errors', message: 'Error : ${contragent.errorDetail}');
      return;
    }
    await _createPickupForContragent(contragent.idRef);
  }

  Future<void> _createPickupForContragent(String contragentIdRef) async {
    final PickupStatusResult result = await _repository.createPickupOnRoute(
      courierIdRef: widget.user.userId,
      contragentIdRef: contragentIdRef,
    );
    if (!result.isSuccess) {
      if (!mounted) return;
      await showLegacyAlertDialog(context,
          title: 'Errors', message: 'Error : ${result.errorDetail}');
      return;
    }

    final List<Pickup> pickups =
        await _repository.fetchPickups(widget.user.userId);
    final Pickup? pickup = pickups.cast<Pickup?>().firstWhere(
          (Pickup? item) =>
              item?.idRef.toUpperCase() == result.idRef.toUpperCase(),
          orElse: () => null,
        );
    if (!mounted || pickup == null) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => PickupDetailPage(
          services: widget.services,
          pickup: pickup,
          user: widget.user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Select contragent'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (BuildContext context, int index) {
                final ContragentUsa item = _items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle:
                      Text('${item.address}\n${item.agentName}\n${item.code}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _createPickupForContragent(item.idRef),
                );
              },
            ),
    );
  }
}

class PickupDetailPage extends StatefulWidget {
  const PickupDetailPage({
    super.key,
    required this.services,
    required this.pickup,
    required this.user,
  });

  final AppServices services;
  final Pickup pickup;
  final AuthUser user;

  @override
  State<PickupDetailPage> createState() => _PickupDetailPageState();
}

class _PickupDetailPageState extends State<PickupDetailPage> {
  late final PickupRepository _repository;
  List<PickupShipment> _shipments = const <PickupShipment>[];
  bool _loadingShipments = false;

  @override
  void initState() {
    super.initState();
    _repository = PickupRepository(apiClient: widget.services.apiClient);
    if (widget.pickup.contragentPickup) {
      _loadShipments();
    }
  }

  Future<void> _loadShipments() async {
    setState(() => _loadingShipments = true);
    try {
      final List<PickupShipment> shipments =
          await _repository.fetchPickupShipments(widget.pickup.idRef);
      if (!mounted) return;
      setState(() {
        _shipments = shipments;
        _loadingShipments = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _loadingShipments = false);
      await showLegacyAlertDialog(context,
          title: 'Errors', message: 'Error : ${error.message}');
    }
  }

  Future<void> _call(String phone) async {
    if (phone.trim().isEmpty) return;
    final Uri uri = Uri.parse('tel:$phone');
    await launchUrl(uri);
  }

  Future<void> _openSmsTemplates() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PickupSmsSelectPage(
          services: widget.services,
          pickup: widget.pickup,
          user: widget.user,
        ),
      ),
    );
  }

  Future<void> _openCancelReasons() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PickupCancelPage(
          services: widget.services,
          pickup: widget.pickup,
        ),
      ),
    );
  }

  Future<void> _openFinish() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PickupConfirmationPage(
          services: widget.services,
          pickup: widget.pickup,
          mode: widget.pickup.contragentPickup
              ? PickupConfirmationMode.finishContragent
              : PickupConfirmationMode.finishAgent,
          shipments: _shipments,
          smsText: '',
          cancelReason: null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool shopsUnavailable =
        widget.pickup.contragentPickup || widget.pickup.agentsPickup;
    final bool clientPickupUnavailable = !widget.pickup.contragentPickup;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Pickup'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(widget.pickup.senderName,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(widget.pickup.titleAddress, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          if (widget.pickup.phone.isNotEmpty)
            TextButton(
                onPressed: () => _call(widget.pickup.phone),
                child: Text('Call - ${widget.pickup.phone}')),
          if (widget.pickup.phone2.isNotEmpty)
            TextButton(
                onPressed: () => _call(widget.pickup.phone2),
                child: Text('Call - ${widget.pickup.phone2}')),
          Text('Pickup: ${widget.pickup.timeFrom} - ${widget.pickup.timeTo}',
              textAlign: TextAlign.center),
          Text(
              'Courier: ${widget.pickup.planedTimeFrom} - ${widget.pickup.planedTimeTo}',
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            widget.pickup.amount > 0
                ? 'Price pickup : ${widget.pickup.amount.toStringAsFixed(2)}'
                : 'Price pickup - Free',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: widget.pickup.amount > 0 ? Colors.red : Colors.black87),
          ),
          const SizedBox(height: 16),
          _PickupActionButton(
            label: shopsUnavailable ? '- Unavaible -' : 'Shops',
            enabled: false,
          ),
          _PickupActionButton(
            label: shopsUnavailable ? '- Unavaible -' : 'Photos',
            enabled: false,
          ),
          _PickupActionButton(
            label: shopsUnavailable ? '- Unavaible -' : 'Agents/Clients',
            enabled: false,
          ),
          _PickupActionButton(
            label: clientPickupUnavailable ? '- Unavaible -' : 'Clients PickUp',
            enabled: false,
          ),
          _PickupActionButton(label: 'SMS', onPressed: _openSmsTemplates),
          _PickupActionButton(
              label: 'Cancel pickup', onPressed: _openCancelReasons),
          _PickupActionButton(label: 'Finish pickup', onPressed: _openFinish),
          const SizedBox(height: 16),
          if (_loadingShipments) const LinearProgressIndicator(),
          if (_shipments.isNotEmpty) ...<Widget>[
            const Text('Shipments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ..._shipments.map((PickupShipment item) => ListTile(
                  dense: true,
                  title: Text(item.barcode),
                  subtitle:
                      Text('${item.countryName} / ${item.deliveryServiceName}'),
                  trailing: Text(
                      item.amount > 0 ? item.amount.toStringAsFixed(2) : ''),
                )),
          ],
        ],
      ),
    );
  }
}

class PickupSmsSelectPage extends StatelessWidget {
  const PickupSmsSelectPage({
    super.key,
    required this.services,
    required this.pickup,
    required this.user,
  });

  final AppServices services;
  final Pickup pickup;
  final AuthUser user;

  String _buildMessage(String minutes) {
    return 'The Dnipro Company courier will come to pick up your parcel approximately in $minutes minutes. DNIPRO LLC ';
  }

  @override
  Widget build(BuildContext context) {
    const List<String> values = <String>['30', '60', '90', '120'];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('SMS'),
      ),
      body: ListView.builder(
        itemCount: values.length,
        itemBuilder: (BuildContext context, int index) {
          final String value = values[index];
          return ListTile(
            title: Text(value),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PickupConfirmationPage(
                    services: services,
                    pickup: pickup,
                    mode: PickupConfirmationMode.sms,
                    shipments: const <PickupShipment>[],
                    smsText: _buildMessage(value),
                    cancelReason: null,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

enum PickupConfirmationMode {
  sms,
  cancel,
  finishAgent,
  finishContragent,
}

class PickupCancelPage extends StatelessWidget {
  const PickupCancelPage({
    super.key,
    required this.services,
    required this.pickup,
  });

  final AppServices services;
  final Pickup pickup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Cancel pickup'),
      ),
      body: ListView.builder(
        itemCount: PickupRepository.cancelReasons.length,
        itemBuilder: (BuildContext context, int index) {
          final PickupCancelReason item = PickupRepository.cancelReasons[index];
          return ListTile(
            title: Text(item.name),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PickupConfirmationPage(
                    services: services,
                    pickup: pickup,
                    mode: PickupConfirmationMode.cancel,
                    shipments: const <PickupShipment>[],
                    smsText: '',
                    cancelReason: item,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PickupConfirmationPage extends StatefulWidget {
  const PickupConfirmationPage({
    super.key,
    required this.services,
    required this.pickup,
    required this.mode,
    required this.shipments,
    required this.smsText,
    required this.cancelReason,
  });

  final AppServices services;
  final Pickup pickup;
  final PickupConfirmationMode mode;
  final List<PickupShipment> shipments;
  final String smsText;
  final PickupCancelReason? cancelReason;

  @override
  State<PickupConfirmationPage> createState() => _PickupConfirmationPageState();
}

class _PickupConfirmationPageState extends State<PickupConfirmationPage> {
  late final PickupRepository _repository;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _repository = PickupRepository(apiClient: widget.services.apiClient);
  }

  String get _titleButton => switch (widget.mode) {
        PickupConfirmationMode.sms => 'Pickup Send SMS',
        PickupConfirmationMode.cancel => 'CANCEL PICKUP',
        PickupConfirmationMode.finishAgent ||
        PickupConfirmationMode.finishContragent =>
          'FINISH PICKUP',
      };

  String get _message => switch (widget.mode) {
        PickupConfirmationMode.sms => widget.smsText,
        PickupConfirmationMode.cancel => widget.cancelReason?.name ?? '',
        PickupConfirmationMode.finishAgent ||
        PickupConfirmationMode.finishContragent =>
          'Pickup finish..',
      };

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      switch (widget.mode) {
        case PickupConfirmationMode.sms:
          String phone = widget.pickup.phone;
          if (!phone.startsWith('1')) {
            phone = '1$phone';
          }
          await _repository.sendSms(phone: phone, text: widget.smsText);
          break;
        case PickupConfirmationMode.cancel:
          final PickupStatusResult result =
              await _repository.changePickupStatus(
            idRef: widget.pickup.idRef,
            mode: '1',
            status: widget.cancelReason?.idRef ?? '',
            incoming: const <String>[],
            outcoming: const <String>[],
            money: 0,
          );
          if (!result.isSuccess) {
            throw ApiBusinessException(result.errorDetail);
          }
          break;
        case PickupConfirmationMode.finishAgent:
          await showLegacyAlertDialog(
            context,
            title: 'Atantion',
            message:
                'Loading error : shipment registration flow is unavailable.',
          );
          return;
        case PickupConfirmationMode.finishContragent:
          final double shipmentMoney = widget.shipments.fold<double>(
            0,
            (double sum, PickupShipment item) => sum + item.amount,
          );
          final PickupStatusResult result =
              await _repository.finishContragentPickup(
            pickup: widget.pickup,
            outcoming: widget.shipments,
            money: shipmentMoney + widget.pickup.amount,
            moneyOfPickup: widget.pickup.amount,
          );
          if (!result.isSuccess) {
            throw ApiBusinessException(result.errorDetail);
          }
          break;
      }

      if (!mounted) return;
      Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
    } on ApiException catch (error) {
      if (!mounted) return;
      await showLegacyAlertDialog(context,
          title: 'Errors', message: 'Error : ${error.message}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int shipmentCount = widget.shipments.length;
    final double shipmentMoney = widget.shipments.fold<double>(
        0, (double sum, PickupShipment item) => sum + item.amount);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Confirmation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(widget.pickup.phone, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(_message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (widget.mode == PickupConfirmationMode.finishAgent ||
                widget.mode ==
                    PickupConfirmationMode.finishContragent) ...<Widget>[
              Text(
                  'Total parcels: ${widget.mode == PickupConfirmationMode.finishContragent ? ' - - -' : 0}'),
              Text('Total Shipments: $shipmentCount'),
              Text(
                  'Amount money : ${(shipmentMoney + widget.pickup.amount).toStringAsFixed(2)}'),
              const SizedBox(height: 16),
            ],
            FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: widget.mode == PickupConfirmationMode.cancel
                    ? Colors.red
                    : const Color(0xFF1877F2),
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(),
              ),
              child: Text(_busy ? 'Please wait...' : _titleButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickupActionButton extends StatelessWidget {
  const _PickupActionButton({
    required this.label,
    this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 46,
        child: FilledButton(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1877F2),
            disabledBackgroundColor: const Color(0xFF9C9C9C),
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white70,
            shape: const RoundedRectangleBorder(),
          ),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
