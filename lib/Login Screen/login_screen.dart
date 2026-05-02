import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masrofy/core/theme/app_colors.dart';
import '../Register Screen/custom_text_form_filed.dart';
import '../core/theme/app_text_style.dart';
import 'login_screen_view_model.dart';
import 'login_state.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginScreenViewModel viewModel = LoginScreenViewModel();

  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      body: SafeArea(
        child: BlocConsumer<LoginScreenViewModel, LoginState>(
          bloc: viewModel,
          listener: (context, state) {
            if (state is SuccessLoginState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Login Successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }

            if (state is ErrorLoginState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Login Failed'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Form(
                  key: viewModel.formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.blue.withOpacity(.1),
                        child: Image.asset('assetes/images/login_icon.png'),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "Welcome Back",
                        style: AppTextStyle.ts20bold.copyWith(
                          color: AppColors.primaryText,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Securely manage your wealth with Masrofy.",
                        textAlign: TextAlign.center,
                        style: AppTextStyle.ts14
                            .copyWith(color: AppColors.little_grey),
                      ),

                      const SizedBox(height: 30),

                      /// EMAIL
                      CustomTextFormFiled(
                        hint: "Email address",
                        controller: viewModel.emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email required";
                          }

                          final emailRegex = RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+");

                          if (!emailRegex.hasMatch(value)) {
                            return "Enter valid email";
                          }

                          return null;
                        },
                        onChanged: (value) {},
                      ),

                      const SizedBox(height: 15),

                      /// PASSWORD
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          CustomTextFormFiled(
                            hint: "Password",
                            controller: viewModel.passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password required";
                              }
                              if (value.length < 6) {
                                return "Min 6 characters";
                              }
                              return null;
                            },
                            onChanged: (value) {},
                          ),
                          IconButton(
                            icon: Icon(
                              isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                isObscure = !isObscure;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Forgot Password?",
                          style: AppTextStyle.ts14bold.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state is LoadingLoginState
                              ? null
                              : () {
                            if (viewModel.formKey.currentState!.validate()) {
                              viewModel.login();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: state is LoadingLoginState
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : Text(
                            'Login',
                            style: AppTextStyle.ts16.copyWith(
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.hint)),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "OR CONTINUE WITH",
                              style: AppTextStyle.ts14.copyWith(
                                color: AppColors.little_grey,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.hint)),
                        ],
                      ),

                      const SizedBox(height: 25),

                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border:
                          Border.all(color: Colors.grey.shade300),
                          color: Colors.white,
                        ),
                        child: const Center(
                          child: Text(
                            "Sign in with Google",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}