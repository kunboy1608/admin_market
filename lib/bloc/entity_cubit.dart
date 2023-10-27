import 'package:admin_market/entity/entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class EntityCubit<T extends Entity> extends Cubit<Map<String, T>> {
  EntityCubit(super.initialState);

  void replaceState(Map<String, T> map) {
    state.clear();
    state.addAll(map);
  }

  void addOrUpdateIfExist(T e) => emit(Map.of(state..addAll({e.id!: e})));
  void addOrUpdateIfExistAll(List<T> products) {
    for (final e in products) {
      state[e.id!] = e;
    }
    emit(Map.of(state));
  }

  void remove(T e) => removeById(e.id ?? "");

  void removeById(String id) {
    state.remove(id);
    emit(Map.of(state));
  }

  void removeAll(List<T> list) {
    for (var element in list) {
      state.remove(element.id);
    }
    emit(Map.of(state));
  }

  Map<String, T> currentState() => state;
}
