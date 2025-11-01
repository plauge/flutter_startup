import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final FocusNode? focusNode;
  final bool readOnly;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final Function()? onTap;
  final String? errorText;
  final String? initialValue;
  final Iterable<String>? autofillHints;
  final bool showClearButton;

  const CustomTextFormField({
    Key? key,
    this.controller,
    this.keyboardType,
    this.validator,
    this.autovalidateMode,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.focusNode,
    this.readOnly = false,
    this.maxLines = 1,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.errorText,
    this.initialValue,
    this.autofillHints,
    this.showClearButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Build clear button if showClearButton is true and controller has text
    Widget? effectiveSuffixIcon = suffixIcon;
    if (showClearButton && controller != null) {
      effectiveSuffixIcon = AnimatedBuilder(
        animation: controller!,
        builder: (context, child) {
          if (controller!.text.isEmpty) {
            return suffixIcon ?? const SizedBox.shrink();
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (suffixIcon != null) suffixIcon!,
              IconButton(
                key: const Key('text_field_clear_button'),
                icon: const Icon(
                  Icons.clear,
                  color: Color(0xFF656565),
                  size: 20,
                ),
                onPressed: () {
                  controller?.clear();
                  // Remove focus after clearing
                  focusNode?.unfocus();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
          obscureText: obscureText,
          focusNode: focusNode,
          readOnly: readOnly,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onTap: onTap,
          autofillHints: autofillHints,
          style: const TextStyle(
            color: Color(0xFF656565),
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: labelText ?? hintText,
            errorText: null,
            errorStyle: const TextStyle(height: 0),
            suffixIcon: effectiveSuffixIcon,
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            constraints: const BoxConstraints(minHeight: 50),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(
                color: Color(0xFF656565),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(
                color: Color(0xFF656565),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(
                color: Color(0xFF656565),
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1,
              ),
            ),
            hintStyle: const TextStyle(
              color: Color(0xFF656565),
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 16),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

// Created: 2024-07-12 17:28
