class EndPoints{
  ///Auth
 static const String Login = '/parent/sign_in';

 /// Orders endpoints
 static const String orders = '/waiter/orders';
 static const String orderStatus = '/waiter/orders/status'; // للـ pickup

 /// Helper methods
 static String getOrderStatusUrl(int orderId) => '$orderStatus/$orderId';
 static String getOrderUrl(int orderId) => '$orders/$orderId';

}