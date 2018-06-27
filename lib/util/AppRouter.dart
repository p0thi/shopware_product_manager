import 'package:diKapo/widgets/pages/AuthPage.dart';
import 'package:diKapo/widgets/pages/CreateProductPage.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static final AppRouter _instance = new AppRouter._internal();
  final Router _router = new Router();

  factory AppRouter() => _instance;

  AppRouter._internal();

  Router router() => _router;

  void configureRoutes() {
    var duplicateProductHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return CreateProductPage(params["id"][0].toString(), true);
    });
    var editProductHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return CreateProductPage(params["id"][0].toString(), false);
    });
    var authHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new AuthPage(null);
    });
    _router.define("/duplicate-product/:id", handler: duplicateProductHandler);
    _router.define("/edit-product/:id", handler: editProductHandler);
    _router.define("/auth", handler: authHandler);
  }
}
