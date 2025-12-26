import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.label,
    this.isPassword = false,
    this.validator,
    this.controller, this.isLoginTheme = false,
  });

  final String label;
  final String hint;
  final IconData icon;
  final bool? isPassword;
  final bool? isLoginTheme;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 18),
            Text(
              label,
              style: TextStyle(
                color: Colors.white60,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.start,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF27272A),

              prefixIcon: Icon(icon, color: Colors.white38),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38),

              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: const BorderSide(
                  color: Color(0xFF14355E),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(
                  color: (isLoginTheme!) ? Color(0xFF25BAC1) : Color(0xFF00A63E),
                ),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            validator: validator,
            controller: controller,
            obscureText: isPassword ?? false,
          ),
        ),
      ],
    );
  }
}
