import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:edupro/infrastructure/theme/theme_helper.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/auth.controller.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.fromLTRB(25, 50, 25, 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              GestureDetector(
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(width: 5, color: Colors.white),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(5, 5),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 50.0,
                    backgroundImage: AssetImage("assets/images/logo.png"),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildForm(context),
              const SizedBox(height: 30),
              _buildRegistrationLink(),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: controller.formKey.value,
      child: Column(
        children: [
          _buildEmailField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 15),
          _buildTermsCheckbox(context),
          const SizedBox(height: 20),
          _buildLoginButton(context),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
      child: TextFormField(
        onSaved: (val) => controller.userInfo.value.emailAddress = val!,
        decoration: ThemeHelper().textInputDecoration(
          "E-mail address",
          "Enter your email",
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (val) {
          if ((val!.isNotEmpty) &&
              !RegExp(
                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
              ).hasMatch(val)) {
            return "Enter a valid email address";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
      child: TextFormField(
        onSaved: (val) => controller.userInfo.value.password = val!,
        obscureText: true,
        decoration: ThemeHelper().textInputDecoration(
          "Password*",
          "Enter your password",
        ),
        validator: (val) {
          if (val!.isEmpty) {
            return "Please enter your password";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTermsCheckbox(BuildContext context) {
    return FormField<bool>(
      builder: (state) {
        return Column(
          children: [
            Obx(
              () => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  "I accept all terms and conditions.",
                  style: TextStyle(color: Colors.grey),
                ),
                value: controller.checkboxValue.value,
                onChanged: (value) {
                  controller.checkboxValue.value = value!;
                  state.didChange(value);
                },
              ),
            ),
            if (state.hasError)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
      validator: (value) {
        if (!controller.checkboxValue.value) {
          return 'You need to accept terms and conditions';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Container(
      decoration: ThemeHelper().buttonBoxDecoration(context),
      child: ElevatedButton(
        style: ThemeHelper().buttonStyle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
          child: Text(
            "Log In".toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        onPressed: () {
          if (controller.formKey.value.currentState!.validate()) {
            controller.formKey.value.currentState!.save();
            controller.logInAsAppUser(
              controller.userInfo.value.emailAddress!,
              controller.userInfo.value.password!,
            );
          }
        },
      ),
    );
  }

  Widget _buildRegistrationLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'have_an_account_already',
          style: TextStyle(color: Colors.black),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => Get.toNamed("/signup"),
          child: Text(
            'Registration',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}
