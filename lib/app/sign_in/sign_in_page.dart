import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_sns/app/sign_in/email_sign_in_model.dart';
import 'package:simple_sns/app/sign_in/email_sign_in_page.dart';
import 'package:simple_sns/app/sign_in/sign_in_bloc.dart';
import 'package:simple_sns/app/sign_in/sign_in_button.dart';
import 'package:simple_sns/common_widgets/platform_exception_alert_dialog.dart';
import 'package:simple_sns/services/auth.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key key, @required this.bloc}) : super(key: key);
  final SignInBloc bloc;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context);
    return Provider<SignInBloc>(
      create: (_) => SignInBloc(auth: auth),
      dispose: (context, bloc) => bloc.dispose(),
      child: Consumer<SignInBloc>(
        builder: (context, bloc, _) => SignInPage(bloc: bloc),
      ),
    );
  }

  void _showSignInError(BuildContext context, PlatformException exception) {
    PlatformExceptionAlertDialog(
      title: 'Sign in failed',
      exception: exception,
    ).show(context);
  }

  void _signInWithEmail(BuildContext context, EmailSignInFormType formType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => EmailSignInPage(formType: formType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Simple SNS"),
        elevation: 10.0,
      ),
      body: StreamBuilder(
        stream: bloc.isLoadingStream,
        initialData: false,
        builder: (context, snapshot) {
          return _buildContent(context, snapshot.data);
        },
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContent(BuildContext context, bool isLoading) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 50.0,
            child: _buildHeader(isLoading),
          ),
          SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: SignInButton(
                  text: "Sign in",
                  textColor: Colors.white,
                  color: Colors.teal[700],
                  onPressed: () =>
                      isLoading ? null : _signInWithEmail(context, EmailSignInFormType.signIn),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: SignInButton(
                  text: "Sign up",
                  textColor: Colors.teal[700],
                  color: Colors.grey[100],
                  onPressed: () =>
                      isLoading ? null : _signInWithEmail(context, EmailSignInFormType.register),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isLoading) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Text(
      "Welcome",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
