class InvoiceItem {
  final String name;
  final int qty;
  final double unitPrice;

  InvoiceItem({required this.name, required this.qty, required this.unitPrice});

  double get total => qty * unitPrice;
}

class InvoiceData {
  final String invoiceNo;
  final DateTime date;
  final String customerName;
  final String customerMobile;
  final String customerAddress;
  final List<InvoiceItem> items;
  final double discount;
  final double delivery;
  final double paid;

  InvoiceData({
    required this.invoiceNo,
    required this.date,
    required this.customerName,
    required this.customerMobile,
    required this.customerAddress,
    required this.items,
    required this.discount,
    required this.delivery,
    required this.paid,
  });

  double get subtotal => items.fold(0, (s, i) => s + i.total);
  double get grandTotal => subtotal - discount + delivery;
  double get due => (grandTotal - paid).clamp(0, double.infinity);
}
