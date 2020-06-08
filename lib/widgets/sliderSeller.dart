import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testonetest/scoped_models/main.dart';
import 'package:testonetest/utilities/database_helper.dart';
import 'package:testonetest/widgets/ui_elements/logout_list_tile.dart';

Widget BuildSideDrawerSeller(BuildContext context) {
  return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
    return Drawer(
        child: Column(children: <Widget>[
      AppBar(title: Text('Choose'), automaticallyImplyLeading: false),
       ListTile(
          leading: Icon(Icons.shop),
          title: Text('All Products'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/');
          }),
      ListTile(
          leading: Icon(Icons.shop),
          title: Text('Manage Products'),
          onTap: () async{
           await model.fetchCategeriesForAddProduct();
            Navigator.pushReplacementNamed(context, '/admin');
          }),
      Divider(height: 2.0),
      ListTile(
          leading: Icon(Icons.shop),
          title: Text('Orders'),
          onTap: () async {
            var dbs = DatabaseHelper();
            var userid = await SharedPreferences.getInstance();
            var data = await dbs.getOrdersForSeller(userid.getInt('id'));
            // print(data);
            model.setMyOrder(data);
            Navigator.pushReplacementNamed(context, '/orders');
          }),
      Divider(height: 2.0),
      LogoutListTile(),
    ]));
  });
}
