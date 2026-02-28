import 'package:flutter_test/flutter_test.dart';
import 'package:upi_alert/services/regex_parser.dart';

void main() {
  group('NotificationParser extractReceivedAmount', () {
    test('extracts amount with rupees symbol perfectly aligned', () {
      final amount = NotificationParser.extractReceivedAmount(
        "Payment Received",
        "Received ₹100 from John",
      );
      expect(amount, "100");
    });

    test('extracts amount with space after rupees symbol', () {
      final amount = NotificationParser.extractReceivedAmount(
        "Payment Received",
        "Received ₹ 50 from John",
      );
      expect(amount, "50");
    });

    test('extracts amount with commas', () {
      final amount = NotificationParser.extractReceivedAmount(
        "Payment Received",
        "Received ₹1,200.50 from John",
      );
      expect(amount, "1200.50");
    });

    test('extracts from title instead of body', () {
      final amount = NotificationParser.extractReceivedAmount(
        "₹500 received",
        "from John",
      );
      expect(amount, "500");
    });

    test('handles Rs. format', () {
      final amount = NotificationParser.extractReceivedAmount(
        "Credit Alert",
        "Rs. 25.50 received successfully",
      );
      expect(amount, "25.50");
    });

    test('ignores messages without received keywords', () {
      final amount = NotificationParser.extractReceivedAmount(
        "Money Sent",
        "You paid ₹50 to John",
      );
      expect(amount, isNull);
    });

    test('ignores promotional notifications', () {
      final amount = NotificationParser.extractReceivedAmount(
        "New Offer",
        "Get ₹500 cashback today!",
      );
      expect(amount, isNull);
    });
  });
}
