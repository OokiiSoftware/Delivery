import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';
import 'package:delivery/pages/import.dart';
import 'package:delivery/res/import.dart';
import 'package:flutter/material.dart';

class PedidosPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<PedidosPage> {

  //region variaveis

  final Map<String, Pedido> data = Map();
  bool _inProgress = false;

  Estabelecimento estb = Aplication.estabelecimento;

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    var list = data.values.toList()..sort((a, b) => a.data.compareTo(b.data));

    return Scaffold(
      appBar: AppBar(
        title: OkiAppBarText('Meus Pedidos'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
              icon: Icon(Icons.refresh),
              onPressed: _onRefresh
          )
        ],
      ),
      body: data.isEmpty ?
      Center(child: OkiTitleText('Sem pedidos')) :
      ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            Pedido item = list[index];

            return PedidoLayout(item,
              onTap: _onPedidoClick,
            );
          }
      ),
      bottomSheet: (estb == null) ? null :
      BottomSheet(
        builder: (context) {
          return OkiFlatButton(
            text: 'Faça uma encomenda pelo nosso Whatsapp',
            onPressed: _onEncomendaClick,
          );
        },
        onClosing: () {},
      ),
      floatingActionButton: _inProgress ?
      Padding(
        padding: EdgeInsets.only(bottom: 40),
        child: CircularProgressIndicator(),
      ) : null,
    );
  }

  //endregion

  //region metodos

  void _init() async {
    var i = Pedidos.instance.getPedidoTemp;
    if (i != null)
      data[i.id] = i;
    _setInProgress(true);

    var temp = await Pedidos.instance.baixar(save: true);
    if (temp != null) {
      temp.removeWhere((key, value) => value.idCliente != FirebaseOki.user?.uid ?? '');
      data.addAll(temp);
    }

    _setInProgress(false);
  }

  void _onPedidoClick(Pedido item) async {
    var result = await Navigate.to(context, PedidoPage(item));
    if (result != null && result is PedidoPageResult) {
      if (result == PedidoPageResult.pedido_cancelado)
        setState(() {data.remove(item.id);});
      if (result == PedidoPageResult.pedido_finalizado)
        setState(() {});
    }
  }

  void _onEncomendaClick() {
    Aplication.openWhatsApp(estb.telefone);
  }

  void _onRefresh() {
    data.clear();
    _init();
  }

  void _setInProgress(bool b) {
    if (!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}
