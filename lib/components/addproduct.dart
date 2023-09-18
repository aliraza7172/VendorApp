import 'package:flutter/material.dart';

class AddProductForm extends StatefulWidget {
  final Function onSubmit;

  const AddProductForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productQuantityController = TextEditingController();

  @override
  void dispose() {
    _productNameController.dispose();
    _productPriceController.dispose();
    _productQuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Product'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _productPriceController,
                decoration: InputDecoration(labelText: 'Product Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _productQuantityController,
                decoration: InputDecoration(labelText: 'Product Quantity'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product quantity';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Add Product'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final productName = _productNameController.text;
              final productPrice = double.parse(_productPriceController.text);
              final productQuantity = int.parse(_productQuantityController.text);
              widget.onSubmit(productName, productPrice, productQuantity);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
