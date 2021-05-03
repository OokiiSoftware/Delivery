import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';
import 'package:delivery/pages/import.dart';
import 'package:delivery/res/import.dart';
import 'package:flutter/material.dart';

class ProdutoPage extends StatefulWidget {
  final Produto produto;
  final bool readOnly;
  ProdutoPage({this.produto, this.readOnly = false});
  @override
  State<StatefulWidget> createState() => _State(produto, readOnly);
}
class _State extends State<ProdutoPage>{

  //region variaveis
  final Produto produto;
  final bool readOnly;

  int quant = 0;
  bool produtoAdicionado = false;
  double total = 0;

  bool _inProgress = false;
  bool _showOkButton = false;
  //endregion

  _State(this.produto, this.readOnly);

  //region overrides

  @override
  void initState() {
    super.initState();
    var temp = Pedidos.instance.getProduto(produto.id);
    if (temp != null) {
        quant = temp.quantidade;
      produtoAdicionado = quant > 0;
    }
    total = Pedidos.instance.tempPrecoTotal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: OkiAppBarText(produto.nome),
        actions: [
          if (FirebaseOki.isGerenteOrAdmin && !readOnly)...[
            IconButton(
                tooltip: 'Editar',
                icon: Icon(Icons.edit),
                onPressed: _onEditClick
            ),
            IconButton(
                tooltip: 'Excluir',
                icon: Icon(Icons.delete_forever),
                onPressed: _onDeleteClick
            ),
          ]
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 100),
        children: [
          // Image.network(produto.foto),
          ListTile(
            title: OkiTitleText(produto.nome),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OkiText('${produto.categoria}'),
                SizedBox(height: 5),
                OkiText('${produto.descricao}'),
                Divider(),
                Text(
                  'R\$: ${produto.preco.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: readOnly? null :
      BottomSheet(
        builder: (context) {
          return Container(
            decoration: Styles.decoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: _onMenos
                    ),
                    OkiText('$quant'),
                    IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _onMais
                    ),
                    OkiText('R\$: ${(produto.preco * quant).toStringAsFixed(2)}'),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, bottom: 10),
                  child: OkiTitleText('Total: R\$ ${total.toStringAsFixed(2)}'),
                )
              ],
            ),
          );
        },
        onClosing: () {},
      ),
      floatingActionButton: _inProgress ?
      CircularProgressIndicator() :
      _showOkButton ?
      FloatingActionButton.extended(
        label: OkiAppBarText(quant == 0 ? 'OK' : 'Adicionar'),
        onPressed: _onOK,
      ) : null,
    );
  }

  //endregion

  //region metodos

  void _onEditClick() async {
    await Navigate.to(context, AddProdutoFragment(produto));
    setState(() {});
  }

  void _onDeleteClick() async {
    var title = 'Excluir esse item?';
    var content = [
      OkiText('Clique em SIM para continuar.')
    ];
    var result = await DialogBox.simNao(context, title: title, content: content);
    if (result.isPositive) {
      _setInProgress(true);
      if (await produto.delete()) {
        Log.snack('Item Excluido');
        Produtos.instance.remove(produto: produto);
        Navigator.pop(context, 'item_excluido');
      } else
        Log.snack(MyErros.ERRO_GENERICO, isError: true);
      _setInProgress(false);
    }
  }

  void _onMais() {
    setState(() {
      quant++;
      _showOkButton = true;
    });
  }

  void _onMenos() {
    if (quant > 0)
      setState(() {
        quant--;
        _showOkButton = true;
      });
    }

  void _onOK() {
    _showOkButton = false;
    if (quant == 0) {
      _onRemove();
      return;
    }

    Pedidos.instance.add(produto: produto..quantidade = quant);

    setState(() {
      total = Pedidos.instance.tempPrecoTotal;
      produtoAdicionado = true;
    });
    Log.snack('Item Adicionado');
  }

  void _onRemove() {
    Pedidos.instance.remove(produto: produto);

    setState(() {
      produtoAdicionado = false;
      total = Pedidos.instance.tempPrecoTotal;
      quant = 0;
    });
  }

  void _setInProgress(bool b) {
    if (!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}