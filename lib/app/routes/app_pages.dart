import 'package:get/get.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_view.dart';
import '../modules/super_admin/super_admin_binding.dart';
import '../modules/super_admin/super_admin_view.dart';
import '../modules/add_admin/add_admin_binding.dart';
import '../modules/add_admin/add_admin_view.dart';
import '../modules/manage_admins/manage_admins_binding.dart';
import '../modules/manage_admins/manage_admins_view.dart';
import '../modules/settings/settings_binding.dart';
import '../modules/settings/settings_view.dart';
import '../modules/add_line/add_line_binding.dart';
import '../modules/add_line/add_line_view.dart';
import '../modules/manage_lines/manage_lines_view.dart';
import '../modules/manage_lines/manage_lines_binding.dart';
import '../modules/add_customer/add_customer_view.dart';
import '../modules/add_customer/add_customer_binding.dart';
import '../modules/manage_customers/manage_customers_view.dart';
import '../modules/manage_customers/manage_customers_binding.dart';
import '../modules/edit_customer/edit_customer_view.dart';
import '../modules/edit_customer/edit_customer_binding.dart';
import '../modules/add_product/add_product_view.dart';
import '../modules/add_product/add_product_binding.dart';
import '../modules/manage_products/manage_products_view.dart';
import '../modules/manage_products/manage_products_binding.dart';
import '../modules/edit_product/edit_product_view.dart';
import '../modules/edit_product/edit_product_binding.dart';
import '../modules/review_customers/review_customers_view.dart';
import '../modules/review_customers/review_customers_binding.dart';
import '../modules/customers_menu/customers_menu_view.dart';
import '../modules/lines_menu/lines_menu_view.dart';
import '../modules/products_menu/products_menu_view.dart';
import '../modules/admins_menu/admins_menu_view.dart';
import '../modules/add_purchases/add_purchases_view.dart';
import '../modules/add_purchases/add_purchases_binding.dart';
import '../modules/manage_purchases/manage_purchases_view.dart';
import '../modules/manage_purchases/manage_purchases_binding.dart';
import '../modules/purchases_menu/purchases_menu_view.dart';
import '../modules/inventory/inventory_binding.dart';
import '../modules/inventory/inventory_view.dart';
import '../modules/add_delegate/add_delegate_binding.dart';
import '../modules/add_delegate/add_delegate_view.dart';
import '../modules/manage_delegates/manage_delegates_binding.dart';
import '../modules/manage_delegates/manage_delegates_view.dart';
import '../modules/start_line/start_line_view.dart';
import '../modules/start_line/start_line_binding.dart';
import '../modules/reorder_lines/reorder_lines_binding.dart';
import '../modules/reorder_lines/reorder_lines_view.dart';
import '../modules/line_customers/line_customers_binding.dart';
import '../modules/line_customers/line_customers_view.dart';
import '../modules/line_customers/line_customers_controller.dart';
import '../modules/line_customers_reorder/line_customers_reorder_view.dart';
import '../modules/line_customers_reorder/line_customers_reorder_binding.dart';
import '../modules/delegate_delivery/delegate_delivery_view.dart';
import '../modules/delegate_delivery/delegate_delivery_binding.dart';
import '../modules/delegate_delivery_form/delegate_delivery_form_binding.dart';
import '../modules/delegate_delivery_form/delegate_delivery_form_view.dart';
import '../modules/delegate_products/delegate_products_binding.dart';
import '../modules/delegate_products/delegate_products_view.dart';
import '../modules/customer_sale/views/product_selection_view.dart';
import '../modules/customer_sale/customer_sale_binding.dart';
import '../modules/customer_sale/customer_sale_view.dart';
import '../auth/auth_binding.dart';
import '../modules/invoice_payment/invoice_payment_view.dart';
import '../modules/invoice_payment/invoice_payment_binding.dart';
import '../modules/sales/sales_binding.dart';
import '../modules/sales/sales_view.dart';
import '../modules/invoice_details/invoice_details_binding.dart';
import '../modules/invoice_details/invoice_details_view.dart';
import '../modules/customer_returns/customer_returns_binding.dart';
import '../modules/customer_returns/customer_returns_view.dart';

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

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.SUPER_ADMIN,
      page: () => const SuperAdminView(),
      binding: SuperAdminBinding(),
    ),
    GetPage(
      name: Routes.ADD_ADMIN,
      page: () => AddAdminView(),
      binding: AddAdminBinding(),
    ),
    GetPage(
      name: Routes.MANAGE_ADMINS,
      page: () => const ManageAdminsView(),
      binding: ManageAdminsBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.ADD_LINE,
      page: () => const AddLineView(),
      binding: AddLineBinding(),
    ),
    GetPage(
      name: Routes.MANAGE_LINES,
      page: () => const ManageLinesView(),
      binding: ManageLinesBinding(),
    ),
    GetPage(
      name: Routes.ADD_CUSTOMER,
      page: () => const AddCustomerView(),
      binding: AddCustomerBinding(),
    ),
    GetPage(
      name: Routes.MANAGE_CUSTOMERS,
      page: () => const ManageCustomersView(),
      binding: ManageCustomersBinding(),
    ),
    GetPage(
      name: Routes.EDIT_CUSTOMER,
      page: () => const EditCustomerView(),
      binding: EditCustomerBinding(),
    ),
    GetPage(
      name: Routes.ADD_PRODUCT,
      page: () => const AddProductView(),
      binding: AddProductBinding(),
    ),
    GetPage(
      name: Routes.MANAGE_PRODUCTS,
      page: () => const ManageProductsView(),
      binding: ManageProductsBinding(),
    ),
    GetPage(
      name: Routes.EDIT_PRODUCT,
      page: () => const EditProductView(),
      binding: EditProductBinding(),
    ),
    GetPage(
      name: Routes.REVIEW_CUSTOMERS,
      page: () => ReviewCustomersView(
        customers: Get.arguments['customers'],
        onSave: Get.arguments['onSave'],
      ),
      binding: ReviewCustomersBinding(),
    ),
    GetPage(
      name: Routes.CUSTOMERS_MENU,
      page: () => const CustomersMenuView(),
    ),
    GetPage(
      name: Routes.LINES_MENU,
      page: () => const LinesMenuView(),
    ),
    GetPage(
      name: Routes.PRODUCTS_MENU,
      page: () => const ProductsMenuView(),
    ),
    GetPage(
      name: Routes.ADMINS_MENU,
      page: () => const AdminsMenuView(),
    ),
    GetPage(
      name: Routes.ADD_PURCHASES,
      page: () => const AddPurchasesView(),
      binding: AddPurchasesBinding(),
    ),
    GetPage(
      name: Routes.MANAGE_PURCHASES,
      page: () => const ManagePurchasesView(),
      binding: ManagePurchasesBinding(),
    ),
    GetPage(
      name: Routes.PURCHASES_MENU,
      page: () => const PurchasesMenuView(),
    ),
    GetPage(
      name: Routes.INVENTORY,
      page: () => const InventoryView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: Routes.ADD_DELEGATE,
      page: () => const AddDelegateView(),
      binding: AddDelegateBinding(),
    ),
    GetPage(
      name: Routes.MANAGE_DELEGATES,
      page: () => const ManageDelegatesView(),
      binding: ManageDelegatesBinding(),
    ),
    GetPage(
      name: Routes.START_LINE,
      page: () => const StartLineView(),
      binding: StartLineBinding(),
    ),
    GetPage(
      name: Routes.REORDER_LINES,
      page: () => const ReorderLinesView(),
      binding: ReorderLinesBinding(),
    ),
    GetPage(
      name: Routes.LINE_CUSTOMERS,
      page: () => const LineCustomersView(),
      binding: BindingsBuilder(() {
        AuthBinding().dependencies();
        LineCustomersBinding().dependencies();
      }),
    ),
    GetPage(
      name: Routes.LINE_CUSTOMERS_REORDER,
      page: () => const LineCustomersReorderView(),
      binding: LineCustomersReorderBinding(),
    ),
    GetPage(
      name: Routes.DELEGATE_DELIVERY,
      page: () => const DelegateDeliveryView(),
      binding: DelegateDeliveryBinding(),
    ),
    GetPage(
      name: Routes.DELEGATE_PRODUCTS,
      page: () => DelegateProductsView(),
      binding: DelegateProductsBinding(),
    ),
    GetPage(
      name: Routes.DELEGATE_DELIVERY_FORM,
      page: () => const DelegateDeliveryFormView(),
      binding: DelegateDeliveryFormBinding(),
    ),
    GetPage(
      name: Routes.CUSTOMER_SALE,
      page: () => const CustomerSaleView(),
      binding: CustomerSaleBinding(),
    ),
    GetPage(
      name: Routes.INVOICE_PAYMENT,
      page: () => const InvoicePaymentView(),
      binding: InvoicePaymentBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: Routes.SALES,
      page: () => const SalesView(),
      binding: SalesBinding(),
    ),
    GetPage(
      name: Routes.INVOICE_DETAILS,
      page: () => const InvoiceDetailsView(),
      binding: InvoiceDetailsBinding(),
    ),
    GetPage(
      name: '/customer-returns',
      page: () => const CustomerReturnsView(),
      binding: CustomerReturnsBinding(),
    ),
  ];
}
