import 'dart:convert';
import 'package:flutter/material.dart';
import "package:scoped_model/scoped_model.dart";
import 'package:testonetest/pages/detailsOrder.dart';
import 'package:testonetest/scoped_models/main.dart';
import 'package:testonetest/widgets/sliderSeller.dart';

class Orders extends StatefulWidget {
  static final String route = "Orders-route";

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return OrdersState();
  }
}

class OrdersState extends State<Orders> {
  Widget generateCart(var d) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white12,
            border: Border(
              bottom: BorderSide(color: Colors.grey[100], width: 1.0),
              top: BorderSide(color: Colors.grey[100], width: 1.0),
            )),
        height: 120.0,
        child: Row(
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              height: 100.0,
              width: 100.0,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 5.0)
                  ],
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0)),
                  image: DecorationImage(
                      image: MemoryImage(base64Decode(d['image'])),
                      fit: BoxFit.fill)),
            ),
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(top: 10.0, left: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          d['title'],
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15.0),
                        ),
                      ),
                      Container(
                        // margin: const EdgeInsets.only(top: 50),
                        child: RaisedButton(
                            onPressed: () async{
                            var data = {"order_id":d['order_id'],"name":d['name'],"product_name":d['title'],"Address_lane":d['addressline']};
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailsOrder(data:data,)));
                            },
                            child: Text('Details'),
                            textColor: Colors.white),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text("Price ${(d['price'] * d['quantity']).toString()}"),
                  Text("quantity :  ${d['quantity']}"),
                  Text("Name :  ${d['name']}"),
                  Text("City :  ${d['city']}"),
                  // Text("Quantity ${d.quantity.toString()}"),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        drawer: BuildSideDrawerSeller(context),
        appBar: AppBar(
          elevation: 0.0,
          title: Text("Orders"),
        ),
        backgroundColor: Colors.white,
        body: Container(
          decoration: BoxDecoration(
              border:
                  Border(top: BorderSide(color: Colors.grey[300], width: 1.0))),
          child: ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
              return Column(
                children: <Widget>[
                  ListView(
                    shrinkWrap: true,
                    children:
                        model.myOrder.map((d) => generateCart(d)).toList(),
                  ),
                ],
              );
            },
          ),
        ));
  }
}
