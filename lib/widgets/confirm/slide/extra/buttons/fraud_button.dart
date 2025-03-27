import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FraudButton extends StatelessWidget {
  const FraudButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFC42121),
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
      child: Stack(
        children: [
          // Centreret tekst
          const Align(
            alignment: Alignment(-0.15, 0), // Forskyd teksten lidt til venstre
            child: Text(
              "Attempted fraud",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Thumb fastgjort til højre side
          Positioned(
            right: 1,
            top: 1,
            bottom: 1,
            child: Material(
              elevation: 0,
              color: const Color(0xFFC42121),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              child: Container(
                width: 60,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
                child: SvgPicture.asset(
                  'assets/images/confirmation/fraud.svg',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
