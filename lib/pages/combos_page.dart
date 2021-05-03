import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';
import 'package:delivery/pages/combo_page.dart';
import 'package:delivery/res/import.dart';
import 'package:flutter/material.dart';

class CombosPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<CombosPage> {

  final Map<String, Combo> _data = Map();
  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    var list = _data.values.toList();

    return Scaffold(
      appBar: AppBar(title: OkiAppBarText('NOSSOS COMBOS'),),
      body: ListView.builder(
        itemCount: _data.length,
        itemBuilder: (context, index) {
          Combo item = list[index];
          return ComboLayout(
            item,
            trailing: item.isAVenda? null :
            IconButton(
              icon: Icon(Icons.info),
              onPressed: _onInfoClick,
            ),
            onTap: _onComboClick,
          );
        },

      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() : null,
    );
  }

  void _init() async {
    _data.addAll(Produtos.instance.combos);
    try {
      if (!FirebaseOki.isGerenteOrAdmin)
        _data.removeWhere((key, value) => !value.isAVenda);

      _setInProgress(true);

      var temp = await Produtos.instance.baixarCombos(save: true);
      if (temp != null)
        _data.addAll(temp);

      if (!FirebaseOki.isGerenteOrAdmin)
        _data.removeWhere((key, value) => !value.isAVenda);
    } catch (e, s) {
      print(s);
    }
    _setInProgress(false);
  }

  void _onComboClick(Combo item) async {
    var result = await Navigate.to(context, ComboPage(item));
    if (result != null && result is PageResult)
      if (result == PageResult.itemExcluido)
        setState(() {
          _data.remove(item.id);
        });
  }

  void _onInfoClick() {
    var title = 'Este Produto não está à venda.';
    var content = [OkiText('Este produto não é mostrado aos clientes enquanto não estiver à venda.')];
    DialogBox.ok(context, title: title, content: content);
  }

  void _setInProgress(bool b) {
    if (!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

}