import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/payment_model.dart';
import '../services/database_service.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/glass_container.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final String orgId;
  final String studentUid;

  const PaymentHistoryScreen({
    super.key,
    required this.orgId,
    required this.studentUid,
  });

  IconData _getModeIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'card':
      case 'debit card':
      case 'credit card':
        return Icons.credit_card;
      case 'upi':
      case 'gpay':
      case 'phonepe':
        return Icons.qr_code;
      case 'net banking':
      case 'online':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Payment History")),
        body: FutureBuilder<List<PaymentModel>>(
          future: dbService.getPayments(orgId, studentUid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48.r,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Error loading payments",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      color: Colors.white38,
                      size: 64.r,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "No payment history found",
                      style: AppTextStyles.body.copyWith(color: Colors.white38),
                    ),
                  ],
                ),
              );
            }

            final payments = snapshot.data!;

            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: payments.length,
              separatorBuilder: (_, __) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final payment = payments[index];
                return GlassContainer(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      // Mode Icon
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryAccent.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          _getModeIcon(payment.mode),
                          color: AppColors.primaryAccent,
                          size: 24.r,
                        ),
                      ),
                      SizedBox(width: 16.w),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Paid via ${payment.mode}",
                              style: AppTextStyles.title.copyWith(
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(payment.date, style: AppTextStyles.bodySmall),
                            if (payment.referenceId.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text(
                                "Ref: ${payment.referenceId}",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white38,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "₹${payment.amount.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Success",
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
