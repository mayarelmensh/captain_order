import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_2_go/core/utils/app_colors.dart';
import 'package:food_2_go/custom_widgets/custom_elevated_button.dart';
import 'package:food_2_go/custom_widgets/custom_text_form_field.dart';

import '../logic/cubit/login_cubit.dart';
import '../logic/cubit/login_states.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginCubit loginCubit = LoginCubit();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    loginCubit.close();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      bloc: loginCubit,
      listener: (context, state) {
        if (state is LoginLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                Center(child: CircularProgressIndicator(
                  color: AppColors.primary,
                )),
          );
        } else if (state is LoginError) {
          Navigator.pop(context); // Hide loading
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.failure.errorMsg)));
        } else if (state is LoginSuccess) {
          Navigator.pop(context); // Hide loading
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful!')));
          // Navigate to home or next screen
          // Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Logo and Welcome Text
                Column(
                  children: [
                    Image.asset('assets/images/Frame 4.png'),
                    SizedBox(height: 8.h),
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                // Form Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 20.h),
                        // Email Field
                        Text(
                          'Email/User name',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        CustomTextFormField(
                          hintText: "Enter Your Email",
                          borderColor: AppColors.subColor,
                          controller: _emailController, // ربط الـ controller
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),
                        // Password Field
                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        CustomTextFormField(
                          hintText: "Enter Your Password",
                          borderColor: AppColors.subColor,
                          controller: _passwordController, // ربط الـ controller
                          isPassword: true, // عشان الباسورد يبقى مخفي
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 25.h),
                        // Login Button
                        CustomElevatedButton(
                          text: "Login",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              loginCubit.login(
                                _emailController.text,
                                _passwordController.text,
                              );
                            }
                          },
                          backgroundColor: AppColors.primary,
                          textStyle: TextStyle(
                            fontSize: 18,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}