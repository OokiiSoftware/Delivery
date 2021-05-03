import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';
import 'package:delivery/pages/import.dart';
import 'package:delivery/res/import.dart';
import 'package:flutter/material.dart';

class ProdutosPage extends StatefulWidget {
  final List<dynamic> produtos;
  final bool useGoups;
  ProdutosPage({this.produtos, this.useGoups = true});

  @override
  State<StatefulWidget> createState() =>_State(produtos, useGoups);
}
class _State extends State<ProdutosPage> {
  String categoria = '';
  final bool useGoups;
  final List<dynamic> produtos;
  final Map<String, dynamic> data = Map();

  _State(this.produtos, this.useGoups);

  @override
  void initState() {
    super.initState();
    categoria = produtos[0].categoria;

    if (!FirebaseOki.isGerenteOrAdmin)
      produtos.removeWhere((x) => (x is Produto) && !x.isAVenda);
    produtos.forEach((item) {
      if (!FirebaseOki.isGerenteOrAdmin)
        if (item is ProdutoGroup)
          item.items.removeWhere((x) => !x.isAVenda);
      data[useGoups? item.nome : item.id] = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: OkiAppBarText(categoria.toUpperCase())),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          var item = data.values.toList()[index];
          if (item is Produto)
            return ProdutoLayout(
              item,
              trailing: item.isAVenda? null :
              IconButton(
                icon: Icon(Icons.info),
                onPressed: _onInfoClick,
              ),
              showTamanho: true,
              onTap: _onProdutoClick,
            );
          else if (item.items.length == 1)
            return ProdutoLayout(
              item.items[0],
              trailing: item.items[0].isAVenda? null :
              IconButton(
                icon: Icon(Icons.info),
                onPressed: _onInfoClick,
              ),
              onTap: _onProdutoClick,
            );
          else
            return ProdutoGroupLayout(
              item,
              onTap: _onProdutoGroupClick,
            );
        },
      ),
    );
  }

  void _onProdutoClick(Produto item) async {
    var result = await Navigate.to(context, ProdutoPage(produto: item));
    if (result != null && result is String) {
      if (result == 'item_excluido')
        setState(() {
            data.remove(useGoups? item.nome: item.id);
        });
    }
  }

  void _onProdutoGroupClick(ProdutoGroup item) async {
    if (item.items.isEmpty) {
      Log.snack('Sem Produtos', isError: true);
      return;
    }

    /*var result =*/ await Navigate.to(context, ProdutosPage(produtos: item.items
        .where((x) => x.isAVenda).toList()..sort(
        (a, b) => a.preco.compareTo(b.preco)
    ), useGoups: false));
    if (item.items.isEmpty)
      data.remove(item.nome);
    setState(() {});

    // if (result != null && result is String) {
    //   if (result == 'item_excluido')
    //     setState(() {
    //       produtos.remove(item);
    //     });
    // }
  }

  void _onInfoClick() {
    var title = 'Este Produto não está à venda.';
    var content = [OkiText('Este produto não é mostrado aos clientes enquanto não estiver à venda.')];
    DialogBox.ok(context, title: title, content: content);
  }
}