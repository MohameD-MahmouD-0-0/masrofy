abstract class RegisterState{}
class InitialRegisterState extends RegisterState{}
class LoadingRegisterState extends RegisterState{}
class RegisterSuccessState extends RegisterState{}
class RegisterErrorState extends RegisterState{
  final String message;
  RegisterErrorState(this.message);
}