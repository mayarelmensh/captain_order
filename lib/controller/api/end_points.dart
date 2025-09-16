class EndPoints{
  ///Auth
 static const String Login = '/parent/sign_in';

 /// Orders endpoints
 static const String ordersList = '/waiter/orders';
 static String orderStatus(int orderId) => '/waiter/orders/status/$orderId';
 static String orderItem(int orderId) => '/waiter/orders/order/$orderId';
 static const String baseUrl = 'https://bcknd.food2go.online';



}