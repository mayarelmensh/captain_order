import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_2_go/core/utils/app_colors.dart';
import 'package:food_2_go/core/utils/app_routes.dart';
import 'package:food_2_go/custom_widgets/custom_elevated_button.dart';
import 'package:food_2_go/custom_widgets/custom_text_form_field.dart';
import 'package:food_2_go/features/auth/login/view/role_screen.dart';
import 'package:google_fonts/google_fonts.dart';
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
          print(state.failure.errorMsg);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
              SnackBar(
                content: Text(state.failure.errorMsg),
                backgroundColor: AppColors.red,
              ));
        } else if (state is LoginSuccess) {
          Navigator.pop(context); // Hide loading
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 1),
              content: Text('Login successful!'),
              backgroundColor: AppColors.green,
          ));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RoleScreen(loginResponse: state.loginResponse,), // ✅ مرريه هنا
            ),
          );
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
                    Container(
                      width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(70.r),
                            bottomRight: Radius.circular(70.r),
                          ),
                        ),
                        child: Image.asset('assets/images/Frame 4.png', )),
                    SizedBox(height: 8.h),
                    Text(
                      'Login',
                      style:GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      )
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
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,)
                        ),
                        SizedBox(height: 8.h),
                        CustomTextFormField(
                          hintText: "Enter Your Email",
                          hintStyle:  GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.subColor,),
                          borderColor: AppColors.subColor,
                          controller: _emailController,
                        ),
                        SizedBox(height: 20.h),
                        // Password Field
                        Text(
                          'Password',
                          style:  GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,),
                        ),
                        SizedBox(height: 8.h),
                        CustomTextFormField(
                          isObscureText: loginCubit.isPasswordObscure,
                          hintText: "Enter Your Password",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.subColor,),
                          borderColor: AppColors.subColor,
                          controller: _passwordController, // ربط الـ controller
                          suffixIcon: IconButton(
                            onPressed: () {
                              loginCubit.togglePasswordVisibility();
                            },
                            icon: Icon(
                              loginCubit.isPasswordObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.subColor,
                              size: 20.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 25.h),
                        // Login Button
                        CustomElevatedButton(
                          text: "Login",
                          onPressed: () {
                              loginCubit.login(
                                _emailController.text,
                                _passwordController.text,
                              );
                          },
                          backgroundColor: AppColors.primary,
                          textStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            color: AppColors.white,
                          )
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