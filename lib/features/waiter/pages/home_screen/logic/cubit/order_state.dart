import '../model/order_models.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderSuccess extends OrderState {
  final OrderModels orders;
  OrderSuccess(this.orders);
}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}