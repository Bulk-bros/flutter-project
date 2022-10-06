import 'package:flutter/material.dart';
import 'package:stattrack/components/buttons/form_button.dart';
import 'package:stattrack/services/auth.dart';
import 'package:stattrack/utils/validator.dart';

class EmailSignUpForm extends StatefulWidget {
  const EmailSignUpForm({Key? key, required this.auth}) : super(key: key);

  final AuthBase auth;

  @override
  _EmailSignUpFormState createState() => _EmailSignUpFormState();
}

class _EmailSignUpFormState extends State<EmailSignUpForm> {
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _passwordConfirmFocusNode = FocusNode();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  String get _name => _nameController.text;
  String get _email => _emailController.text;
  String get _password => _passwordController.text;
  String get _passwordConfirm => _passwordConfirmController.text;

  bool get _isValidName => Validator.isValidName(_name);
  bool get _isValidEmail => Validator.isValidEmail(_email);
  bool get _isValidPassword => Validator.isValidPassword(_password);
  bool get _isValidPasswordConfirm =>
      Validator.isValidPassword(_passwordConfirm) &&
      _password == _passwordConfirm;

  bool _hasSubmitted = false;
  bool _isChecked = false;

  /// Handles the submition of form
  void _submit() {
    print('Submitting');
    setState(() {
      _hasSubmitted = true;
    });
  }

  void _updateState() {
    setState(() {});
  }

  void _nameEditingCompelte() {
    final newFocus = _isValidName ? _emailFocusNode : _nameFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _emailEditingCompelte() {
    final newFocus = _isValidEmail ? _passwordFocusNode : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _passwordEditingCompelte() {
    final newFocus =
        _isValidPassword ? _passwordConfirmFocusNode : _passwordFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  @override
  Widget build(BuildContext context) {
    // Makes sure submit button is only enabled
    // when all criterias are met
    bool enableSubmit = _isValidName &&
        _isValidEmail &&
        _isValidPassword &&
        _isValidPasswordConfirm &&
        _isChecked;

    return Padding(
      padding: const EdgeInsets.all(31.0),
      child: Form(
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              decoration: InputDecoration(
                labelText: 'Full name',
                hintText: 'Your username',
                errorText: _hasSubmitted && !_isValidName
                    ? 'Empty name not allowed'
                    : null,
              ),
              textInputAction: TextInputAction.next,
              onEditingComplete: _nameEditingCompelte,
              onChanged: (name) => _updateState(),
            ),
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Your email address',
                errorText:
                    _hasSubmitted && !_isValidEmail ? 'Invalid email' : null,
              ),
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onEditingComplete: _emailEditingCompelte,
              onChanged: (email) => _updateState(),
            ),
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Your password',
                errorText: _hasSubmitted && !_isValidPassword
                    ? '8-20 characters, both lower and uppercase and atleast one number'
                    : null,
              ),
              obscureText: true,
              textInputAction: TextInputAction.next,
              onEditingComplete: _passwordEditingCompelte,
              onChanged: (pwd) => _updateState(),
            ),
            TextFormField(
              controller: _passwordConfirmController,
              focusNode: _passwordConfirmFocusNode,
              decoration: InputDecoration(
                labelText: 'Confirm password',
                hintText: 'Confirm password',
                errorText: _hasSubmitted && !_isValidPasswordConfirm
                    ? 'Both passwords must match'
                    : null,
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onEditingComplete: _submit,
              onChanged: (pwdConfirm) => _updateState(),
            ),
            const SizedBox(
              height: 39.0,
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  value: _isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked = value!;
                    });
                  },
                ),
                const Text('I have read and agree with the Terms of Service'),
              ],
            ),
            const SizedBox(
              height: 39.0,
            ),
            FormButton(
              onPressed: enableSubmit ? _submit : null,
              label: 'Sign Up',
            ),
          ],
        ),
      ),
    );
  }
}
