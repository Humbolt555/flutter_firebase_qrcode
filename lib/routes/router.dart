import 'package:flutter_qrcode_bloc/data/models/product_model.dart';
import 'package:flutter_qrcode_bloc/routes/route_names.dart';
import 'package:flutter_qrcode_bloc/screens/add_product_screen.dart';
import 'package:flutter_qrcode_bloc/screens/home_screen.dart';
import 'package:flutter_qrcode_bloc/screens/login_screen.dart';
import 'package:flutter_qrcode_bloc/screens/product_detail_screen.dart';
import 'package:flutter_qrcode_bloc/screens/product_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

final router = GoRouter(
  redirect: (context, state) {
    // check if the user already login
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      return '/login';
    } else {
      return null;
    }
  },
  routes: [
    GoRoute(
      path: '/',
      name: Routes.home,
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'add-product',
          name: Routes.addProduct,
          builder: (context, state) => AddProductScreen(),
        ),
        GoRoute(
            path: 'product',
            name: Routes.product,
            builder: (context, state) => const ProductScreen(),
            routes: [
              GoRoute(
                path: ':productId',
                name: Routes.productDetail,
                builder: (context, state) => ProductDetailScreen(
                  state.pathParameters['productId'].toString(),
                  state.extra as ProductModel,
                ),
              ),
            ]),
      ],
    ),
    GoRoute(
      path: '/login',
      name: Routes.login,
      builder: (context, state) => LoginScreen(),
    ),
  ],
);
