import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(id: null,title: '',price: 0,imageUrl: '',description: '');
  var _initValues = {
    'title':'',
    'description':'',
    'price':'',
    'imageUrl':'',

  };
  var _isInit = true;
  var _isLoading = false;
  @override

  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
   if(_isInit) {
     final productId = ModalRoute.of(context).settings.arguments as String;
     if(productId !=null) {
     _editedProduct = Provider.of<Products>(context,listen: false).findById(productId);
   _initValues = {
     'title': _editedProduct.title,
     'description': _editedProduct.description,
     'price': _editedProduct.price.toString(),
     //'imageUrl': _editedProduct.imageUrl,
     'imageUrl':'',
   };
   _imageUrlController.text = _editedProduct.imageUrl;
   }
   }
     _isInit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl(){
          if(!_imageUrlFocusNode.hasFocus){
            if(_imageUrlController.text.isEmpty || !_imageUrlController.text.startsWith('http') || (!_imageUrlController.text.endsWith('.png') && !_imageUrlController.text.endsWith('.jpg') && !_imageUrlController.text.endsWith('jpeg')))
              return ;
            setState(() {});
          }
  }
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveFrom() async{
    final isValid = _form.currentState.validate();
    if(!isValid){
      return ;
    }
   _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    if(_editedProduct.id!=null){
     await Provider.of<Products>(context,listen: false).updateProduct(_editedProduct.id,_editedProduct);
      setState(() {
        _isLoading = false;
      });

    }else {
      try{
        await  Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
        }catch(error) {
        return showDialog(context: context,
            builder: (ctx) => AlertDialog(title: Text("An error occurred!"),content: Text('Something Went Wrong'),
              actions: [
                FlatButton(child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },)
              ],));
         }
//         finally{
//        Navigator.of(context).pop();
//        setState(() {
//          _isLoading = false;
//        });
//      }
    }
    Navigator.of(context).pop();

    }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(icon: Icon(Icons.save),
            onPressed: _saveFrom,
          )
        ],

      ),
      body: _isLoading?Center(child: CircularProgressIndicator(),)
      :Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
            child: ListView(
          children: [
            TextFormField(
              initialValue: _initValues['title'],
              decoration: InputDecoration(labelText: 'Title'),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_priceFocusNode);
              },
              validator: (value) {
                if(value.isEmpty)
                  return 'Please Provide Value';
                return null;
              },
              onSaved: (value){
                _editedProduct = Product(
                  title: value,
                  price: _editedProduct.price,
                  description: _editedProduct.description,
                  imageUrl: _editedProduct.imageUrl,
                  id:_editedProduct.id,
                  isFavorite: _editedProduct.isFavorite,

                );
              },
            ),
            TextFormField(
                initialValue: _initValues['price'],
              decoration: InputDecoration(labelText: 'Price'),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              focusNode: _priceFocusNode,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_descriptionFocusNode);
              },
              validator: (value) {
                if(value.isEmpty)
                  return 'Please enter a price.';
                else if (double.tryParse(value)==null)
                  return 'Please enter a valid Number';
                else if (double.parse(value)<=0)
                  return 'Please Enter a number greater than 0';
                return null;
              },
              onSaved: (value){
                _editedProduct = Product(
                  title: _editedProduct.title,
                  price: double.parse(value),
                  description: _editedProduct.description,
                  imageUrl: _editedProduct.imageUrl,
                  id:_editedProduct.id,
                  isFavorite: _editedProduct.isFavorite,

                );

              },
            ),
            TextFormField(
              initialValue: _initValues['description'],
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              focusNode: _descriptionFocusNode,
              validator: (value) {
                if(value.isEmpty)
                  return 'Please enter a Description';
                else if (value.length<10)
                  return 'Should be at least 10 characters long';
                return null;
              },
              onSaved: (value){
                _editedProduct = Product(
                  title: _editedProduct.title,
                  price: _editedProduct.price,
                  description: value,
                  imageUrl: _editedProduct.imageUrl,
                  id:_editedProduct.id,
                  isFavorite: _editedProduct.isFavorite,

                );
              },
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  margin: EdgeInsets.only(top: 8, right: 10),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                  ),
                  child: _imageUrlController.text.isEmpty
                      ? Text('Enter a URL')
                      : FittedBox(
                          child: Image.network(_imageUrlController.text),
                     fit: BoxFit.cover,
                        ),
                ),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Image URL',
                    ),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    controller: _imageUrlController,
                    focusNode: _imageUrlFocusNode,
                    onFieldSubmitted: (_) {
                      _saveFrom();
                    },
                    validator: (value) {
                      if(value.isEmpty)
                        return 'Please Enter Image URL';
                      else if (!value.startsWith('http'))
                        return 'Please Enter a valid URL';
                      else if (!value.endsWith('.png') && !value.endsWith('.jpg') && !value.endsWith('jpeg'))
                        return 'Please Enter a valid URL';
                      return null;
                    },
                    onSaved: (value){
                      _editedProduct = Product(
                        title: _editedProduct.title,
                        price: _editedProduct.price,
                        description: _editedProduct.description,
                        imageUrl: value,
                        id:_editedProduct.id,
                        isFavorite: _editedProduct.isFavorite,

                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        )),
      ),
    );
  }
}
