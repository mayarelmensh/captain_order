abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderSuccess extends OrderState {}

class OrderDetailsLoading extends OrderState {}

class OrderDetailsSuccess extends OrderState {}

class OrderPickupLoading extends OrderState {}

class OrderPickupSuccess extends OrderState {}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}