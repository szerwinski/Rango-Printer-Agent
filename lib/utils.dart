import 'package:decimal/decimal.dart';
import 'types/http_response.dart';

class OrderUtils {
  static String formatCurrency(double amount) {
    return 'R\$${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }


  static Decimal getPriceForOrderItem(Datum orderItem) {
    var totalValueForOptions = 0.0;
    var menuItem = (orderItem.menuItem as MenuItem);
    orderItem.options?.forEach((element) {
      totalValueForOptions += ((element.price ?? 0) * (element.quantity ?? 0));
    });

    var itemPrice =
        menuItem.freePrice == true ? orderItem.freePrice : menuItem.price;
    if (menuItem.byWeight == true) {
      itemPrice = (menuItem.price ?? 0) / 1000000;
    }

    return Decimal.parse(
        (((itemPrice ?? 0) + totalValueForOptions) * (orderItem.quantity ?? 0)).toString());
  }
}