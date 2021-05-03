import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';
import 'package:delivery/res/import.dart';
import 'package:flutter/material.dart';
import 'import.dart';

enum PageResult {
  itemExcluido
}

class ComboPage extends StatefulWidget {
  final Combo combo;
  final bool readOnly;
  ComboPage(this.combo, {this.readOnly = false});

  @override
  State<StatefulWidget> createState() => _State(combo, readOnly);
}
class _State extends State<ComboPage> {

  //region Variáveis
  final Combo combo;
  final bool readOnly;

  int quant = 0;
  double total = 0;

  bool _showOkButton = false;
  bool produtoAdicionado = true;

  bool _inProgress = false;
  //endregion

  _State(this.combo, this.readOnly);

  //region overrides

  @override
  void initState() {
    super.initState();
    total = Pedidos.instance.tempPrecoTotal;
  }

  @override
  Widget build(BuildContext context) {
    var list = combo.toList();

    return Scaffold(
      appBar: AppBar(
        title: OkiAppBarText('Combo ${combo.nome}'),
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
      body: ListView.builder(
        itemCount: combo.itemsD.length,
        padding: EdgeInsets.only(bottom: 170),
        itemBuilder: (context, index) {
          Produto item = list[index];
          return ProdutoLayout(
            item,
            showQuantidade: true,
            showPreco: false,
            showCategoria: true,
            onTap: _onProdutoClick,
          );
        },
      ),
      bottomSheet: readOnly ? _preco() :
      BottomSheet(
        builder: (context) {
          return Container(
            decoration: Styles.decoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _preco(),
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
                    OkiText('R\$: ${(combo.preco * quant).toStringAsFixed(2)}'),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, bottom: 10),
                  child: OkiTitleText('Total: R\$ ${total.toStringAsFixed(2)}'),
                )
              ],
            ),
          );
        },
        onClosing: () {},
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() :
      _showOkButton ?
      FloatingActionButton.extended(
        label: OkiAppBarText(quant == 0 ? 'OK' : 'Adicionar'),
        onPressed: _onOK,
      ) : null,
    );
  }

  //endregion

  //region metodos

  Widget _preco() {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Text(
        'R\$ ${combo.preco.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 22,
          color: Colors.red
        ),
      ),
    );
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

  void _onProdutoClick(Produto item) {
    Navigate.to(context, ProdutoPage(produto: item, readOnly: true));
  }

  void _onEditClick() async {
    await Navigate.to(context, AddComboPage(combo));
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
      if (await combo.delete()) {
        Log.snack('Item Excluido');
        Produtos.instance.remove(combo: combo);
        Navigator.pop(context, PageResult.itemExcluido);
      } else
        Log.snack(MyErros.ERRO_GENERICO, isError: true);
      _setInProgress(false);
    }
  }

  void _onOK() {
    _showOkButton = false;
    if (quant == 0) {
      _onRemove();
      return;
    }

    Pedidos.instance.add(combo: combo..quantidade = quant);

    setState(() {
      total = Pedidos.instance.tempPrecoTotal;
      produtoAdicionado = true;
    });
    Log.snack('Item Adicionado');
  }

  void _onRemove() {
    Pedidos.instance.remove(combo: combo);

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