import 'package:together_version_2/pages/bottom_nav_bar.dart';
import 'package:together_version_2/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: isLoading
          ? Center(
              child: SizedBox(
                  child: LoadingAnimationWidget.hexagonDots(
                      color: Colors.black87, size: 20)),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: size.height / 20,
                  ),
                  Container(
                      width: size.width / 1.2,
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.arrow_back_ios))),
                  SizedBox(
                    height: size.height / 50,
                  ),
                  SizedBox(
                    width: size.width / 1.3,
                    child: const Text(
                      'Welcome',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: size.width / 1.3,
                    child: const Text(
                      'Create account to continue.',
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(
                    height: size.height / 10,
                  ),
                  Container(
                      width: size.width,
                      alignment: Alignment.center,
                      child: field(size, "name", Iconsax.profile_circle5,
                          nameController)),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Container(
                        width: size.width,
                        alignment: Alignment.center,
                        child: field(size, "email", Iconsax.personalcard5,
                            emailController)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Container(
                        width: size.width,
                        alignment: Alignment.center,
                        child: field(size, "password", Iconsax.lock5,
                            passwordController)),
                  ),
                  SizedBox(
                    height: size.height / 40,
                  ),
                  customButton(size),
                  SizedBox(
                    height: size.height / 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "login",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget field(Size size, String hintText, IconData icon,
      TextEditingController textController) {
    return SizedBox(
      height: size.height / 14,
      width: size.width / 1.2,
      child: TextField(
        controller: textController,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget customButton(Size size) {
    return InkWell(
      onTap: () {
        if (nameController.text.isNotEmpty &&
            emailController.text.isNotEmpty &&
            passwordController.text.isNotEmpty) {
          setState(() {
            isLoading = true;
          });
          AuthServices.createAccount(nameController.text, emailController.text,
                  passwordController.text, context)
              .then((value) {
            if (value != null) {
              setState(() {
                isLoading = false;
              });
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BottomNavBar(),
                  ),
                  (route) => false);
            } else {
              setState(() {
                isLoading = false;
                nameController.clear();
                emailController.clear();
                passwordController.clear();
              });
            }
          });
        }
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.black87),
        height: size.height / 14,
        width: size.width / 1.2,
        child: const Text(
          "Create account",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
