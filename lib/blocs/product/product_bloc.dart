import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_qrcode_bloc/data/models/product_model.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

export 'package:flutter_bloc/flutter_bloc.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductStateInitial()) {
    on<ProductEventAdd>(_addProduct);

    on<ProductEventDelete>(_deleteProduct);

    on<ProductEventEdit>(_editProduct);
    on<ProductEventExportPdf>(_exportPdf);

    on<ProductEventQrScan>(_scanQrCode);
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<ProductModel>> streamsProducts() async* {
    yield* firestore
        .collection('products')
        .withConverter<ProductModel>(
          fromFirestore: (snapshot, options) =>
              ProductModel.fromJson(snapshot.data()!),
          toFirestore: (product, options) => product.toJson(),
        )
        .snapshots();
  }

  void _addProduct(ProductEventAdd event, Emitter emit) async {
    emit(ProductStateLoadingAdd());
    try {
      final CollectionReference productsCollection =
          firestore.collection('products');

      // Function to add a new product to the Firestore collection
      var result = await productsCollection.add(
        {
          'name': event.product.name,
          'quantity': event.product.quantity,
          'code': event.product.code,
        },
      );

      await productsCollection.doc(result.id).update({"productId": result.id});

      emit(ProductStateSuccessAdd());
    } on FirebaseException catch (e) {
      emit(ProductStateError(e.message ?? 'Failed Adding Product'));
    } catch (e) {
      emit(ProductStateError(e.toString()));
    }
  }

  void _scanQrCode(ProductEventQrScan event, Emitter emit) async {
    emit(ProductStateLoadingQR());
    try {
      String productScannedId = await FlutterBarcodeScanner.scanBarcode(
          '#000000', 'CANCEL', true, ScanMode.DEFAULT);

      var results = await firestore
          .collection('products')
          .doc(productScannedId)
          .withConverter<ProductModel>(
            fromFirestore: (snapshot, options) =>
                ProductModel.fromJson(snapshot.data()!),
            toFirestore: (product, options) => product.toJson(),
          )
          .get();

      if (results.data() == null) {
        emit(ProductStateError('Product not Found'));
      }

      ProductModel productData = results.data()!;

      emit(ProductStateSuccessQR(product: productData));
    } on FirebaseException catch (e) {
      emit(ProductStateError(e.message ?? 'Failed Adding Product'));
    } catch (e) {
      emit(ProductStateError(e.toString()));
    }
  }

  void _deleteProduct(ProductEventDelete event, Emitter emit) async {
    emit(ProductStateLoadingDelete());
    try {
      final CollectionReference productsCollection =
          firestore.collection('products');

      // Function to add a new product to the Firestore collection
      await productsCollection.doc(event.productId).delete();

      emit(ProductStateSuccessDelete());
    } on FirebaseException catch (e) {
      emit(ProductStateError(e.message ?? 'Failed Deleting Product'));
    } catch (e) {
      emit(ProductStateError(e.toString()));
    }
  }

  void _editProduct(ProductEventEdit event, Emitter emit) async {
    emit(ProductStateLoadingEdit());
    try {
      final CollectionReference productsCollection =
          firestore.collection('products');

      var product = event.product;

      await productsCollection
          .doc(product.productId)
          .update({"name": product.name, 'quantity': product.quantity});

      emit(ProductStateSuccessEdit());
    } on FirebaseException catch (e) {
      emit(ProductStateError(e.message ?? 'Failed Editing Product'));
    } catch (e) {
      emit(ProductStateError(e.toString()));
    }
  }

  void _exportPdf(ProductEventExportPdf event, Emitter emit) async {
    emit(ProductStateLoadingPDF());
    try {
      var results = await firestore
          .collection('products')
          .withConverter<ProductModel>(
            fromFirestore: (snapshot, options) =>
                ProductModel.fromJson(snapshot.data()!),
            toFirestore: (product, options) => product.toJson(),
          )
          .get();

      List<ProductModel> data = <ProductModel>[];

      for (var item in results.docs) {
        data.add(item.data());
      }

      if (data.isEmpty) {
        emit(ProductStateError('You have no product, add product to export'));
      }

      var fontData =
          await rootBundle.load('assets/fonts/opensans/OpenSans-Regular.ttf');
      var fontDataBold =
          await rootBundle.load('assets/fonts/opensans/OpenSans-Bold.ttf');

      var font = pw.Font.ttf(fontData);
      var fontBold = pw.Font.ttf(fontDataBold);

      var pdfTextStyle = pw.TextStyle(font: font, fontSize: 11);
      var pdfHeaderTextStyle = pw.TextStyle(font: fontBold, fontSize: 14);

      final pdf = pw.Document();

      pdf.addPage(
        MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return [
              pw.Center(
                child: pw.Text('PRODUCT CATALOG', style: pdfHeaderTextStyle),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            'CODE',
                            style: pdfHeaderTextStyle,
                          ),
                          pw.SizedBox(height: 4),
                        ],
                      ),
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Text(
                              'NAME',
                              style: pdfHeaderTextStyle,
                            ),
                            pw.SizedBox(height: 4),
                          ]),
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Text(
                              'QUANTITY',
                              style: pdfHeaderTextStyle,
                            ),
                            pw.SizedBox(height: 4),
                          ]),
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Text(
                              'QR CODE',
                              style: pdfHeaderTextStyle,
                            ),
                            pw.SizedBox(height: 4),
                          ]),
                    ],
                  ),
                  ...data.map((item) {
                    return pw.TableRow(
                      verticalAlignment: pw.TableCellVerticalAlignment.middle,
                      children: [
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.SizedBox(height: 5),
                              pw.Container(
                                height: 50,
                                child: pw.Text(
                                  item.code,
                                  style: pdfTextStyle,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                            ]),
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.SizedBox(height: 5),
                              pw.Container(
                                height: 50,
                                child: pw.Text(
                                  item.name,
                                  style: pdfTextStyle,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                            ]),
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.SizedBox(height: 5),
                              pw.Container(
                                height: 50,
                                child: pw.Text(
                                  item.quantity.toString(),
                                  style: pdfTextStyle,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                            ]),
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.SizedBox(height: 5),
                              pw.BarcodeWidget(
                                  data: item.productId!,
                                  barcode: pw.Barcode.qrCode(),
                                  width: 50,
                                  height: 50),
                              pw.SizedBox(height: 5),
                            ]),
                      ],
                    );
                  }).toList()
                ],
              )
            ];
          },
        ),
      );

      Uint8List bytes = await pdf.save();

      final dir = await getApplicationDocumentsDirectory();
      File file = File('${dir.path}/products.pdf');

      await file.writeAsBytes(bytes);

      await OpenFile.open(file.path);

      emit(ProductStateSuccessExport());
    } on FirebaseException catch (e) {
      emit(ProductStateError(e.message ?? 'Failed Adding Product'));
    } catch (e) {
      emit(ProductStateError(e.toString()));
    }
  }
}
