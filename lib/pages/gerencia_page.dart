import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';
import 'package:delivery/pages/import.dart';
import 'package:delivery/res/import.dart';
import 'package:flutter/material.dart';

class GerenciaPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<GerenciaPage> {

  //region variaveis

  final Map<String, Pedido> _pedidos = Map();
  bool _inProgress = false;

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    var list = _pedidos.values.toList()..sort((a, b) => a.data.compareTo(b.data));

    return Scaffold(
        appBar: AppBar(
          title: OkiAppBarText('PEDIDOS'),
          actions: [
            IconButton(
                tooltip: 'Atualizar',
                icon: Icon(Icons.refresh),
                onPressed: _onRefresh
            ),
          ],
        ),
        body: ListView.builder(
          padding: EdgeInsets.only(bottom: 100),
          itemCount: _pedidos.length,
          itemBuilder: (context, index) {
            Pedido item = list[index];
            return PedidoLayout(item,
              onTap: _onPedidoClick,
            );
          },
        ),
        bottomSheet: BottomSheet(
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (FirebaseOki.userOki.isGerente || FirebaseOki.isAdmin)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                        Expanded(child: FlatButton(
                          color: OkiTheme.accent,
                          child: OkiAppBarText('Adicionar Produto'),
                          onPressed: _onAddProdutoClick,
                        )),
                      SizedBox(width: 3),
                      Expanded(child: FlatButton(
                        color: OkiTheme.accent,
                        child: OkiAppBarText('Adicionar Combo'),
                        onPressed: _onAddComboClick,
                      )),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (FirebaseOki.userOki.isGerente || FirebaseOki.isAdmin)
                        Expanded(child: FlatButton(
                          color: OkiTheme.accent,
                          child: OkiAppBarText('Estabelecimento'),
                          onPressed: _onEstabelecimentoClick,
                        )),
                      SizedBox(width: 3),
                      Expanded(child: FlatButton(
                        color: OkiTheme.accent,
                        child: OkiAppBarText('Funcionários'),
                        onPressed: _onFuncionarioClick,
                      )),
                    ],
                  ),
              ],
            );
          },
          onClosing: () {},
        ),
        floatingActionButton: _inProgress ? Padding(
            padding: EdgeInsets.only(bottom: 60),
            child: CircularProgressIndicator()
        ) : null,
    );
  }

  //endregion

  //region metodos

  void _init() async {
    _setInProgress(true);

    _pedidos.addAll(Pedidos.instance.data);

    var temp = await Pedidos.instance.baixar(save: true);
    if (temp != null) {
      _pedidos.clear();
      _pedidos.addAll(temp);
      Pedidos.instance.save();
    }

    for (var value in _pedidos.values) {
      if (value.user == null) {
        UserOki temp = Funcionarios.instance.getUser(value.idCliente);
        if (temp == null)
          await Funcionarios.instance.baixar();
        temp = Funcionarios.instance.getUser(value.idCliente);
        value.user = temp;
      }
    }

    _setInProgress(false);
  }

  void _onRefresh() {
    _init();
  }

  void _onPedidoClick(Pedido item) async {
    var result = await Navigate.to(context, _PedidoFragment(item));
    if (result != null && result is _PedidoFragmentResult)
      if (result == _PedidoFragmentResult.pedido_recusado)
        _pedidos.remove(item.id);

    setState(() {});
  }

  void _onAddProdutoClick() async {
    await Navigate.to(context, AddProdutoFragment());
    setState(() {});
  }

  void _onFuncionarioClick()  {
    Navigate.to(context, FuncionariosPage());
  }

  void _onEstabelecimentoClick() {
    Navigate.to(context, EstabelecimentoPage());
  }

  void _onAddComboClick() {
    Navigate.to(context, AddComboPage());
  }

  void _setInProgress(bool b) {
    if (!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}

enum _PedidoFragmentResult {
  pedido_recusado
}

class _PedidoFragment extends StatefulWidget {
  final Pedido item;
  _PedidoFragment(this.item);
  @override
  State<StatefulWidget> createState() => _StateFragment(item);
}
class _StateFragment extends State<_PedidoFragment> {

  //region variaveis

  final Pedido pedido;
  final Pedido pedidoAux = Pedido('');

  UserOki user;

  int currentStatus = 1;
  bool _inProgress = false;
  bool _showSaveButton = false;

  //endregion

  _StateFragment(this.pedido);

  //region overrides

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (pedido.status != currentStatus) {
          var title = 'Você não salvou o status do pedido';
          var content = [
            OkiText('Deseja sair mesmo assim?')
          ];
          var result = await DialogBox.simNao(context, title: title, content: content);
          return result.isPositive;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: OkiAppBarText('PEDIDO'),
          actions: [
            if (FirebaseOki.hasAcessoEspecialOrIsAdmin)
              IconButton(
                tooltip: 'Recusar Pedido',
                icon: Icon(Icons.block,
                  color: Colors.red,
                ),
                onPressed: _onBlock,
              ),
          ],
        ),
        body: pedido == null || pedido.produtos.isEmpty ?
        Center(child: OkiTitleText('Sem itens')):
        ListView.builder(
            padding: EdgeInsets.only(bottom: 180),
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
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    // leading: OkiClipRRect(child: Image.network(item.foto)),
                    title: OkiTitleText(item.nome),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OkiText(item.categoria),
                        // OkiText('R\$ ${(item.preco * quantItems).toStringAsFixed(2)}'),
                        Text('Quant: $quantItems', style: TextStyle(color: OkiTheme.accent)),
                      ],
                    ),
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
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    // leading: OkiClipRRect(child: Image.network(p.foto)),
                    title: OkiTitleText(item.nome),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OkiText('Combo'),
                        OkiText('Quant: $quantItems'),
                      ],
                    ),
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
              padding: EdgeInsets.only(left: 10, bottom: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user != null)
                    UserLayout(
                      user: user,
                      isCliente: true,
                      onTap: _onUserClick,
                    ),

                  OkiTitleText('Status: ${pedidoAux.statusS}'),
                  _statusControle()
                ],
              ),
            );
          },
          onClosing: () {},
        ),
        floatingActionButton: _inProgress ? CircularProgressIndicator() :
        _showSaveButton ?
        FloatingActionButton.extended(
            label: OkiAppBarText('Salvar Status'),
            onPressed: _onSalvar
        ) : null,
      )
    );
  }

  //endregion

  //region metodos

  void _init() async {
    currentStatus = pedido.status;
    pedidoAux.status = pedido.status;

    user = Funcionarios.instance.getUser(pedido.idCliente);

    if (user == null) {
      _setInProgress(true);
      await Funcionarios.instance.baixar();
      _setInProgress(false);
    }
    user = Funcionarios.instance.getUser(pedido.idCliente);
    setState(() {});
  }

  Widget _statusControle() {
    double circleSize = 30;

    Color colorOn = Colors.green;
    Color colorOff = Colors.grey;

    SizedBox divider = SizedBox(width: 3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Anterior',
            icon: Icon(Icons.arrow_back),
            onPressed: _onAnterior
        ),
        Spacer(),
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
            height: circleSize,
              width: circleSize,
              color: currentStatus == 1 ? colorOn : colorOff,
            child: Center(child: OkiAppBarText(1.toString())),
          ),
        ),
        divider,
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
            height: circleSize,
            width: circleSize,
            color: currentStatus == 2 ? colorOn : colorOff,
            child: Center(child: OkiAppBarText(2.toString())),
          ),
        ),
        divider,
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
            height: circleSize,
            width: circleSize,
            color: currentStatus == 3 ? colorOn : colorOff,
            child: Center(child: OkiAppBarText(3.toString())),
          ),
        ),
        divider,
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
            height: circleSize,
            width: circleSize,
            color: currentStatus == 4 ? colorOn : colorOff,
            child: Center(child: OkiAppBarText(4.toString())),
          ),
        ),
        Spacer(),
        IconButton(
          tooltip: 'Próximo',
            icon: Icon(Icons.arrow_forward_rounded),
            onPressed: _onProx
        ),
      ],
    );
  }

  void _onProx() async {
    if (currentStatus < 4)
    setState(() {
      currentStatus++;
      pedidoAux.status = currentStatus;
      _showSaveButton = true;
    });
  }

  void _onAnterior() async {
    if (currentStatus > 1)
    setState(() {
      currentStatus--;
      pedidoAux.status = currentStatus;
      _showSaveButton = true;
    });
  }

  void _onSalvar() async {
    _setInProgress(true);

    pedido.status = currentStatus;
    if (await pedido.salvar()) {
      Log.snack('Status Salvo');
    } else
      Log.snack('Ocorreu um erro', isError: true);

    _showSaveButton = false;
    _setInProgress(false);
  }

  void _onBlock() async {
    var title = 'Recusar esse pedido?';
    var notShowAgainText = 'Notificar o cliente';
    bool sendNotfication = false;

    void onNotShowAgain(bool value) {sendNotfication = value;}

    var result = await DialogBox.simNao(context, title: title, notShowAgainText: notShowAgainText, onNotShowAgain: null);
    if (!result.isPositive)
      return;

    _setInProgress(true);
    if (await pedido.delete(ignoreStatus: true)) {
      Log.snack('Pedido recusado');
      Navigator.pop(context, _PedidoFragmentResult.pedido_recusado);
    } else
      Log.snack(MyErros.ERRO_GENERICO, isError: true);
    _setInProgress(false);
  }

  void _onProdutoClick(Produto item) {
    Navigate.to(context, ProdutoPage(produto: item, readOnly: true));
  }

  void _onComboClick(Combo item) {
    Navigate.to(context, ComboPage(item, readOnly: true));
  }

  void _onUserClick(UserOki item) {
    var end = item.dados.endereco;

    var title = 'Endereço';
    var content = [
      OkiText('Cidade: ${end.cidade}'),
      OkiText('Bairro: ${end.bairro}'),
      OkiText('Rua: ${end.rua}'),
      OkiText('Número: ${end.numero}'),
      if (end.complemento.isNotEmpty)
        OkiText('Complemento: ${end.complemento}'),
    ];
    DialogBox.ok(context, title: title, content: content);
  }

  void _setInProgress(bool b) {
    if (!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}