import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/repositories/user_repository.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';
import 'package:guardiao_cliente/utils/strategy_load_screen.dart';

class OtpController extends GetxController {
  TextEditingController otpController = TextEditingController();

  final UserRepository _userRepository = UserRepository();

  RxString countryCode = "".obs;
  RxString phoneNumber = "".obs;
  RxString verificationId = "".obs;

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      countryCode.value = argumentData['countryCode'];
      phoneNumber.value = argumentData['phoneNumber'];
      verificationId.value = argumentData['verificationId'];
    }
    update();
  }

  verifyCode() async {
    if (otpController.value.text.length == 6) {
      // Exibe o loader
      isLoading.value = true;

      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId.value,
          smsCode: otpController.value.text,
        );

        // Tentativa de login
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        var userLogin = await _userRepository.saveLoginInfo(userCredential, userCredential.user!);

        if (userLogin != null) {
          Preferences.setString('userId', userLogin.uid!);
          if(userLogin.companyId != null) {
            Preferences.setString('companyId', userLogin.companyId!);
          }
          StrategyLoadScreen.validateAccess();
        } else {
          SnackbarCustom.showError('Usuário não encontrado após login com Google.');
        }
      } on FirebaseAuthException catch (e) {
        // Captura erros do Firebase e exibe o snackbar
        hideLoader();
        handleFirebaseAuthError(e);
      } catch (e) {
        // Captura outros erros e exibe o snackbar
        hideLoader();
        SnackbarCustom.showError("Ocorreu um erro inesperado. Tente novamente mais tarde.");
        print('Erro inesperado: $e');
      } finally {
        isLoading.value = false;
      }
    } else {
      SnackbarCustom.showInfo("Por favor, insira um código OTP de 6 dígitos.");
    }
  }

  void handleFirebaseAuthError(FirebaseAuthException e) {
    String errorMessage;

    switch (e.code) {
      case 'invalid-verification-code':
        errorMessage = "O código de verificação está incorreto. Por favor, tente novamente.";
        break;
      case 'user-disabled':
        errorMessage = "Este usuário foi desativado. Entre em contato com o suporte.";
        break;
      case 'operation-not-allowed':
        errorMessage = "A autenticação com número de telefone não está habilitada.";
        break;
      case 'network-request-failed':
        errorMessage = "Sem conexão com a internet. Verifique sua conexão e tente novamente.";
        break;
      case 'too-many-requests':
        errorMessage = "Muitas tentativas de login. Por favor, tente novamente mais tarde.";
        break;
      case 'session-expired':
        errorMessage = "A sessão de verificação expirou. Solicite um novo código OTP.";
        break;
      default:
        errorMessage = "Ocorreu um erro ao verificar o código. Por favor, tente novamente.";
    }

    // Exibe a mensagem no Snackbar
    Get.snackbar(
      "Erro de autenticação",
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
    );

    print('FirebaseAuthException: ${e.code} - ${e.message}');
  }

  // Remove o Loader
  void hideLoader() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  @override
  void dispose() {
    super.dispose();

    otpController.dispose();
  }
}
