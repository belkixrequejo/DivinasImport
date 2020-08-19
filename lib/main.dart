import 'package:divinasimportproyect/product/bloc/routes.dart';
import 'package:divinasimportproyect/product/model/cart.dart';
import 'package:divinasimportproyect/product/model/orders.dart';
import 'package:divinasimportproyect/product/model/products.dart';
import 'package:divinasimportproyect/product/ui/screens/products_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:divinasimportproyect/user/bloc/authentication_bloc/bloc.dart';
import 'package:divinasimportproyect/user/bloc/simple_bloc_delegate.dart';
import 'package:divinasimportproyect/user/repository/user_repository.dart';
import 'package:divinasimportproyect/user/ui/screens/home_screen.dart';
import 'package:divinasimportproyect/user/ui/screens/login/login_screen.dart';
import 'package:divinasimportproyect/user/ui/screens/splash_screen.dart';

import 'package:provider/provider.dart';
import 'package:provider/src/change_notifier_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = SimpleBlocDelegate();

  final UserRepository userRepository = UserRepository();
  runApp(BlocProvider(
    create: (context) =>
        AuthenticationBloc(userRepository: userRepository)..add(AppStarted()),
    child: App(userRepository: userRepository),
  ));
}

class App extends StatelessWidget {
  final UserRepository _userRepository;

  App({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Uninitialized) {
            return SplashScreen();
          }
          if (state is Authenticated) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider.value(
                  value: Products(),
                ),
                ChangeNotifierProvider.value(
                  value: Cart(),
                ),
                ChangeNotifierProvider.value(
                  value: Orders(),
                ),
              ],
              child: MaterialApp(
                title: 'MyShop',
                theme: ThemeData(
                  primarySwatch: Colors.purple,
                  accentColor: Colors.orangeAccent,
                  fontFamily: 'Lato',
                ),
                home: ProductsOverviewScreen(),
                routes: Routes.availableRoutes,
              ),
            );
          }
          if (state is Unauthenticated) {
            return LoginScreen(
              userRepository: _userRepository,
            );
          }
          return Container();
        },
      ),
    );
  }
}
