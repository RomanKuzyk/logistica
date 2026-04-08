import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_buy_search_item.dart';
import 'package:mobile_app_flutter/features/order_search/domain/work_mode.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/order_details_preview_page.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/reprint_action_page.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/order_search_detail_page.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/unpacking_summary_page.dart';

class OrderResultListPage extends StatelessWidget {
  const OrderResultListPage({
    super.key,
    required this.results,
    required this.services,
    required this.mode,
  });

  final List<OrderBuySearchItem> results;
  final AppServices services;
  final WorkMode mode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(''),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Обрати',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: results.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          final OrderBuySearchItem item = results[index];
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => switch (mode) {
                    WorkMode.unpack => UnpackingSummaryPage(order: item),
                    WorkMode.reprint => ReprintActionPage(order: item),
                    WorkMode.details => OrderDetailsPreviewPage(order: item),
                    _ => OrderSearchDetailPage(
                        order: item,
                        services: services,
                      ),
                  },
                ),
              );
            },
            child: Container(
              color: index.isEven ? const Color(0xFFEDEDF1) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          item.displayNumber.isEmpty
                              ? 'Без номера'
                              : item.displayNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Text(
                        item.count.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    [item.street, item.city]
                        .where((String value) => value.isNotEmpty)
                        .join(' '),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.customerName,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.waybill,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    child: Text(
                      item.nameOrders,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ДО ОПЛАТИ PL : ${item.summaCod.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'ОПЛАЧЕНО : ${item.summaPayPl.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
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
