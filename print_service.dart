import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'invoice.dart';

class PrintService {
  static const company = 'SafwanTech';
  static const tagline = 'CCTV SOLUTION';
  static const phone = '01677316296';
  static const address = 'Jatrabari, Dhaka-1236';
  static const email = 'safwantechbd@gmail.com';
  static const website = 'www.safwantech.com';

  static pw.Widget copy(InvoiceData inv, String label) {
    final money = (double v) => '৳${v.toStringAsFixed(2)}';
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
        pw.Center(child: pw.Text(company, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
        pw.Center(child: pw.Text(tagline)),
        pw.Center(child: pw.Text('$phone  |  $email')),
        pw.Center(child: pw.Text(address)),
        pw.SizedBox(height: 8),
        pw.Center(child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13))),
        pw.SizedBox(height: 6),
        pw.Text('Invoice: ${inv.invoiceNo}'),
        pw.Text('Date: ${inv.date.toLocal()}'),
        pw.Text('Customer: ${inv.customerName}'),
        pw.Text('Mobile: ${inv.customerMobile}'),
        if (inv.customerAddress.isNotEmpty) pw.Text('Address: ${inv.customerAddress}'),
        pw.SizedBox(height: 8),
        pw.Table.fromTextArray(
          headers: const ['Product', 'Qty', 'Price', 'Total'],
          data: inv.items.map((i) => [i.name, '${i.qty}', money(i.unitPrice), money(i.total)]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Subtotal: ${money(inv.subtotal)}')),
        pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Discount: ${money(inv.discount)}')),
        pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Delivery: ${money(inv.delivery)}')),
        pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Grand Total: ${money(inv.grandTotal)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Paid: ${money(inv.paid)}')),
        pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Due: ${money(inv.due)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        pw.SizedBox(height: 8),
        pw.Text(website, textAlign: pw.TextAlign.center),
      ]),
    );
  }

  static Future<Uint8List> makeA4(InvoiceData inv) async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(18),
      build: (_) => pw.Column(children: [
        pw.Expanded(child: copy(inv, 'CUSTOMER COPY')),
        pw.Container(height: 12, child: pw.Center(child: pw.Text('------------------------------------------------'))),
        pw.Expanded(child: copy(inv, 'OFFICE COPY')),
      ]),
    ));
    return doc.save();
  }

  static Future<void> printA4TwoCopies(InvoiceData inv) async {
    final bytes = await makeA4(inv);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  static Future<void> sharePdf(InvoiceData inv) async {
    final bytes = await makeA4(inv);
    await Printing.sharePdf(bytes: bytes, filename: '${inv.invoiceNo}.pdf');
  }

  static Future<void> printThermalTwoCopies(InvoiceData inv) async {
    throw UnimplementedError('Thermal Bluetooth printing will be connected after the printer model is known.');
  }
}
