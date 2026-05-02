import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masrofy/Login%20Screen/login_state.dart';

class LoginScreenViewModel extends Cubit<LoginState>{
  LoginScreenViewModel():super(InitialLoginState());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login() async{
    try {
      if(formKey.currentState!.validate()) {
        emit(LoadingLoginState());
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text
        );
        if(credential.user != null) {
          emit(SuccessLoginState());
        }
         else{
           emit(ErrorLoginState());
        }

      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(ErrorLoginState());
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        emit(ErrorLoginState());
        print('Wrong password provided for that user.');
      }
    }
  }
}