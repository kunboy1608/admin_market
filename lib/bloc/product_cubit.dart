import 'package:admin_market/entity/product.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCubit extends Cubit<Map<String, Product>> {
  ProductCubit(super.initialState);

  void replaceState(Map<String, Product> map) => emit(map);
  void addOrUpdateIfExist(Product p) => emit(Map.of(state..addAll({p.id!: p})));
  void addOrUpdateIfExistAll(List<Product> products) {
    for (final p in products) {
      state[p.id!] = p;
    }
    emit(Map.of(state));
  }

  void remove(Product p) => (p.id ?? "");

  void removeById(String id) {
    state.remove(id);
    emit(Map.of(state));
  }

  void removeAll(List<Product> list) {
    for (var element in list) {
      state.remove(element.id);
    }
    emit(Map.of(state));
  }

  Map<String, Product> currentState() => state;
}
