import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:stripe_test/services/paymentService.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  onItemPress(BuildContext context, int index) async {
    switch(index) {
      case 0:
        payViaNewCard(context);
        print("hi");
        //payViaNewCard(context);
        break;
      case 1:
        Navigator.pushNamed(context, '/existing-cards');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    StripeService.init();
  }


  payViaNewCard(BuildContext context) async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(
        message: 'Please Wait'
    );
    await dialog.show();

    var response = await StripeService.payWithNewCard(amount: '150', currency: 'INR');
    await dialog.hide();
    if(response.success == true) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(response.message), duration: Duration(milliseconds: 1200),));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(response.message), duration: Duration(milliseconds: 3000),));
    }
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home Page'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.location_on_outlined),),
              Tab(icon: Icon(Icons.delivery_dining),),
              Tab(icon: Icon(Icons.credit_card),),
              Tab(icon: Icon(Icons.list),),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Text("Location Selection"),),
            Center(child: Text("Delivery Option Selection"),),
            Container(
              padding: EdgeInsets.all(20),
              child: ListView.separated(itemBuilder: (context, index) {
                Icon icon;
                Text text;
                switch (index) {
                  case 0:
                    icon = Icon(Icons.add);
                    text = Text("Pay via new card");
                    break;
                  case 1:
                    icon = Icon(Icons.credit_card);
                    text = Text("Pay via existing card");
                    break;
                }
                return InkWell(
                  onTap: () {
                    onItemPress(context, index);
                  },
                  child: ListTile(
                    title: text,
                    leading: icon,
                  ),
                );
              }, separatorBuilder: (context, index) {
                return Divider(color: Colors.grey,);
              }, itemCount: 2),
            ),
            Center(child: Text("Order Summary"),),
          ],
        ),
      ),
    );
  }
}
