import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qrcode_bloc/blocs/product/product_bloc.dart';
import 'package:flutter_qrcode_bloc/data/models/product_model.dart';
import 'package:flutter_qrcode_bloc/routes/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ProductBloc productB = context.read<ProductBloc>();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Product'),
        ),
        body: StreamBuilder<QuerySnapshot<ProductModel>>(
          stream: productB.streamsProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text('There is no data :('),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong :('),
              );
            }
            List<ProductModel> data = [];
            for (var item in snapshot.data!.docs) {
              data.add(item.data());
            }

            if (data.isEmpty) {
              return const Center(
                child: Text('There is no data :('),
              );
            }

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                ProductModel product = data[index];
                return Material(
                  child: Card(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                      left: 12,
                      right: 12,
                    ),
                    elevation: 5,
                    child: InkWell(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => SimpleDialog(
                            backgroundColor: Colors.grey.shade300,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                height: 300,
                                width: 300,
                                child: QrImageView(
                                  data: product.productId!,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      onTap: () {
                        context.goNamed(
                          Routes.productDetail,
                          pathParameters: {"productId": product.productId!},
                          extra: product,
                        );
                      },
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    product.code,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  Text(
                                    'QTY : ${product.quantity}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              height: 60,
                              width: 60,
                              child: QrImageView(
                                data: product.productId!,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ));
  }
}
