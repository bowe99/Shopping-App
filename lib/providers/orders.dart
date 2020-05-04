import 'dart:convert';

import 'package:app_4/providers/cart.dart';
import 'package:app_4/providers/product.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final String dateTime;

  OrderItem({
    @required this.amount,
    @required this.dateTime,
    @required this.id,
    @required this.products,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url = 'https://shop-app-8139c.firebaseio.com/orders.json';
    final orderDate = DateFormat('dd/MM/yyyy hh:mm').format(DateTime.now());

    //TODO implement way to add a list to Firebase

    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': orderDate,
          'products': cartProducts
              .map((cartProduct) => {
                    'id': cartProduct.id,
                    'title': cartProduct.title,
                    'price': cartProduct.price,
                    'quantity': cartProduct.quantity,
                  })
              .toList(),
        }));
    _orders.insert(
        0,
        OrderItem(
          amount: total,
          dateTime: orderDate,
          id: json.decode(response.body)['name'],
          products: cartProducts,
        ));
    print(_orders.elementAt(0).id);
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    const url = 'https://shop-app-8139c.firebaseio.com/orders.json';
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if(extractedData == null){
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
        amount: orderData['amount'],
        dateTime: orderData['dateTime'],
        id: orderId,
        products: (orderData['products'] as List)
            .map((item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title'],
                ))
            .toList(),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
    print(json.decode(response.body));
  }
}
