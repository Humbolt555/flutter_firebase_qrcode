import 'package:flutter/material.dart';
import 'package:flutter_qrcode_bloc/blocs/product/product_bloc.dart';
import 'package:flutter_qrcode_bloc/data/models/product_model.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProductDetailScreen extends StatelessWidget {
  ProductDetailScreen(this.productId, this.product, {super.key});

  final String productId;

  final ProductModel product;
  final TextEditingController nameC = TextEditingController();
  final TextEditingController codeC = TextEditingController();

  final TextEditingController quantityC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    nameC.text = product.name.toString();
    codeC.text = product.code.toString();
    quantityC.text = product.quantity.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SizedBox(
            height: 220,
            child: Center(
              child: QrImageView(
                data: productId,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          TextField(
            controller: codeC,
            autocorrect: false,
            readOnly: true,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), label: Text('Product Code')),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: nameC,
            autocorrect: false,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), label: Text('Product Name')),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: quantityC,
            autocorrect: false,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), label: Text('Product Quantity')),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              var data = ProductModel(
                code: codeC.text,
                name: nameC.text,
                quantity: int.tryParse(quantityC.text) ?? 0,
                productId: productId,
              );

              if (data.name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('product name cant be empty'),
                  ),
                );
              } else {
                context.read<ProductBloc>().add(
                      ProductEventEdit(product: data),
                    );
              }
            },
            child: BlocConsumer<ProductBloc, ProductState>(
              listener: (context, state) {
                if (state is ProductStateError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                    ),
                  );
                }
                if (state is ProductStateSuccessEdit) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data edited successfuly!'),
                    ),
                  );
                  // back to home page
                  context.pop();
                }
              },
              builder: (context, state) {
                if (state is ProductStateLoadingEdit) {
                  return const Text('LOADING...');
                }
                return const Text('EDIT PRODUCT');
              },
            ),
          ),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: const Text(
                    'Are you sure want to delete this product?',
                    style: TextStyle(fontSize: 18),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: const Text('NO'),
                    ),
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        context.pop();
                        context
                            .read<ProductBloc>()
                            .add(ProductEventDelete(productId: productId));
                      },
                      child: const Text('YES'),
                    ),
                  ],
                ),
              );
            },
            child: BlocConsumer<ProductBloc, ProductState>(
              listener: (context, state) {
                if (state is ProductStateError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                    ),
                  );
                }
                if (state is ProductStateSuccessDelete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data deleted'),
                    ),
                  );
                  context.pop();
                }
              },
              builder: (context, state) {
                if (state is ProductStateLoadingDelete) {
                  return const Text('LOADING...');
                }
                return const Text('DELETE PRODUCT');
              },
            ),
          ),
        ],
      ),
    );
  }
}
