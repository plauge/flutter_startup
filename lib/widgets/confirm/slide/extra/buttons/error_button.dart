import 'package:flutter/material.dart';

class ErrorButton extends StatelessWidget {
  const ErrorButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF656565),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0.5,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "Timed out",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
