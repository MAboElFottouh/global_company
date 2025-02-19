part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const HOME = '/home';
  static const LOGIN = '/login';
  static const SUPER_ADMIN = '/super-admin';
  static const ADD_ADMIN = '/add-admin';
  static const MANAGE_ADMINS = '/manage-admins';
  static const SETTINGS = '/settings';
  static const ADD_LINE = '/add-line';
  static const MANAGE_LINES = '/manage-lines';
  static const ADD_CUSTOMER = '/add-customer';
  static const MANAGE_CUSTOMERS = '/manage-customers';
  static const EDIT_CUSTOMER = '/edit-customer';
  static const ADD_PRODUCT = '/add-product';
  static const MANAGE_PRODUCTS = '/manage-products';
  static const EDIT_PRODUCT = '/edit-product';
  static const REVIEW_CUSTOMERS = '/review-customers';
  static const CUSTOMERS_MENU = '/customers-menu';
  static const LINES_MENU = '/lines-menu';
  static const PRODUCTS_MENU = '/products-menu';
  static const ADMINS_MENU = '/admins-menu';
  static const ADD_PURCHASES = '/add-purchases';
  static const MANAGE_PURCHASES = '/manage-purchases';
  static const PURCHASES_MENU = '/purchases-menu';
  static const INVENTORY = '/inventory';
  static const ADD_DELEGATE = '/add-delegate';
  static const MANAGE_DELEGATES = '/manage-delegates';
  static const START_LINE = '/start-line';
  static const REORDER_LINES = '/reorder-lines';
  static const LINE_CUSTOMERS = '/line-customers';
  static const LINE_CUSTOMERS_REORDER = '/line-customers-reorder';
  static const DELEGATE_DELIVERY = '/delegate-delivery';
  static const DELEGATE_PRODUCTS = '/delegate-products';
  static const DELEGATE_DELIVERY_FORM = '/delegate-delivery-form';
  static const CUSTOMER_SALE = '/customer-sale';
  static const INVOICE_PAYMENT = '/invoice-payment';
  static const SALES = '/sales';
  static const INVOICE_DETAILS = '/invoice-details';
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const SETTINGS = '/settings';
  static const CUSTOMERS_MENU = '/customers-menu';
  static const PURCHASES_MENU = '/purchases-menu';
  static const PRODUCTS_MENU = '/products-menu';
  static const INVENTORY = '/inventory';
  static const LINES_MENU = '/lines-menu';
  static const MANAGE_DELEGATES = '/manage-delegates';
  static const ADMINS_MENU = '/admins-menu';
  static const START_LINE = '/start-line';
  static const REORDER_LINES = '/reorder-lines';
  static const LINE_CUSTOMERS = '/line-customers';
  static const LINE_CUSTOMERS_REORDER = '/line-customers-reorder';
  static const DELEGATE_DELIVERY = '/delegate-delivery';
  static const DELEGATE_PRODUCTS = '/delegate-products';
  static const DELEGATE_DELIVERY_FORM = '/delegate-delivery-form';
}
