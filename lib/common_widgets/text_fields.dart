import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Field extends StatelessWidget {
  const Field({
    super.key,
    required this.labelText,
    required this.validator,
    required this.controller,
    this.obscureText = false,
  });

  final String labelText;
  final String? Function(dynamic value) validator;
  final bool obscureText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w),
            child:
                Text(labelText, style: Theme.of(context).textTheme.bodySmall),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller,
            cursorHeight: 38.h,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
            ),
            obscureText: obscureText,
            validator: validator,
          ),
        ],
      ),
    );
  }
}
