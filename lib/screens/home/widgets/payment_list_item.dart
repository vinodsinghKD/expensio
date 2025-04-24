import 'package:expensio/model/payment.model.dart';
import 'package:expensio/widgets/currency.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/colors.dart';

class PaymentListItem extends StatelessWidget {
  final Payment payment;
  final VoidCallback onTap;

  const PaymentListItem({
    super.key,
    required this.payment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCredit = payment.type == PaymentType.credit;
    final theme = Theme.of(context);
    final Color textColor = isCredit ? ThemeColors.success : ThemeColors.error;
    final Color bgColor = payment.category.color.withOpacity(0.1);
    final Color iconColor = payment.category.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(payment.category.icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyMedium!.color,
                    ),
                    child: Text(payment.category.name, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat("dd MMM yyyy, HH:mm").format(payment.datetime),
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            CurrencyText(
              isCredit ? payment.amount : -payment.amount,
              style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

