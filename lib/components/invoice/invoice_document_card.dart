import 'package:flutter/material.dart';

import 'package:bizly/utils/app_colors.dart';

class InvoiceDocumentLineItem {
  final String name;
  final String qty;
  final String unitPrice;
  final String total;

  const InvoiceDocumentLineItem({
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.total,
  });
}

class InvoiceDocumentCard extends StatelessWidget {
  final Widget? leadingLogo;
  final String businessName;
  final String businessAddress;
  final String businessContact;
  final String businessTaxId;
  final String status;
  final Color statusTextColor;
  final Color statusBackgroundColor;
  final String invoiceNumber;
  final String invoiceDate;
  final String billToName;
  final String billToEmail;
  final String billToPhone;
  final List<InvoiceDocumentLineItem> items;
  final List<MapEntry<String, String>> metaEntries;
  final String subtotalText;
  final String taxText;
  final bool showTax;
  final String totalText;
  final String invoiceNotes;
  final String lateFeeText;
  final String terms;
  final String additionalNotes;
  final String thankYou;

  const InvoiceDocumentCard({
    super.key,
    this.leadingLogo,
    required this.businessName,
    required this.businessAddress,
    required this.businessContact,
    required this.businessTaxId,
    this.status = '',
    this.statusTextColor = Colors.transparent,
    this.statusBackgroundColor = Colors.transparent,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.billToName,
    this.billToEmail = '',
    this.billToPhone = '',
    this.items = const <InvoiceDocumentLineItem>[],
    this.metaEntries = const <MapEntry<String, String>>[],
    required this.subtotalText,
    this.taxText = '',
    this.showTax = false,
    required this.totalText,
    this.invoiceNotes = '',
    this.lateFeeText = '',
    this.terms = '',
    this.additionalNotes = '',
    this.thankYou = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leadingLogo != null) ...[
                leadingLogo!,
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                    if (businessAddress.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        businessAddress.trim(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          height: 1.3,
                        ),
                      ),
                    ],
                    if (businessContact.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        businessContact.trim(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    if (businessTaxId.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Tax ID: ${businessTaxId.trim()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (status.trim().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: statusTextColor,
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        status.trim().toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: statusTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '#$invoiceNumber',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    invoiceDate,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 16),
          const Text(
            'BILL TO',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            billToName.isNotEmpty ? billToName : '-',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          if (billToEmail.trim().isNotEmpty)
            Text(
              billToEmail.trim(),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          if (billToPhone.trim().isNotEmpty)
            Text(
              billToPhone.trim(),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          const SizedBox(height: 16),
          _itemsTable(),
          const SizedBox(height: 16),
          _summarySection(),
        ],
      ),
    );
  }

  Widget _itemsTable() {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          'No items',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      );
    }

    final TextStyle headerStyle = const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
    );
    final TextStyle cellStyle = TextStyle(
      fontSize: 11.5,
      color: Colors.grey.shade900,
      fontWeight: FontWeight.w500,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(flex: 4, child: Text('Item', style: headerStyle)),
                Expanded(
                  flex: 2,
                  child: Text('Qty', textAlign: TextAlign.center, style: headerStyle),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Price', textAlign: TextAlign.center, style: headerStyle),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Total', textAlign: TextAlign.right, style: headerStyle),
                ),
              ],
            ),
          ),
          ...items.map(
            (InvoiceDocumentLineItem item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 0.7),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(item.name, style: cellStyle),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.qty,
                      textAlign: TextAlign.center,
                      style: cellStyle,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.unitPrice,
                      textAlign: TextAlign.center,
                      style: cellStyle,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.total,
                      textAlign: TextAlign.right,
                      style: cellStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summarySection() {
    final bool hasMetaInfo = metaEntries.isNotEmpty;

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Expanded(
                child: hasMetaInfo
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...List<Widget>.generate(
                              metaEntries.length,
                              (int index) => _metaInfoRow(
                                title: metaEntries[index].key,
                                value: metaEntries[index].value,
                                isLast: index == metaEntries.length - 1,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 12),
              Container(
                width: 180,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _summaryLine('Subtotal', subtotalText),
                    if (showTax) ...[
                      const SizedBox(height: 6),
                      _summaryLine('Tax', taxText),
                    ],
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    _summaryLine('Total', totalText, bold: true),
                  ],
                ),
              ),
            ],
            ),
          ),
          if (invoiceNotes.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _detailSection(
                title: 'Invoice Notes',
                value: invoiceNotes,
              ),
            ),
          if (lateFeeText.trim().isNotEmpty)
            _detailSection(
              title: 'Late Fee',
              value: lateFeeText,
              valueColor: Colors.red.shade700,
            ),
          if (terms.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: _detailSection(
                title: 'Terms & Conditions',
                value: terms,
              ),
            ),
          if (additionalNotes.trim().isNotEmpty)
            _detailSection(
              title: 'Additional Notes',
              value: additionalNotes,
            ),
          if (thankYou.trim().isNotEmpty)
            _detailSection(
              title: 'Thank You',
              value: thankYou,
            ),
        ],
      ),
    );
  }

  Widget _summaryLine(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: bold ? AppColors.primary : Colors.grey.shade900,
          ),
        ),
      ],
    );
  }

  Widget _metaInfoRow({
    required String title,
    required String value,
    bool isLast = false,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 0.8,
                ),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailSection({
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.5,
              color: valueColor ?? Colors.grey.shade800,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
