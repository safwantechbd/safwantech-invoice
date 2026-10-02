import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'invoice.dart';
import 'print_service.dart';

void main() => runApp(const SafwanTechApp());

class SafwanTechApp extends StatelessWidget {
  const SafwanTechApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafwanTech Invoice',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SafwanTech Invoice')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('CCTV SOLUTION', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('01677316296  •  Jatrabari, Dhaka-1236'),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewInvoicePage())),
          icon: const Icon(Icons.receipt_long), label: const Text('New Invoice'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyPage())),
          icon: const Icon(Icons.business), label: const Text('Company Profile'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => showDialog(context: context, builder: (_) => const AlertDialog(
            title: Text('Printing'),
            content: Text('A4: one page with Customer Copy + Office Copy. Thermal Bluetooth printing will be added after the printer model is known.'),
          )),
          icon: const Icon(Icons.print), label: const Text('Print Info'),
        ),
      ]),
    );
  }
}

class NewInvoicePage extends StatefulWidget {
  const NewInvoicePage({super.key});
  @override State<NewInvoicePage> createState() => _NewInvoicePageState();
}

class _NewInvoicePageState extends State<NewInvoicePage> {
  final customer = TextEditingController();
  final mobile = TextEditingController();
  final address = TextEditingController();
  final product = TextEditingController();
  final qty = TextEditingController(text: '1');
  final price = TextEditingController();
  final discount = TextEditingController(text: '0');
  final delivery = TextEditingController(text: '0');
  final paid = TextEditingController(text: '0');
  final List<InvoiceItem> items = [];

  double n(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;
  int q() => int.tryParse(qty.text.trim()) ?? 1;

  void addItem() {
    if (product.text.trim().isEmpty || n(price) <= 0) return;
    setState(() {
      items.add(InvoiceItem(name: product.text.trim(), qty: q(), unitPrice: n(price)));
      product.clear(); qty.text = '1'; price.clear();
    });
  }

  InvoiceData buildInvoice() => InvoiceData(
    invoiceNo: 'ST-${DateFormat('yyyyMMdd-HHmmss').format(DateTime.now())}',
    date: DateTime.now(),
    customerName: customer.text.trim(),
    customerMobile: mobile.text.trim(),
    customerAddress: address.text.trim(),
    items: List.of(items),
    discount: n(discount),
    delivery: n(delivery),
    paid: n(paid),
  );

  @override
  Widget build(BuildContext context) {
    final inv = buildInvoice();
    return Scaffold(
      appBar: AppBar(title: const Text('New Invoice')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: customer, decoration: const InputDecoration(labelText: 'Customer Name')),
        TextField(controller: mobile, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile')),
        TextField(controller: address, decoration: const InputDecoration(labelText: 'Address')),
        const SizedBox(height: 12),
        const Text('Product', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(controller: product, decoration: const InputDecoration(labelText: 'Product name')),
        Row(children: [
          Expanded(child: TextField(controller: qty, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Qty'))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Unit price'))),
          IconButton(onPressed: addItem, icon: const Icon(Icons.add_circle)),
        ]),
        ...items.asMap().entries.map((e) => ListTile(
          title: Text(e.value.name), subtitle: Text('${e.value.qty} × ৳${e.value.unitPrice.toStringAsFixed(2)}'),
          trailing: Text('৳${e.value.total.toStringAsFixed(2)}'),
        )),
        const Divider(),
        TextField(controller: discount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Discount')),
        TextField(controller: delivery, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Delivery charge')),
        TextField(controller: paid, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Paid')),
        const SizedBox(height: 12),
        Text('Subtotal: ৳${inv.subtotal.toStringAsFixed(2)}'),
        Text('Grand Total: ৳${inv.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('Due: ৳${inv.due.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: items.isEmpty ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => PreviewPage(inv: buildInvoice()))),
          icon: const Icon(Icons.visibility), label: const Text('Preview Invoice'),
        ),
      ]),
    );
  }
}

class PreviewPage extends StatelessWidget {
  final InvoiceData inv;
  const PreviewPage({super.key, required this.inv});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Preview')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Center(child: Text('SafwanTech', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          const Center(child: Text('CCTV SOLUTION')),
          const SizedBox(height: 8),
          Text('Invoice: ${inv.invoiceNo}'),
          Text('Date: ${DateFormat('dd-MM-yyyy hh:mm a').format(inv.date)}'),
          Text('Customer: ${inv.customerName}'),
          Text('Mobile: ${inv.customerMobile}'),
          if (inv.customerAddress.isNotEmpty) Text('Address: ${inv.customerAddress}'),
          const Divider(),
          ...inv.items.map((i) => ListTile(contentPadding: EdgeInsets.zero, title: Text(i.name), subtitle: Text('${i.qty} × ৳${i.unitPrice.toStringAsFixed(2)}'), trailing: Text('৳${i.total.toStringAsFixed(2)}'))),
          const Divider(),
          Text('Subtotal: ৳${inv.subtotal.toStringAsFixed(2)}'),
          Text('Discount: ৳${inv.discount.toStringAsFixed(2)}'),
          Text('Delivery: ৳${inv.delivery.toStringAsFixed(2)}'),
          Text('Grand Total: ৳${inv.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Paid: ৳${inv.paid.toStringAsFixed(2)}'),
          Text('Due: ৳${inv.due.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ]))),
        const SizedBox(height: 8),
        FilledButton.icon(onPressed: () => PrintService.printA4TwoCopies(inv), icon: const Icon(Icons.print), label: const Text('Print A4 — 2 Copies')),
        OutlinedButton.icon(onPressed: () => PrintService.sharePdf(inv), icon: const Icon(Icons.picture_as_pdf), label: const Text('Share PDF')),
      ]),
    );
  }
}

class CompanyPage extends StatelessWidget {
  const CompanyPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Company Profile')),
    body: const Padding(padding: EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('SafwanTech', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      Text('CCTV SOLUTION'),
      SizedBox(height: 16),
      Text('Phone: 01677316296'),
      Text('Address: Jatrabari, Dhaka-1236'),
      Text('Email: safwantechbd@gmail.com'),
      Text('Website: www.safwantech.com'),
    ])),
  );
}
