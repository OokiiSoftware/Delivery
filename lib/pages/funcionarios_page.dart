import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';
import 'package:delivery/res/import.dart';
import 'package:flutter/material.dart';

class FuncionariosPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<FuncionariosPage> {

  //region variaveis

  final Map<String, UserOki> _data = Map();

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
    bool isGerente = FirebaseOki.userOki.isGerente || FirebaseOki.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: OkiAppBarText('FUNCIONÁRIOS'),
        actions: [
          if (isGerente)
            IconButton(
              icon: Icon(Icons.info),
              onPressed: _onInfoClick,
            )
        ],
      ),
      body: ListView.builder(
        itemCount: _data.length,
        itemBuilder: (context, index) {
          UserOki item = _data.values.toList()[index];

          bool noCanDelete = (item.dados.id == FirebaseOki.user.uid) || !isGerente;

          return UserLayout(
            user: item,
            trailing: noCanDelete ? null : IconButton(
              icon: Icon(Icons.delete_forever, color: item.isGerente ? OkiTheme.accent : null),
              onPressed: () => _onRemoveFuncionario(item),
            ),
            onTap: noCanDelete ? null : _onFuncionarioClick,
          );
        },
      ),
      bottomSheet: isGerente ? BottomSheet(
        builder: (context) {
          return FlatButton(
            minWidth: double.infinity,
            color: OkiTheme.accent,
            child: OkiAppBarText('Adicionar Funcionário'),
            onPressed: _onAddFuncionario,
          );
        },
        onClosing: () {},
      ) : null,
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
    _setInProgress(true);

    _data.addAll(Funcionarios.instance.data);

    var temp = await Funcionarios.instance.baixar();
    if (temp != null) {
      _data.clear();
      _data.addAll(temp);
      Funcionarios.instance.save();
    }

    _setInProgress(false);
  }

  void _onInfoClick() {
    var title = 'Info';
    var content = [
      OkiText('Clique em um funcionário para alterar seu nível de acesso ao app.'),
      Divider(),
      OkiText('Você não pode alterar seu próprio nível de acesso.')
    ];
    DialogBox.ok(context, title: title, content: content);
  }

  void _onGerenteInfoClick() {
    var title = 'Gerente pode:';
    var content = [
      OkiText('Adicionar/Remover/Editar Produtos.'),
      OkiText('Adicionar/Remover Funcionários.'),
      OkiText('Alterar status dos pedidos.'),
    ];
    DialogBox.ok(context, title: title, content: content);
  }
  void _onFuncionarioInfoClick() {
    var title = 'Funcionario pode:';
    var content = [
      OkiText('Alterar status dos pedidos.')
    ];
    DialogBox.ok(context, title: title, content: content);
  }

  void _onFuncionarioClick(UserOki item) async {
    var title = item.dados.nome;
    var content = [
      Row(
        children: [
          Expanded(
              child: ElevatedButton(
                child: OkiAppBarText('Gerente'),
                onPressed: () {
                  Navigator.pop(context, DialogResult.aux);
                },
              )
          ),
          IconButton(
            icon: Icon(Icons.info, color: OkiTheme.accent),
            onPressed: _onGerenteInfoClick,
          )
        ],
      ),
      Row(
        children: [
          Expanded(
              child: ElevatedButton(
                child: OkiAppBarText('Funcionário'),
                onPressed: () {
                  Navigator.pop(context, DialogResult.aux2);
                },
              )
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: _onFuncionarioInfoClick,
          )
        ],
      ),
    ];
    var result = await DialogBox.cancel(context, title: title, content: content);

    _setInProgress(true);

    switch (result.value) {
      case DialogResult.auxValue:
        await item.setSpecialAcesso(2);
        break;
      case DialogResult.aux2Value:
        await item.setSpecialAcesso(1);
        break;
    }
    _setInProgress(false);
  }

  void _onAddFuncionario() async {
    var controller = TextEditingController();

    String contentS = 'Certifique-se de que a pessoa fez login no app usando o email inserido.';

    var title = 'Adicionar Funcionário';
    var content = [
      OkiText(contentS),
      OkiTextField(
        hint: 'Email',
        controller: controller,
      )
    ];
    var result = await DialogBox.cancelOK(context, title: title, content: content);
    if (!result.isPositive || controller.text.isEmpty)
      return;

    String email = controller.text;
    UserOki userOki = Funcionarios.instance.getUser(email);

    if (userOki == null) {
      var title = 'Email não encontrado';
      var content = [
        OkiText(contentS),
      ];
      DialogBox.ok(context, title: title, content: content);
    } else {
      var title = userOki.dados.nome;
      var content = [
        OkiText('O usuário está correto?'),
        OkiText('Clique em SIM para adicionar.'),
      ];
      var result = await DialogBox.simNao(context, title: title, content: content);
      if (result.isPositive) {
        _setInProgress(true);
        await userOki.setSpecialAcesso(1);
      }
    }

    _setInProgress(false);
  }

  void _onRemoveFuncionario(UserOki item) async {
    var title = item.dados.nome;
    var content = [
      OkiText('Deseja remover esse ${ item.isGerente ? 'Gerente' : 'funcionário'}?'),
      OkiText('Clique em SIM para continuar.'),
    ];
    var result = await DialogBox.simNao(context, title: title, content: content);
    if (result.isPositive) {
      _setInProgress(true);
      await item.setSpecialAcesso(0);
    }
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