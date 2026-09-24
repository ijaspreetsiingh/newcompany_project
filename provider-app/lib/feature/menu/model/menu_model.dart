import 'package:flutter/material.dart';

class MenuModel {
  String? icon;
  IconData? iconData;
  String? title;
  String? route;
  String? routeValidation;

  MenuModel({
    this.icon,
    this.iconData,
    required this.title,
    required this.route,
    this.routeValidation,
  });
}
