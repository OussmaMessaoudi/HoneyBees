import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:share2cash/fireStoreServices.dart';

class CardEntryPage extends StatefulWidget {
  final FirestoreService firestoreService;
  const CardEntryPage({Key? key, required this.firestoreService})
    : super(key: key);

  @override
  State<CardEntryPage> createState() => _CardEntryPageState();
}

class _CardEntryPageState extends State<CardEntryPage> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  void onValidatePress() {
    if (_formKey.currentState?.validate() == true &&
        cardNumber.isNotEmpty &&
        expiryDate.isNotEmpty &&
        cvvCode.isNotEmpty) {
      final email = _emailCtrl.text.trim();
      final amount = double.tryParse(_amountCtrl.text.trim());
      if (amount != null) {
        widget.firestoreService.recordPayment(email, amount).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              elevation: null,
              content: Text('Card details validated and logged'),
            ),
          );
          Navigator.of(context).pop();
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill valid card data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Card Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CreditCardForm(
              formKey: _formKey,
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              onCreditCardModelChange: (model) {
                setState(() {
                  cardNumber = model.cardNumber;
                  expiryDate = model.expiryDate;
                  cardHolderName = model.cardHolderName;
                  cvvCode = model.cvvCode;
                  isCvvFocused = model.isCvvFocused;
                });
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) =>
                  v != null && v.contains('@') ? null : 'Enter valid email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Amount'),
              validator: (v) => v != null && double.tryParse(v) != null
                  ? null
                  : 'Enter valid amount',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onValidatePress,
              child: const Text('Validate & Log'),
            ),
          ],
        ),
      ),
    );
  }
}
