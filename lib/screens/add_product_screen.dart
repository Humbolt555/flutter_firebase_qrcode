import 'package:flutter/material.dart';
import 'package:flutter_qrcode_bloc/blocs/product/product_bloc.dart';
import 'package:flutter_qrcode_bloc/data/models/product_model.dart';
import 'package:go_router/go_router.dart';

class AddProductScreen extends StatelessWidget {
  AddProductScreen({super.key});

  final TextEditingController nameC = TextEditingController();
  final TextEditingController quantityC = TextEditingController();
  final TextEditingController codeC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
            controller: codeC,
            keyboardType: TextInputType.number,
            autocorrect: false,
            maxLength: 10,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), label: Text('Product Code')),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: quantityC,
            keyboardType: TextInputType.number,
            autocorrect: false,
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
              );

              if (data.code.length != 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('product code length must be 10'),
                  ),
                );
              } else if (data.name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('product name cant be empty'),
                  ),
                );
              } else {
                context.read<ProductBloc>().add(
                      ProductEventAdd(product: data),
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
                if (state is ProductStateSuccessAdd) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data added successfuly!'),
                    ),
                  );
                  // back to home page
                  context.pop();
                }
              },
              builder: (context, state) {
                if (state is ProductStateLoadingAdd) {
                  return const Text('LOADING...');
                }
                return const Text('ADD PRODUCT');
              },
            ),
          ),
        ],
      ),
    );
  }
}
