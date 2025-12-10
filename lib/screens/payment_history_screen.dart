import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/payment_model.dart';
import '../services/database_service.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final String orgId;
  final String studentUid;

  const PaymentHistoryScreen({
    super.key,
    required this.orgId,
    required this.studentUid,
  });

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(title: const Text("Payment History")),
      body: FutureBuilder<List<PaymentModel>>(
        future: dbService.getPayments(orgId, studentUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No payment history found"));
          }

          final payments = snapshot.data!;

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: payments.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final payment = payments[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            payment.date,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            "₹${payment.amount.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Mode: ${payment.mode}",
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          if (payment.referenceId.isNotEmpty)
                            Text(
                              "Ref: ${payment.referenceId}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
