import 'dart:typed_data';

import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monumento/application/authentication/login_register/login_register_bloc.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';

import 'widgets/sign_up_decider_widget.dart';

class SignUpViewDesktop extends StatefulWidget {
  const SignUpViewDesktop({super.key});

  @override
  State<SignUpViewDesktop> createState() => _SignUpViewDesktopState();
}

class _SignUpViewDesktopState extends State<SignUpViewDesktop>
    with AutomaticKeepAliveClientMixin<SignUpViewDesktop> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController statusController;
  late PageController controller;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Uint8List? imageBytes;
  bool isSeen = false;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    usernameController = TextEditingController();
    statusController = TextEditingController();
    controller = PageController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    usernameController.dispose();
    statusController.dispose();
    controller.dispose();
    super.dispose();
  }

  void _attemptSignUp() {
    if (formKey.currentState!.validate()) {
      locator<LoginRegisterBloc>().add(
        SignUpWithEmailPressed(
          email: emailController.text,
          password: passwordController.text,
          name: nameController.text,
          username: usernameController.text,
          status: statusController.text,
          profilePictureFile: imageBytes != null
              ? imageBytes!
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColor.appBackground,
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Assets.desktop.logoDesktop.svg(),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Card(
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 32, vertical: 50),
                        width: 380,
                        child: BlocListener<LoginRegisterBloc, LoginRegisterState>(
                          bloc: locator<LoginRegisterBloc>(),
                          listener: (context, state) {
                            if (state is SignUpFailed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.message),
                                ),
                              );
                            }
                            if (state is SigninWithGoogleFailed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.message),
                                ),
                              );
                            }
                          },
                          child: BlocBuilder<LoginRegisterBloc, LoginRegisterState>(
                            bloc: locator<LoginRegisterBloc>(),
                            builder: (context, state) {
                              if (state is LoginRegisterLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColor.appPrimary,
                                    ),
                                  ),
                                );
                              }
                              if (state is SignUpSuccess) {
                                SchedulerBinding.instance.addPostFrameCallback((_) {
                                  context.go('/');
                                });
                              }
                              return ExpandablePageView(
                                pageSnapping: false,
                                physics: const NeverScrollableScrollPhysics(),
                                controller: controller,
                                children: [
                                  SignUpDeciderWidget(
                                    onSignUpWithEmailPressed: () {
                                      controller.nextPage(
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeIn,
                                      );
                                    },
                                    onSignUpWithGooglePressed: () {
                                      locator<LoginRegisterBloc>().add(
                                        LoginWithGooglePressed(),
                                      );
                                    },
                                  ),
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          final ImagePicker picker = ImagePicker();
                                          final img = await picker.pickImage(
                                            source: ImageSource.gallery,
                                          ).then((value) => value!.readAsBytes());
                                          setState(() {
                                            imageBytes = img;
                                          });
                                        },
                                        child: imageBytes != null
                                            ? CircleAvatar(
                                                radius: 40,
                                                backgroundImage:
                                                    MemoryImage(imageBytes!),)
                                            : CircleAvatar(
                                                radius: 40,
                                                backgroundColor:
                                                    AppColor.appGreyAccent,
                                                child: Assets.icons.icUser.svg(),
                                              ),
                                      ),
                                      const SizedBox(
                                        height: 22,
                                      ),
                                      CustomTextField(
                                        controller: nameController,
                                        isDesktop: true,
                                        text: 'Name',
                                        textInputAction: TextInputAction.next,
                                        validateFunction: (value) {
                                          if (value!.isEmpty) {
                                            return 'Name cannot be empty';
                                          }
                                          return null;
                                        },
                                        autoValid: AutovalidateMode.onUserInteraction,
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      CustomTextField(
                                        controller: usernameController,
                                        isDesktop: true,
                                        text: 'Username',
                                        textInputAction: TextInputAction.next,
                                        validateFunction: (value) {
                                          if (value!.isEmpty) {
                                            return 'Username cannot be empty';
                                          }
                                          return null;
                                        },
                                        autoValid: AutovalidateMode.onUserInteraction,
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      CustomTextField(
                                        controller: statusController,
                                        isDesktop: true,
                                        text: 'Status',
                                        textInputAction: TextInputAction.next,
                                        validateFunction: (value) {
                                          if (value!.isEmpty) {
                                            return 'Status cannot be empty';
                                          }
                                          return null;
                                        },
                                        autoValid: AutovalidateMode.onUserInteraction,
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      CustomTextField(
                                        controller: emailController,
                                        isDesktop: true,
                                        text: 'Email',
                                        textInputAction: TextInputAction.next,
                                        validateFunction: (value) {
                                          if (value!.isEmpty) {
                                            return 'Email cannot be empty';
                                          } else if (!value.contains('@')) {
                                            return 'Invalid email';
                                          }
                                          return null;
                                        },
                                        autoValid: AutovalidateMode.onUserInteraction,
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      CustomTextField(
                                        controller: passwordController,
                                        text: 'Password',
                                        isDesktop: true,
                                        isSeen: !isSeen,
                                        textInputAction: TextInputAction.done,
                                        onEditingComplete: _attemptSignUp,
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              isSeen = !isSeen;
                                            });
                                          },
                                          icon: Icon(!isSeen
                                              ? Icons.visibility_off
                                              : Icons.visibility),
                                        ),
                                        validateFunction: (value) {
                                          if (value!.isEmpty) {
                                            return 'Password cannot be empty';
                                          } else if (value.length < 6) {
                                            return 'Password must be at least 6 characters';
                                          }
                                          return null;
                                        },
                                        autoValid:
                                            AutovalidateMode.onUserInteraction,
                                      ),
                                      const SizedBox(
                                        height: 48,
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        child: CustomElevatedButton(
                                          isDesktop: true,
                                          onPressed: _attemptSignUp,
                                          text: 'Sign Up',
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 26,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Already have an account?',
                                            style: AppTextStyles.s14(
                                              color: AppColor.appSecondaryBlack,
                                              fontType: FontType.REGULAR,
                                              isDesktop: true,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              context.pop();
                                            },
                                            style: ButtonStyle(
                                              overlayColor: WidgetStateProperty.all(
                                                Colors.transparent,
                                              ),
                                            ),
                                            child: Text(
                                              'Login',
                                              style: AppTextStyles.s14(
                                                color: AppColor.appPrimary,
                                                fontType: FontType.MEDIUM,
                                                isDesktop: true,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
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

  @override
  bool get wantKeepAlive => true;
}