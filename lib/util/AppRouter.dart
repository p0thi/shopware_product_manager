import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/pages/AuthPage.dart';
import 'package:flutter_app/widgets/pages/CreateProductPage.dart';
import 'package:flutter_app/widgets/pages/ImageViewer.dart';

class AppRouter {
  static final AppRouter _instance = new AppRouter._internal();
  final Router _router = new Router();

  factory AppRouter() => _instance;

  AppRouter._internal();

  Router router() => _router;

  void configureRoutes() {
    var duplicateProductHandler = new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return CreateProductPage(int.parse(params["id"][0]), true);
    });
    var editProductHandler = new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return CreateProductPage(int.parse(params["id"][0]), false);
    });
    var authHandler = new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new AuthPage(null);
    });
    _router.define("/duplicate-product/:id", handler: duplicateProductHandler);
    _router.define("/edit-product/:id", handler: editProductHandler);
    _router.define("/auth", handler: authHandler);
  }
}