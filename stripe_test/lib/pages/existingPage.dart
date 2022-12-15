import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:stripe_test/services/paymentService.dart';

class ExistingCardsPage extends StatefulWidget {
  @override
  _ExistingCardsPageState createState() => _ExistingCardsPageState();
}

class _ExistingCardsPageState extends State<ExistingCardsPage> {
  List cards = [
    {
      'cardNumber': '4242424242424242',
      'expiryDate': '04/24',
      'cardHolderName': 'Testing Cool',
      'cvvCode': '424',
      'showBackView': false,
    },
    {
      'cardNumber': '5555555555554444',
      'expiryDate': '04/23',
      'cardHolderName': 'Tracer',
      'cvvCode': '123',
      'showBackView': false,
    }
  ];

  payViaExistingCard(BuildContext context, card) async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(
      message: 'Please Wait'
    );
    await dialog.show();
    var expiryArray = card['expiryDate'].split('/');
    CreditCard creditCard = CreditCard(
        expMonth: int.parse(expiryArray[0]),
        expYear: int.parse(expiryArray[1]),
        number: card['cardNumber'],
        name: card['cardHolderName'],
        cvc: card['cvv']);
    var response = await StripeService.payViaExisitingCard(
        amount: '2500', currency: 'INR', card: creditCard);
    await dialog.hide();
    if (response.success == true) {
      Scaffold.of(context)
          .showSnackBar(
            SnackBar(
              content: Text(response.message),
              duration: Duration(milliseconds: 1200),
            ),
          )
          .closed
          .then((_) => Navigator.pop(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Existing Card'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            itemBuilder: (BuildContext context, int index) {
              var card = cards[index];
              return InkWell(
                onTap: () {
                  payViaExistingCard(context, card);
                },
                child: CreditCardWidget(
                  cardNumber: card['cardNumber'],
                  expiryDate: card['expiryDate'],
                  cardHolderName: card['cardHolderName'],
                  width: MediaQuery.of(context).size.width / 1.25,
                  cvvCode: card['cvvCode'],
                  showBackView:
                      false, //true when you want to show cvv(back) view
                ),
              );
            }),
      ),
    );
  }
}
