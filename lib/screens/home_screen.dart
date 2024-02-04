import 'package:flutter/material.dart';

import 'package:flutter_qrcode_bloc/blocs/auth/auth_bloc.dart';
import 'package:flutter_qrcode_bloc/blocs/product/product_bloc.dart';
import 'package:flutter_qrcode_bloc/routes/route_names.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR CODE')),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductStateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
              ),
            );
          }

          if (state is ProductStateSuccessQR) {
            context.goNamed(Routes.productDetail,
                pathParameters: {
                  "productId": state.product.productId!,
                },
                extra: state.product);
          }
        },
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductStateLoadingQR) {
              return const Center(child: CircularProgressIndicator());
            }
            return BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthStateLoggedOut) {
                  context.goNamed(Routes.login);
                }
                if (state is AuthStateError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AuthStateLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    late String title;
                    late IconData icon;
                    late VoidCallback onTap;

                    switch (index) {
                      case 0:
                        title = 'Add Product';
                        icon = Icons.post_add_rounded;
                        onTap = () {
                          context.goNamed(Routes.addProduct);
                        };
                        break;

                      case 1:
                        title = 'Products';
                        icon = Icons.list_alt;
                        onTap = () {
                          context.goNamed(Routes.product);
                        };
                        break;

                      case 2:
                        title = 'SCAN';
                        icon = Icons.qr_code_scanner_outlined;
                        onTap = () {
                          context.read<ProductBloc>().add(ProductEventQrScan());
                        };
                        break;

                      case 3:
                        title = 'Catalog';
                        icon = Icons.library_books;
                        onTap = () {
                          context
                              .read<ProductBloc>()
                              .add(ProductEventExportPdf());
                        };
                        break;
                    }
                    return Material(
                      color: Colors.blueGrey.shade900,
                      elevation: 8,
                      borderRadius: BorderRadius.circular(9),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(9),
                        onTap: onTap,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              (index == 3)
                                  ? BlocBuilder<ProductBloc, ProductState>(
                                      builder: (context, state) {
                                        if (state is ProductStateLoadingPDF) {
                                          return const CircularProgressIndicator();
                                        } else {
                                          return Icon(
                                            icon,
                                            size: 55,
                                          );
                                        }
                                      },
                                    )
                                  : Icon(
                                      icon,
                                      size: 55,
                                    ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                title,
                                style: const TextStyle(fontSize: 15),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          context.read<AuthBloc>().add(AuthEventLogout());
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
