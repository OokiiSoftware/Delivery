import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';
import 'package:delivery/pages/import.dart';
import 'package:delivery/res/import.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<MainPage> {

  //region variaveis

  final Map<String, Produto> _data = Map();

  final List<String> categorias = [];

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
    String title = Aplication.estabelecimento?.nome ?? '';
    if (title.isEmpty) title = AppResources.APP_NAME;

    bool showGerenciaButton = FirebaseOki.hasAcessoEspecialOrIsAdmin;

    return Scaffold(
      appBar: AppBar(
        title: OkiAppBarText(title),
        actions: [
          if (showGerenciaButton)
            IconButton(
                tooltip: 'Gerência',
                icon: Icon(Icons.whatshot),
                onPressed: _onGerenciaClick
            ),
          if (FirebaseOki.isLogado)
            IconButton(
                tooltip: 'Perfil',
                icon: Icon(Icons.person_pin),
                onPressed: _onPerfilClick
            ),
          IconButton(
              tooltip: 'Informações',
              icon: Icon(Icons.info),
              onPressed: _onInfoClick
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.only(bottom: 150),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          String categoria = categorias[index];

          var list = _data.values.toList().where((x) => x.categoria.toLowerCase() == categoria);
          // Produto item = list.first;

          String itens = '';
          list.forEach((element) {
            itens += '${element.nome}, ';
          });

          return Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            decoration: Styles.decoration,
            child: ListTile(
              // leading: OkiClipRRect(child: Image.network(item.foto)),
              title: OkiText(categoria),
              subtitle: Text(itens, maxLines: 1),
              onTap: () => _onCategoriaClick(categoria),
            ),
          );
        },
      ),
      bottomSheet: FirebaseOki.isLogado ?
      BottomSheet(
        builder: (context) {
          return Container(
            decoration: Styles.decoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FlatButton(
                  height: 60,
                  minWidth: double.infinity,
                  child: Text('VEJA NOSSOS COMBOS'),
                  onPressed: _onCombosClick,
                ),
              ],
            ),
          );
        },
        onClosing: () {},
      ) :
      BottomSheet(
        builder: (context) {
          return OkiFlatButton(
            text: 'Login',
            onPressed: _onLoginClick,
          );
        },
        onClosing: () {},
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() :
      Padding(
        padding: EdgeInsets.only(bottom: 50),
        child: FloatingActionButton.extended(
            label: OkiAppBarText('Meus Pedidos'),
            onPressed: _onVerPedidosClick
        ),
      ),
    );
  }

  //endregion

  //region metodos

  void _init() async {
    _setInProgress(true);
    _data.addAll(Produtos.instance.data);

    FirebaseOki.onCheckSpecialAccess = () {
      NotificationManager.instance = NotificationManager(context);
      setState(() {});
    };

    var temp = await Produtos.instance.baixar(save: true);
    if (temp != null) {
      _data.clear();
      _data.addAll(temp);
    }
    _data.removeWhere((key, value) => !value.isAVenda);
    categorias.addAll(Produtos.instance.categorias());

    Produtos.onProdutoAdded = _onProdutoAdded;
    Produtos.onProdutoRemoved = _onProdutoRemoved;

    await Produtos.instance.baixarCombos(save: true);

    _setInProgress(false);
  }

  void _onCategoriaClick(String item) {
    List<dynamic> produtos = [];
    // produtos.addAll(
    //     Produtos.instance.data.values.toList().where((x)
    //     => x.isAVenda && (x.categoria.toLowerCase() == item)));
    produtos.addAll(
        Produtos.instance.groups.values.toList().where((x)
        => x.categoria.toLowerCase() == item));

    produtos.sort((a, b) => a.nome.compareTo(b.nome));

    Navigate.to(context, ProdutosPage(produtos: produtos));
  }

  void _onVerPedidosClick() {
    Navigate.to(context, PedidosPage());
  }

  void _onPerfilClick() async {
     await Navigate.to(context, PerfilPage());
     setState(() {});
  }

  void _onGerenciaClick() {
    Navigate.to(context, GerenciaPage());
  }

  void _onLoginClick() async {
    await Navigate.to(context, LoginPage(context));
    setState(() {});
  }

  void _onCombosClick() {
    Navigate.to(context, CombosPage());
  }

  void _onInfoClick() {
    Navigate.to(context, EstabelecimentoPage(readOnly: true));
  }

  void _onProdutoAdded(Produto item) {
    if (!item.isAVenda)
      return;
    _data[item.id] = item;
    if (!categorias.contains(item.categoria))
      setState(() {
        categorias.add(item.categoria);
      });
  }
  void _onProdutoRemoved(Produto item) {
    _data.remove(item.id);
    setState(() {});
  }

  void _setInProgress(bool b) {
    if (!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}
