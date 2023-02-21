import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// text fields' controllers
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _precoController = TextEditingController();

  final CollectionReference _produtos =
  FirebaseFirestore.instance.collection('produtos');

  _criarProduto() async {

    await showDialog(context: context,
           builder: (BuildContext context) {
             return Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 AlertDialog(
                   content: Column(
                     children: [
                       TextField(

                       decoration: InputDecoration(
                       labelText: "Nome do produto",
               hintText: "Digite o nome do produto",
             ),
                         controller: _nomeController,
                         keyboardType: TextInputType.text,
             autofocus: true,),
                       TextField(
                         decoration: InputDecoration(
                           labelText: "Preço do produto",
                           hintText: "Digite o preço do produto"
                         ), keyboardType:
                       TextInputType.numberWithOptions(decimal: true),
                         controller: _precoController,
                       ),
                       ElevatedButton(onPressed: () async {
                         String preencheNome = await _nomeController.text;
                         double? preenchePreco = await double.tryParse(_precoController.text);
                         print('até aqui tá executando');
                         if(preenchePreco != null ) {

                           await _produtos.add({
                             'nome': preencheNome,
                             'preco': preenchePreco
                           });
                           _nomeController.text = "";
                           _precoController.text ="";
                           Navigator.pop(context);

                         }
                       },
                           child: Text("Criar item"))
                     ],
                   ),
                 )
               ],
             );
           });
  }
_update(DocumentSnapshot? documentSnapshot) async {
    if(documentSnapshot != null){
      _nomeController.text = documentSnapshot['nome'];
      _precoController.text = documentSnapshot['preco'].toString();
      await showDialog(context: context,
          builder: (BuildContext context ){
        return Column(
          children: [
            AlertDialog(
              title: Text("Editar"),
              content: Column(
                children: [
                  TextField(

                    decoration: InputDecoration(
                      labelText: "Editar nome",
                    ), keyboardType: TextInputType.text,
                    autofocus: true,
                    controller: _nomeController,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Preço do produto"
                    ), keyboardType: TextInputType.numberWithOptions(decimal: true),
                    controller: _precoController,
                  ),

                ],
              ),
              actions: [
                ElevatedButton(onPressed: () async {
                  String nomeProduto = _nomeController.text;
                  double? precoProduto = double.tryParse(_precoController.text);
                  if(precoProduto != null) {
                    await _produtos.doc(documentSnapshot!.id).update({
                      'nome': nomeProduto,
                      'preco': precoProduto
                    });
                    Navigator.pop(context);
                  }
                },
                    child: Text('Update'))
              ]
            ),


          ],

        );
          });
    }

  }
  _delete(String idProduto)async {
    await _produtos.doc(idProduto).delete();
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Item deletado")
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create, update and delete with Firestore"),
      ),
      body: StreamBuilder(
        stream: _produtos.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if(streamSnapshot.hasData){
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, indice){
                DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[indice];
                return Column(
                  children: [
                    ListTile(
                      title: Text(documentSnapshot['nome']),
                      subtitle: Text(documentSnapshot['preco'].toString()),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(onPressed: (){
                              _update(documentSnapshot);

                            },
                                icon: Icon(Icons.edit), ),
                            IconButton(onPressed: (){
                              _delete(documentSnapshot.id);

                            }, icon: Icon(Icons.delete))

                          ],
                        ),
                      ),
                      


                    )
                  ],

                );
          }


            );}
return Container();
        },

      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _criarProduto();
        },
      ),
    );
  }
}





















