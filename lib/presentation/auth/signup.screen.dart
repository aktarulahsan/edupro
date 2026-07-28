import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:edupro/infrastructure/theme/theme_helper.dart';
import 'controllers/signup.controller.dart';

class SignupScreen extends GetView<SignupController> {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text('Registration', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Create your Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
                        
                        // First Name
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            decoration: ThemeHelper().textInputDecoration("First Name", "Enter first name"),
                            validator: (val) => val!.trim().isEmpty ? "Please enter first name" : null,
                            onSaved: (val) => controller.firstName.value = val!.trim(),
                          ),
                        ),
                        const SizedBox(height: 18),
                        
                        // Last Name
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            decoration: ThemeHelper().textInputDecoration("Last Name", "Enter last name"),
                            validator: (val) => val!.trim().isEmpty ? "Please enter last name" : null,
                            onSaved: (val) => controller.lastName.value = val!.trim(),
                          ),
                        ),
                        const SizedBox(height: 18),
                        
                        // Email Address
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: ThemeHelper().textInputDecoration("E-mail address", "Enter your email"),
                            validator: (val) {
                              if (val!.trim().isEmpty) return "Please enter your email";
                              if (!RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(val.trim())) {
                                return "Enter a valid email address";
                              }
                              return null;
                            },
                            onSaved: (val) => controller.email.value = val!.trim(),
                          ),
                        ),
                        const SizedBox(height: 18),
                        
                        // Password
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            obscureText: true,
                            decoration: ThemeHelper().textInputDecoration("Password*", "Enter your password"),
                            validator: (val) {
                              if (val!.isEmpty) return "Please enter password";
                              if (val.length < 6) return "Password must be at least 6 characters";
                              return null;
                            },
                            onSaved: (val) => controller.password.value = val!,
                          ),
                        ),
                        const SizedBox(height: 18),
                        
                        // Mobile Number
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            keyboardType: TextInputType.phone,
                            decoration: ThemeHelper().textInputDecoration("Mobile Number", "Enter phone number"),
                            validator: (val) => val!.trim().isEmpty ? "Please enter mobile number" : null,
                            onSaved: (val) => controller.mobileNumber.value = val!.trim(),
                          ),
                        ),
                        const SizedBox(height: 18),
                        
                        // Gender Selector
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: DropdownButtonFormField<String>(
                            value: controller.gender.value,
                            decoration: ThemeHelper().textInputDecoration("Gender", ""),
                            items: const [
                              DropdownMenuItem(value: "Male", child: Text("Male")),
                              DropdownMenuItem(value: "Female", child: Text("Female")),
                              DropdownMenuItem(value: "Other", child: Text("Other")),
                            ],
                            onChanged: (val) => controller.gender.value = val!,
                          ),
                        ),
                        const SizedBox(height: 18),
                        
                        // Country Selector
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: DropdownButtonFormField<String>(
                            value: controller.country.value,
                            decoration: ThemeHelper().textInputDecoration("Country", ""),
                            items: const [
                              DropdownMenuItem(value: "Bangladesh", child: Text("Bangladesh")),
                              DropdownMenuItem(value: "USA", child: Text("USA")),
                              DropdownMenuItem(value: "Canada", child: Text("Canada")),
                              DropdownMenuItem(value: "UK", child: Text("UK")),
                              DropdownMenuItem(value: "Other", child: Text("Other")),
                            ],
                            onChanged: (val) => controller.country.value = val!,
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Register Button
                        Container(
                          decoration: ThemeHelper().buttonBoxDecoration(context),
                          child: ElevatedButton(
                            style: ThemeHelper().buttonStyle(),
                            onPressed: () => controller.register(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Register".toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
