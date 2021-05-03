import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';
import 'package:delivery/pages/import.dart';
import 'package:delivery/res/import.dart';
import 'package:flutter/material.dart';

enum PedidoPageResult {
  pedido_cancelado, pedido_finalizado
}

class PedidoPage extends StatefulWidget {
  final Pedido item;

  PedidoPage(this.item);
  @override
  State<StatefulWidget> createState() => _State(item);
}
class _State extends State<PedidoPage> {

  //region variaveis

  final Pedido pedido;

  bool _inProgress = false;

  _State(this.pedido);

  //endregion

  //region overrides

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: OkiAppBarText('Meu Pedido')),
      body: pedido == null || (pedido.produtos.isEmpty && pedido.combos.isEmpty) ?
      Center(child: OkiTitleText('Sem itens')):
      ListView.builder(
          padding: EdgeInsets.only(bottom: 100),
          itemCount: pedido.produtos.length + pedido.combos.length,
          itemBuilder: (context, index) {
            if (index < pedido.produtos.length) {
              String produtoId = pedido.produtos.keys.toList()[index];
              int quantItems = pedido.produtos.values.toList()[index];

              Produto item = Produtos.instance.get(produtoId);
              if (item == null)
                return ListTile(title: OkiText('Produto indisponível'));

              return Container(
                decoration: Styles.decoration,
                child: ListTile(
                  // leading: OkiClipRRect(child: Image.network(item.foto)),
                  title: OkiTitleText(item.nome),
                  subtitle: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OkiText(item.categoria),
                      OkiText('R\$ ${(item.preco * quantItems).toStringAsFixed(2)}'),
                      OkiText('Quant: $quantItems'),
                    ],
                  ),
                  trailing: pedido.status == 0 ? IconButton(
                    tooltip: 'Remover',
                    icon: Icon(Icons.delete_forever),
                    onPressed: () => _onRemove(item),
                  ) : null,
                  onTap: () => _onProdutoClick(item),
                ),
              );
            } else {
              String itemId = pedido.combos.keys.toList()[index - pedido.produtos.length];
              int quantItems = pedido.combos.values.toList()[index - pedido.produtos.length];

              Combo item = Produtos.instance.getCombo(itemId);
              if (item == null)
                return ListTile(title: OkiText('Combo indisponível'));

              // Produto p = item.getProduto(0);

              return Container(
                decoration: Styles.decoration,
                child: ListTile(
                  // leading: OkiClipRRect(child: Image.network(p.foto)),
                  title: OkiTitleText(item.nome),
                  subtitle: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OkiText('R\$ ${(item.preco * quantItems).toStringAsFixed(2)}'),
                      OkiText('Quant: $quantItems'),
                    ],
                  ),
                  trailing: pedido.status == 0 ? IconButton(
                    tooltip: 'Remover',
                    icon: Icon(Icons.delete_forever),
                    onPressed: () => _onRemoveCombo(item),
                  ) : null,
                  onTap: () => _onComboClick(item),
                ),
              );
            }
          }
      ),
      bottomSheet: BottomSheet(
        builder: (context) {
          return Container(
            decoration: Styles.decoration,
            width: double.infinity,
            height: 60,
            padding: EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OkiTitleText('Total: R\$ ${pedido.total.toStringAsFixed(2)}'),
            ),
          );
        },
        onClosing: () {},
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() :
      _floatButton(pedido.status),
    );
  }

  //endregion

  //region metodos

  Widget _floatButton(int status) {
    if (status == 0)
      return FloatingActionButton.extended(
          label: OkiAppBarText('Concluir Pedido'),
          onPressed: _onCloncluir
      );
    if (status == 1)
      return FloatingActionButton.extended(
          label: OkiAppBarText('Cancelar Pedido'),
          onPressed: _onCancelar
      );
    return null;
  }

  void _onRemove(Produto item) async {
    var title = 'Remover este item?';
    var content = [
      OkiTitleText(item.nome),
      OkiText(item.categoria),
    ];
    var result = await DialogBox.simNao(context, title: title, content: content);
    if (result.isPositive) {
      pedido.produtos.remove(item.id);
      pedido.data = '';
      setState(() {});
    }
  }

  void _onRemoveCombo(Combo item) async {
    var title = 'Remover este item?';
    var content = [
      OkiTitleText(item.nome),
    ];
    var result = await DialogBox.simNao(context, title: title, content: content);
    if (result.isPositive) {
      pedido.combos.remove(item.id);
      pedido.data = '';
      setState(() {});
    }
  }

  void _onProdutoClick(Produto item) {
    Navigate.to(context, ProdutoPage(produto: item, readOnly: true));
  }

  void _onComboClick(Combo item) {
    Navigate.to(context, ComboPage(item, readOnly: true));
  }

  void _onCloncluir() async {
    if (pedido.produtos.isEmpty)
      return;

    if (!await Aplication.checkLogin(context))
      return;

    if (FirebaseOki.userOki.dados.endereco.isIncompleto) {
      var title = 'Endereço';
      var content = [
        OkiText('Seu endereço está incompleto'),
        OkiText('Para podermos realizar sua entrega, você precisa informar seu endereço.'),
        OkiText('Deseja inserir seu endereço agora?'),
      ];
      var result = await DialogBox.simNao(context, title: title, content: content);
      if (!result.isPositive)
        return;

      await Navigate.to(context, PerfilPage());
      _onCloncluir();
      return;
    }

    _setInProgress(true);

    if (pedido.data.isEmpty)
      pedido.data = DataHora.now();
    if (pedido.id == null || pedido.id.isEmpty)
      pedido.id = Cript.randomString();
    pedido.idCliente = FirebaseOki.user.uid;
    pedido.status = 1;

    if (await pedido.salvar()) {
      Pedidos.instance.add(pedido: pedido);
      Pedidos.instance.resetTemp();
      Pedidos.instance.save();
      NotificationManager.instance.sendPedidoTopic(pedido);
      Log.snack('Pedido Concluido');
      Navigator.pop(context, PedidoPageResult.pedido_finalizado);
    } else
      Log.snack('Ocorreu um erro', isError: true);

    _setInProgress(false);
  }

  void _onCancelar() async {
    var title = 'Cancelar pedido';
    var content = [
      OkiText('Deseja continuar com o cancelamento do seu pedido?')
    ];
    var result = await DialogBox.simNao(context, title: title, content: content);
    if (!result.isPositive)
      return;

    _setInProgress(true);

    int status = await pedido.checkStatus();
    if ((status ?? 0) > 1) {
      var title = 'Pedido em processo';
      var content = [
        OkiText('Seu pedido já está em curso e não poderá ser cancelado.')
      ];
      DialogBox.ok(context, title: title, content: content);
      _setInProgress(false);
      return;
    }

    if (await pedido.delete(ignoreStatus: true)) {
      Pedidos.instance.remove(pedido: pedido);
      Pedidos.instance.save();
      Log.snack('Pedido Cancelado');
      Navigator.pop(context, PedidoPageResult.pedido_cancelado);
    } else
      Log.snack('Ocorreu um erro', isError: true);

    _setInProgress(false);
  }

  void _setInProgress(bool b) {
    if (!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}