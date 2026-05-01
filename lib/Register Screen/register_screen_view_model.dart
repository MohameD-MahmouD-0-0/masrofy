import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masrofy/Register%20Screen/register_state.dart';

class RegisterScreenViewModel extends Cubit<RegisterState> {
  RegisterScreenViewModel() : super(InitialRegisterState());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void register() async {
    emit(LoadingRegisterState());
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
      if(credential.user != null) {
        emit(RegisterSuccessState());
      }
        else{
          emit(RegisterErrorState('Something went wrong'));
      }
      }
     on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }
}
