import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_2_go/core/utils/app_colors.dart';
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

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // ❌ امسح الـ line دي
  // final LoginCubit loginCubit = LoginCubit();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _formAnimationController;

  // Header Animations
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;

  // Form Animations
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;

  @override
  void initState() {
    super.initState();

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOut,
    ));

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOutQuart,
    ));

    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _headerAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        _formAnimationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _formAnimationController.dispose();
    // ❌ امسح الـ line دي
    // loginCubit.close();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ استخدم الـ LoginCubit من الـ context
    final loginCubit = context.read<LoginCubit>();

    return BlocConsumer<LoginCubit, LoginState>(
      // ❌ امسح الـ bloc parameter
      // bloc: loginCubit,
      listener: (context, state) {
        if (state is LoginLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        } else if (state is LoginError) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure.errorMsg),
              backgroundColor: AppColors.red,
            ),
          );
        } else if (state is LoginSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 1),
              content: Text('Login successful!'),
              backgroundColor: AppColors.green,
            ),
          );

          // ✅ استخدم الـ BlocProvider.value عشان تبعت الـ LoginCubit
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: loginCubit,
                child: RoleScreen(loginResponse: state.loginResponse),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                SlideTransition(
                  position: _headerSlideAnimation,
                  child: FadeTransition(
                    opacity: _headerFadeAnimation,
                    child: Column(
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
                          child: Image.asset('assets/images/welcome.png'),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SlideTransition(
                  position: _formSlideAnimation,
                  child: FadeTransition(
                    opacity: _formFadeAnimation,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 20.h),
                            Text(
                              'Email/User name',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            CustomTextFormField(
                              hintText: "Enter Your Email",
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.subColor,
                              ),
                              borderColor: AppColors.subColor,
                              controller: _emailController,
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              'Password',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            BlocBuilder<LoginCubit, LoginState>(
                              builder: (context, state) {
                                return CustomTextFormField(
                                  isObscureText: loginCubit.isPasswordObscure,
                                  hintText: "Enter Your Password",
                                  hintStyle: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.subColor,
                                  ),
                                  borderColor: AppColors.subColor,
                                  controller: _passwordController,
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
                                );
                              },
                            ),
                            SizedBox(height: 25.h),
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
                              ),
                            ),
                          ],
                        ),
                      ),
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