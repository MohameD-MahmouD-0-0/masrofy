import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masrofy/Register%20Screen/register_screen_view_model.dart';
import 'package:masrofy/Register%20Screen/register_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import 'custom_text_form_filed.dart';

class RegisterScreen extends StatelessWidget {
  static const String routeName = '/register';

  RegisterScreenViewModel viewModel = RegisterScreenViewModel();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<RegisterScreenViewModel, RegisterState>(
          bloc: viewModel,
          listener: (context, state) {
            if (state is RegisterSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Register Successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushNamed(context, '/login');
            }

            if (state is RegisterErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Something went wrong'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: viewModel.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),

                    Center(
                      child: Text(
                        "Masrofy",
                        style: AppTextStyle.ts34bold
                            .copyWith(color: AppColors.primary),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Center(
                      child: Text(
                        "Create your account and take control of your finances",
                        textAlign: TextAlign.center,
                        style: AppTextStyle.ts14
                            .copyWith(color: AppColors.little_grey),
                      ),
                    ),

                    const SizedBox(height: 40),

                    Text("Full Name", style: AppTextStyle.ts14bold),
                    const SizedBox(height: 8),
                    CustomTextFormFiled(
                      hint: "Enter your full name",
                      controller: viewModel.fullNameController,
                      onChanged: (value) {},
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Name is required";
                        }
                        if (value.trim().length < 3) {
                          return "Name must be at least 3 characters";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    Text("Email", style: AppTextStyle.ts14bold),
                    const SizedBox(height: 8),
                    CustomTextFormFiled(
                      hint: "name@example.com",
                      controller: viewModel.emailController,
                      onChanged: (value) {},
                      validator: (value) {
                        final emailRegex = RegExp(
                          r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+",
                        );

                        if (value == null || value.trim().isEmpty) {
                          return "Email is required";
                        }
                        if (!emailRegex.hasMatch(value.trim())) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    Text("Password", style: AppTextStyle.ts14bold),
                    const SizedBox(height: 8),
                    CustomTextFormFiled(
                      hint: "••••••••",
                      controller: viewModel.passwordController,
                      onChanged: (value) {},
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Password is required";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: state is LoadingRegisterState
                            ? null
                            : () {
                          final isValid =
                              viewModel.formKey.currentState
                                  ?.validate() ??
                                  false;

                          if (isValid) {
                            viewModel.register();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: state is LoadingRegisterState
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Create Account",
                              style: AppTextStyle.ts16.copyWith(
                                color: AppColors.background,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.arrow_forward,
                              color: AppColors.background,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}