import 'package:email_validator/email_validator.dart';
import 'package:fin/utils/routes.dart';
import 'package:fin/widgets/formButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ResetPage extends StatefulWidget {
  const ResetPage({ Key? key }) : super(key: key);

  @override
  State<ResetPage> createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  var email = "";
  final emailController = TextEditingController();
  bool changeButton = false;

  final _formkey = GlobalKey<FormState>();

  reset(GlobalKey<FormState> _formkey) async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        email = emailController.text;
        changeButton = true;
      });

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: "Password Reset Mail Sent to ${email}".text.make()));
        context.vxNav.pop();
      } on FirebaseAuthException catch (e) {
        changeButton = false;
        if (e.code == 'user-not-found') {
          print("This email is not registered");
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: "User not found. Sign-Up".text.make()));
          await context.vxNav.push(Uri.parse(MyRoutes.signupRoute),
              params: {"email": emailController.text});
        } else if (e.code == 'wrong-password') {
          print("Email and Password does not match");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: "Email and Password does not match".text.make()));
        }
      }
      setState(() {
        changeButton = false;
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Form(
        key: _formkey,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Image.asset(
                "assets/images/login_image.png",
                fit: BoxFit.fill,
              ),
            ),
            Container(
              color: Colors.white,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 32.0),
                child: Column(
                  children: [
                    TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Enter your Email",
                          prefixIcon: Icon(CupertinoIcons.mail),
                          labelText: "Email",
                        ),
                        controller: emailController,
                        validator: (value) {
                          if (value!.isEmpty ||
                              !EmailValidator.validate(value)) {
                            return "Enter valid Email-ID";
                          }
                          if (value.isEmpty) {
                            return "Email-ID cannot be empty";
                          }
                          return null;
                        },
                      ),
                    const SizedBox(
                      height: 40.0,
                    ),
                    FormButton(changeButton: changeButton, onTapFunction: reset, formkey: _formkey, buttonName: "Send Reset Link",),
                  ],
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}