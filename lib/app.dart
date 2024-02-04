import 'package:flutter/material.dart';

import 'package:flutter_qrcode_bloc/blocs/auth/auth_bloc.dart';
import 'package:flutter_qrcode_bloc/blocs/product/product_bloc.dart';
import 'package:flutter_qrcode_bloc/routes/router.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<AuthBloc>(
//       create: (context) => AuthBloc(),
//       child: MaterialApp.router(
//         routerConfig: router,
//         theme: ThemeData.dark(),
//       ),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<ProductBloc>(
          create: (context) => ProductBloc(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData.dark(),
      ),
    );
  }
}
