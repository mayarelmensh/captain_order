class EndPoints{
  ///Auth
 static const String Login = '/parent/sign_in';

 /// Orders endpoints
 static const String orders = '/waiter/orders';
 static const String orderStatus = '/waiter/orders/status';
 static const String getLocationsList  = '/captain/selection_lists';
 static const String getProductList  = '/captain/lists';

 /// Helper methods
 static String getOrderStatusUrl(int orderId) => '$orderStatus/$orderId';
 static String getOrderUrl(int orderId) => '$orders/$orderId';

}