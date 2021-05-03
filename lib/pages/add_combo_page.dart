import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';
import 'package:delivery/res/import.dart';
import 'package:flutter/material.dart';

class AddComboPage extends StatefulWidget {
  final Combo combo;
  AddComboPage([this.combo]);
  @override
  State<StatefulWidget> createState() => _State(Combo.fromJson(combo?.toJson()));
}
class _State extends State<AddComboPage> {

  //region Variáveis
  final Combo combo;

  Map<String, Produto> items = Map();
  Map<String, Produto> itemsTemp = Map();

  bool nomeIsEmpty = false;
  bool precoIsEmpty = false;
  bool itemsIsEmpty = false;

  bool _canPublique = false;

  var cNome = TextEditingController();
  var cPreco = TextEditingController();

  bool _inProgress = false;
  //endregion

  _State(this.combo);

  //region overrides

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: OkiAppBarText('NOVO COMBO'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetDados,
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 80),
        children: [
          OkiTextField(
            label: 'Nome',
            controller: cNome,
            valueIsEmpty: nomeIsEmpty,
            onTap: () {
              setState(() {
                nomeIsEmpty = false;
              });
            },
          ),
          OkiTextField(
            label: 'Preço',
            hint: 'R\$ 0.00',
            prefixText: 'R\$',
            helperText: 'Somente números e ponto',
            controller: cPreco,
            valueIsEmpty: precoIsEmpty,
            keyboardType: TextInputType.number,
            onTap: () {
              setState(() {
                precoIsEmpty = false;
              });
            },
          ),
          OkiChechbox(
            text: 'Habilitar Venda',
            value: _canPublique,
            onChanged: _onCanPubliqueChanged,
          ),

          Divider(),
          if (itemsIsEmpty)
            OkiErrorText('Sem Itens adicionados'),
          if (items.isNotEmpty)...[
            OkiText('Itens adicionados'),
            SizedBox(height: 5),
          ],
          for (var item in items.values)
            ProdutoLayout(
              item,
              showQuantidade: true,
              showCategoria: true,
              trailing: IconButton(
                icon: Icon(Icons.delete_forever),
                onPressed: () => _onRemoveItem(item),
              ),
            ),
          Divider(),
          if (itemsTemp.isNotEmpty)...[
            OkiText('Itens não adicionados'),
            SizedBox(height: 5),
          ],
          for (var item in itemsTemp.values)
            ProdutoLayout(
              item,
              showCategoria: true,
              trailing: IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _onAddItem(item),
              ),
            )
        ],
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() :
      FloatingActionButton.extended(
        label: OkiAppBarText('Salvar'),
        onPressed: _onSalvarClick,
      ),
    );
  }

  //endregion

  //region metodos

  void _init() {
    itemsTemp.addAll(Produtos.instance.data);

    if (combo != null) {
      cNome.text = combo.nome;
      cPreco.text = combo.preco.toStringAsFixed(2);
      _canPublique = combo.isAVenda;

      combo.items.forEach((key, value) {
        var temp = itemsTemp[key];
        if (temp != null)
          items[key] = temp..quantidade = value;
        itemsTemp.remove(key);
      });
    }
  }

  void _onAddItem(Produto item) async {
    var controller = TextEditingController();

    var title = item.nome;
    var content = [
      OkiTextField(
        hint: 'Quantidade',
        controller: controller,
        keyboardType: TextInputType.number,
      )
    ];
    var result = await DialogBox.cancelOK(context, title: title, content: content);
    if (result.isPositive && controller.text.isNotEmpty) {
      int quant = int.tryParse(controller.text);
      setState(() {
        items[item.id] = item..quantidade = quant;
        itemsTemp.remove(item.id);
        itemsIsEmpty = false;
      });
    }
  }

  void _onRemoveItem(Produto item) {
    setState(() {
      items.remove(item.id);
      itemsTemp[item.id] = item..quantidade = 0;
    });
  }

  void _onCanPubliqueChanged(bool value) {
    setState(() {
      _canPublique = value;
    });
  }

  void _onSalvarClick() async {
    var item = _criarObj();
    if (_verificarDados(item)) {
      _setInProgress(true);
      if (await item.salvar()) {
        Log.snack(MyTexts.DADOS_SALVOS);
        Produtos.instance.add(combo: item);
        _resetDados();
      } else {
        Log.snack(MyErros.ERRO_GENERICO, isError: true);
      }
    }

    _setInProgress(false);
  }

  Combo _criarObj() {
    var item = combo;
    if (item == null) {
      item = Combo();
      item.id = Cript.randomString();
    }

    item.nome = cNome.text;
    item.preco = double.tryParse(cPreco.text);
    item.isAVenda = _canPublique;
    items.forEach((key, value) {
      item.items[key] = value.quantidade;
    });
    return item;
  }

  bool _verificarDados(Combo item) {
    try {
      nomeIsEmpty = item.nome.isEmpty;
      precoIsEmpty = item.preco == 0;
      itemsIsEmpty = item.items.isEmpty;
      setState(() {});

      if (nomeIsEmpty) throw('');
      if (precoIsEmpty) throw('');
      if (itemsIsEmpty) throw('');
    } catch(e) {
      return false;
    }
    return true;
  }

  void _resetDados() {
    items.clear();
    itemsTemp.clear();
    itemsTemp.addAll(Produtos.instance.data);

    cNome.text = '';
    cPreco.text = '';
    setState(() {});
  }

  void _setInProgress(bool b ) {
    if (!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}