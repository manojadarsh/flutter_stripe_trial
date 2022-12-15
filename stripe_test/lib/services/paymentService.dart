import 'package:flutter/services.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StripeTransactionResponse {
  String message;
  bool success;

  StripeTransactionResponse({this.message, this.success});
}

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentAPIURL = '${apiBase}/payment_intents';
  static String secret =
      //insert your secret key here
  static Map<String, String> headers = {
    'Authorization': 'Bearer $secret',
    'Content-Type': 'application/x-www-form-urlencoded'
  };
  static init() {
    StripePayment.setOptions(StripeOptions(
        publishableKey:
            "pk_test_51Htry6B4rmQkhb2KZfhj0N01CFzI6r9qGgb7dl8H96ks0GMW7RNcV12dCKedZOKFTLim1b7Sc8iM8IvJZSZ15HhJ00PBquuD8F",
        merchantId: "Test",
        androidPayMode: 'test'));
  }

  static Future<StripeTransactionResponse> payViaExisitingCard({String amount, String currency, card}) async {
    try {
      var paymentMethond = await StripePayment.createPaymentMethod(PaymentMethodRequest(
        card: card,
      ));
      var paymentIntent =
          await StripeService.createPaymentIntent(amount, currency);
      var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
          clientSecret: paymentIntent['client_secret'],
          paymentMethodId: paymentMethond.id));
      //print(jsonEncode(paymentIntent));
      print(response.status);
      if(response.status == 'succeeded') {
        return new StripeTransactionResponse(
            message: 'Transaction of ${amount} succesful', success: true);
      } else {
        return new StripeTransactionResponse(
            message: 'Transaction failed', success: false);
      }
    }
    on PlatformException catch (err) {
      return getPlatformExceptionResult(err);
    }
    catch (err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}', success: false);
    }
  }

  static Future<StripeTransactionResponse> payWithNewCard(
      {String amount, String currency}) async {
    try {
      var paymentMethond = await StripePayment.paymentRequestWithCardForm(
          CardFormPaymentRequest());
      var paymentIntent =
          await StripeService.createPaymentIntent(amount, currency);
      var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
          clientSecret: paymentIntent['client_secret'],
          paymentMethodId: paymentMethond.id));
      //print(jsonEncode(paymentIntent));
      print(response.status);
      if(response.status == 'succeeded') {
        return new StripeTransactionResponse(
            message: 'Transaction of ${amount} succesful', success: true);
      } else {
        return new StripeTransactionResponse(
            message: 'Transaction failed', success: false);
      }
    }
    on PlatformException catch (err) {
      return getPlatformExceptionResult(err);
    }
    catch (err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}', success: false);
    }
  }

  static getPlatformExceptionResult(err) {
    String message = "Something went wrong";
    if (err.code == 'cancelled') {
      message = "Transaction cancelled";
    }

    return new StripeTransactionResponse(
      success: false,
      message: message
    );
  }

  static Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'description' : 'goods and services',

        'currency': currency,
        'receipt_email' : "adarsh.manoj@a3jm.com",
        'payment_method_types[]': 'card'
      };
      print(StripeService.headers);
      var response = await http.post(paymentAPIURL,
          body: body, headers: StripeService.headers);
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
    return null;
  }
}
