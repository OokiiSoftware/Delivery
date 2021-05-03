import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';
import 'package:delivery/res/import.dart';
import 'package:flutter/material.dart';

class EstabelecimentoPage extends StatefulWidget {
  final bool readOnly;
  EstabelecimentoPage({this.readOnly = false});
  @override
  State<StatefulWidget> createState() => _State(readOnly);
}
class _State extends State<EstabelecimentoPage> {

  Estabelecimento estb = Aplication.estabelecimento;

  final bool readOnly;

  //region TextEditingController
  TextEditingController _nome = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _telefone = TextEditingController();
  TextEditingController _cidade = TextEditingController();
  TextEditingController _bairro = TextEditingController();
  TextEditingController _rua = TextEditingController();
  TextEditingController _numero = TextEditingController();
  TextEditingController _complemento = TextEditingController();
  //endregion

  bool nomeIsEmpty = false;
  bool _inProgress = false;

  _State(this.readOnly);

  @override
  void initState() {
    super.initState();

    _nome.text = estb.nome;
    _email.text = estb.email;
    _telefone.text = estb.telefone;

    var end = estb.endereco;
    _cidade.text = 'Joselândia';
    _bairro.text = 'Cazuza';
    _rua.text = end.rua;
    _numero.text = end.numero;
    _complemento.text = end.complemento;
  }

  @override
  Widget build(BuildContext context) {
    Endereco end = estb.endereco;
    var dividerP = SizedBox(height: 10);
    var dividerG = SizedBox(height: 30);

    return Scaffold(
      appBar: AppBar(title: OkiAppBarText('ESTABELECIMENTO')),
      body: readOnly ?
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Icone
            Image.asset(OkiIcons.ic_launcher,
              width: 130,
              height: 130,
            ),
            dividerG,
            OkiTitleText(estb.nome),

            if (estb.email.isNotEmpty)...[
              dividerP,
              GestureDetector(
                child: Text(estb.email,
                    style: TextStyle(
                        color: OkiTheme.accent, fontSize: Config.fontSize)
                ),
                onTap: () {
                  Aplication.openEmail(estb.email);
                },
              ),
            ],
            if (estb.telefone.isNotEmpty)...[
              dividerP,
              GestureDetector(
                child: Text(estb.telefone,
                    style: TextStyle(
                        color: OkiTheme.accent, fontSize: Config.fontSize)
                ),
                onTap: () {
                  Aplication.openWhatsApp(estb.telefone);
                },
              ),
            ],

            dividerG,
            OkiText('Endereço:'),
            dividerP,
            OkiText('${end.cidade}, ${end.bairro}'),
            dividerP,
            OkiText('Rua: ${end.rua}, N: ${end.numero}'),
            dividerP,
            OkiText('${end.complemento}'),
          ],
        ),
      ) :
      SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
              // Nome
              OkiTextField(
                controller: _nome,
                label: Strings.NOME,
                valueIsEmpty: nomeIsEmpty,
                keyboardType: TextInputType.name,
                onTap: () {
                  setState(() {
                    nomeIsEmpty = false;
                  });
                },
              ),
              // Email
              OkiTextField(
                controller: _email,
                label: Strings.EMAIL,
                keyboardType: TextInputType.emailAddress,
                icon: (readOnly) ? IconButton(
                  tooltip: 'Abrir Email',
                  icon: Icon(Icons.open_in_new),
                  onPressed: _onOpenEmail,
                ) : null,
              ),
              // Telefone
              OkiTextField(
                controller: _telefone,
                label: Strings.TELEFONE,
                keyboardType: TextInputType.phone,
                icon: (readOnly) ? IconButton(
                  tooltip: 'Abrir Whatsapp',
                  icon: Icon(Icons.open_in_new),
                  onPressed: _onOpenTelefone,
                ) : null,
              ),
              // Cidade
              OkiTextField(
                controller: _cidade,
                label: Strings.CIDADE,
                readOnly: true,
              ),
              // Bairro
              OkiTextField(
                controller: _bairro,
                label: Strings.BAIRRO,
              ),
              // Rua
              OkiTextField(
                controller: _rua,
                label: Strings.RUA,
              ),
              // Numero
              OkiTextField(
                controller: _numero,
                label: Strings.NUMERO,
              ),
              // Complemento
              OkiTextField(
                controller: _complemento,
                label: Strings.COMPLEMENTO,
              ),
          ],
        ),
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() :
      readOnly ? null :
      FloatingActionButton.extended(
        label: OkiAppBarText('Salvar'),
        onPressed: _onSaveClick,
      ),
    );
  }

  void _onSaveClick() async {
    var item = _criarObg();
    if (_verificarDados(item)) {
      _setInProgress(true);
      if (await item.salvar()) {
        Aplication.estabelecimento = item;
        Log.snack(MyTexts.DADOS_SALVOS);
      } else
        Log.snack(MyErros.ERRO_GENERICO);
    }

    _setInProgress(false);
  }

  Estabelecimento _criarObg() {
    var item = Estabelecimento();
    item.nome = _nome.text;
    item.email = _email.text;
    item.telefone = _telefone.text;

    var end = Endereco();
    end.estado = 'Maranhão';
    end.cidade = _cidade.text;
    end.bairro = _bairro.text;
    end.rua = _rua.text;
    end.numero = _numero.text;
    end.complemento = _complemento.text;

    item.endereco = end;
    return item;
  }

  bool _verificarDados(Estabelecimento item) {
    try {
      nomeIsEmpty = _nome.text.isEmpty;

      if (nomeIsEmpty) throw('');
    } catch(e) {
      return false;
    }
    return true;
  }

  void _onOpenTelefone() {
    Aplication.openWhatsApp(estb.telefone);
  }
  void _onOpenEmail() {
    Aplication.openEmail(estb.email);
  }

  void _setInProgress(bool b) {
    if (!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }
}