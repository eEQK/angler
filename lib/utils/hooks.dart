import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

AsyncSnapshot<T> useMemoFuture<T>(
  Future<T> Function() futureBuilder, [
  List<Object> keys = const [],
]) =>
    useFuture(useMemoized(() => futureBuilder(), keys));
