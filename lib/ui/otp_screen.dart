import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/otp_controller.dart';
import 'package:guardiao_cliente/themes/button_them.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    final OtpController controller = Get.put(
        OtpController()); // Instancia via GetX

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08, // Margem responsiva
                  vertical: screenHeight * 0.04,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🔹 Logo
                    Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.02),
                      child: Image.asset(
                        theme.brightness == Brightness.dark
                            ? "assets/images/logo.png"
                            : "assets/images/logo_light.png",
                        width: screenWidth * 0.5, // 50% da largura da tela
                        height: screenHeight * 0.18, // 18% da altura da tela
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    // 🔹 Título
                    Text(
                      "Verifique seu número".tr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // 🔹 Subtítulo
                    Obx(() =>
                        Text(
                          "Enviamos um código de verificação para o número\n${controller
                              .countryCode.value +
                              controller.phoneNumber.value}"
                              .tr,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        )),
                    SizedBox(height: screenHeight * 0.05),

                    // 🔹 Campo OTP
                    PinCodeTextField(
                      length: 6,
                      appContext: context,
                      keyboardType: TextInputType.number,
                      pinTheme: PinTheme(
                        fieldHeight: screenWidth * 0.12,
                        fieldWidth: screenWidth * 0.12,
                        activeColor: theme.colorScheme.primary,
                        selectedColor: theme.colorScheme.secondary,
                        inactiveColor: theme.colorScheme.outline,
                        activeFillColor: theme.colorScheme.surfaceContainerHighest,
                        selectedFillColor: theme.colorScheme.secondaryContainer,
                        inactiveFillColor: theme.colorScheme.surfaceContainerHighest,
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enableActiveFill: true,
                      cursorColor: theme.colorScheme.primary,
                      controller: controller.otpController,
                      onCompleted: (value) {},
                      onChanged: (value) {},
                    ),
                    SizedBox(height: screenHeight * 0.05),

                    // 🔹 Botão "Verificar"
                    ButtonThem.buildButton(
                      context,
                      title: "Verificar".tr,
                      onPress: () async {
                        await controller.verifyCode();
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}