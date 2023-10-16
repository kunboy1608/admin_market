import 'dart:collection';

import 'package:admin_market/entity/product.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCubit extends Cubit<Map<String, Product>> {
  ProductCubit(super.initialState);

  void replaceState(Map<String, Product> map) {
    state.clear();
    state.addAll(map);
    sortByName();
  }

  void addOrUpdateIfExist(Product p) => emit(Map.of(state..addAll({p.id!: p})));
  void addOrUpdateIfExistAll(List<Product> products) {
    for (final p in products) {
      state[p.id!] = p;
    }
    emit(Map.of(state));
  }

  void remove(Product p) => removeById(p.id ?? "");

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

  Map<String, Product> currentState() => state;
}
