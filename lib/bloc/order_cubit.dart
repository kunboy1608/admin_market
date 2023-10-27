import 'package:admin_market/bloc/entity_cubit.dart';
import 'package:admin_market/entity/order.dart';

class OrderCubit extends EntityCubit<Order> {
  OrderCubit(super.initialState);

  List<Order> getOrdersByStatus(int status) {
    List<Order> list = [];
    state.forEach((key, value) {
      if (value.status == status) {
        list.add(value);
      }
    });

    return list;
  }
}
