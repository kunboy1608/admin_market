import 'dart:collection';

import 'package:admin_market/bloc/entity_cubit.dart';
import 'package:admin_market/entity/product.dart';

class ProductCubit extends EntityCubit<Product> {
  ProductCubit(super.initialState);

  @override
  void replaceState(Map<String, Product> map) {
    state.clear();
    state.addAll(map);
    sortByName();
  }

  void sortByCategory() {
    List<String> sortedKeys = state.keys.toList(growable: false)
      ..sort(
        (a, b) {
          if (state[a]!.categoryId == null) {
            return -1;
          } else {
            if (state[b]!.categoryId == null) {
              return state[a]!.categoryId!;
            } else {
              return state[a]!.categoryId!.compareTo(state[b]!.categoryId!);
            }
          }
        },
      );

    LinkedHashMap<String, Product> sortedMap = LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => state[k]!);

    emit(sortedMap);
  }

  void sortByName() {
    List<String> sortedKeys = state.keys.toList(growable: false)
      ..sort(
        (a, b) {
          if (state[a]!.name == null) {
            return -1;
          } else {
            if (state[b]!.name == null) {
              return state[a]!.name!.compareTo("");
            } else {
              return state[a]!.name!.compareTo(state[b]!.name!);
            }
          }
        },
      );

    LinkedHashMap<String, Product> sortedMap = LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => state[k]!);

    emit(sortedMap);
  }
}
