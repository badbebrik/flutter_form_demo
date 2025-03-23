import 'package:flutter/material.dart';
import 'package:form_demo/User.dart';
import 'package:form_demo/UserDetails.dart';

void main() {
  runApp(MaterialApp(home: RegistrationForm()));
}

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();


  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _repeatPasswordFocus = FocusNode();
  final _birthdayFocus = FocusNode();
  final _genderFocus = FocusNode();
  final _registerButtonFocus = FocusNode();

  DateTime? _birthDate;
  String? _selectedGender;
  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;
  bool _agreedToPolicy = false;

  final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  final RegExp _passwordRegex =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$&*~]).{8,}$');


  @override
  Widget build(BuildContext context) {

    void submit() {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Регистрация прошла успешно')),
        );

        final user = User(
          email: _emailController.text,
          password: _passwordController.text,
          birthDate: _birthDate!,
          gender: _selectedGender!,
        );

        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => UserDetailsPage(user: user)),
        );
      }
    }

    void resetForm() {
      _formKey.currentState!.reset();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      setState(() {
        _birthDate = null;
        _selectedGender = null;
        _agreedToPolicy = false;
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocus,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_passwordFocus);
                },
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email'),
                onSaved: (val) => _emailController.text = val!,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите email';
                  if (!_emailRegex.hasMatch(value)) return 'Некорректный email';
                  return null;
                },
              ),

              SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_repeatPasswordFocus);
                },
                onSaved: (val) => _passwordController.text = val!,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите пароль';
                  if (!_passwordRegex.hasMatch(value)) {
                    return 'Минимум 8 символов, включая буквы, цифры и спец. символы';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              TextFormField(
                controller: _confirmPasswordController,
                focusNode: _repeatPasswordFocus,
                obscureText: _obscureRepeatPassword,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_birthdayFocus);
                },
                onSaved: (val) => _confirmPasswordController.text = val!,
                decoration: InputDecoration(
                  labelText: 'Повторите пароль',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureRepeatPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscureRepeatPassword = !_obscureRepeatPassword);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Повторите пароль';
                  if (value != _passwordController.text) {
                    return 'Пароли не совпадают';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              FormField<DateTime>(
                validator: (value) {
                  if (value == null) return 'Выберите дату рождения';
                  final now = DateTime.now();
                  final age = now.year -
                      value.year -
                      ((now.month < value.month ||
                          (now.month == value.month && now.day < value.day))
                          ? 1
                          : 0);
                  if (age < 18) return 'Вам должно быть не менее 18 лет';
                  return null;
                },

                onSaved: (value) => _birthDate = value,
                builder: (state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputDatePickerFormField (
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now().subtract(Duration(days: 365 * 18)),
                        initialDate: state.value ?? DateTime.now().subtract(Duration(days: 365 * 18)),
                        onDateSubmitted: (picked) {
                          state.didChange(picked);
                          FocusScope.of(context).requestFocus(_genderFocus);
                        },
                        focusNode: _birthdayFocus,
                        onDateSaved: (picked) {
                          state.didChange(picked);
                        },
                        fieldLabelText: 'Дата рождения',
                        errorInvalidText: '',
                        errorFormatText: '',
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            state.errorText!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  );
                },
              ),


              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                focusNode: _genderFocus,
                onTap: () {
                  FocusScope.of(context).requestFocus(_registerButtonFocus);
                },
                decoration: InputDecoration(labelText: 'Пол'),
                value: _selectedGender,
                items: ['Мужской', 'Женский']
                    .map((gender) =>
                        DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
                onSaved: (value) => _selectedGender = value,
                validator: (value) => value == null ? 'Выберите пол' : null,
              ),

              SizedBox(height: 16),

              FormField<bool>(
                initialValue: _agreedToPolicy,
                validator: (value) {
                  if (value != true) return 'Необходимо согласие с политикой';
                  return null;
                },
                onSaved: (value) => _agreedToPolicy = value ?? false,
                builder: (state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: state.value,
                            onChanged: (val) => state.didChange(val),
                          ),
                          Expanded(
                              child: Text(
                                  'Я согласен с политикой конфиденциальности')),
                        ],
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(state.errorText ?? '',
                              style:
                                  TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                    ],
                  );
                },
              ),

              SizedBox(height: 8),

              TextButton(
                onPressed: resetForm,
                child: Text('Очистить форму'),
              ),

              SizedBox(height: 24),

              ElevatedButton(
                focusNode: _registerButtonFocus,
                onPressed: submit,
                child: Text('Зарегистрироваться'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
