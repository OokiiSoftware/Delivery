import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';
import 'package:delivery/res/import.dart';
import 'package:flutter/material.dart';

class AddProdutoFragment extends StatefulWidget {
  final Produto produto;
  AddProdutoFragment([this.produto]);
  @override
  State<StatefulWidget> createState() => _State(produto);
}
class _State extends State<AddProdutoFragment> {

  //region variaveis
  final Produto produto;
  static Produto _produto;

  TextEditingController cNome = TextEditingController();
  TextEditingController cPreco = TextEditingController();
  TextEditingController cTamanho = TextEditingController();
  TextEditingController cCategoria = TextEditingController();
  TextEditingController cDescricao = TextEditingController();

  bool nomeIsEmpty = false;
  bool precoIsEmpty = false;
  bool categoriaIsEmpty = false;
  // bool fotoIsEmpty = false;

  bool _canPublique = false;

  bool _inProgress = false;
  bool _canSaveFoto = true;

  // File _fotoFile;
  //endregion

  _State(this.produto);

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
        title: OkiAppBarText('NOVO PRODUTO'),
        actions: [
          IconButton(
              tooltip: 'Limpar Campos',
              icon: Icon(Icons.refresh),
              onPressed: _resetDados
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 80),
        child: Column(
          children: [
            // FlatButton(
            //   minWidth: double.infinity,
            //   color: OkiTheme.accent,
            //   child: OkiAppBarText('Adicionar foto'),
            //   onPressed: _onSelectFoto,
            // ),
            // if (fotoIsEmpty)
            //   OkiErrorText('Adicione uma foto'),
            // if (_fotoFile != null)
            //   Image.file(_fotoFile, width: double.infinity),
            // if (_produto != null && _produto.foto.isNotEmpty && _fotoFile == null)
            //   Image.network(_produto.foto, width: double.infinity),
            // Nome
            OkiTextField(
              label: 'Nome',
              hint: 'Pizza de frango Média',
              controller: cNome,
              valueIsEmpty: nomeIsEmpty,
              keyboardType: TextInputType.name,
              onTap: () {
                setState(() {
                  nomeIsEmpty = false;
                });
              },
            ),
            // Categoria
            TextFieldSugestion(
              label: 'Categoria',
              hint: 'Bolo, Pizza, Bebida, etc...',
              controller: cCategoria,
              textIsEmpty: categoriaIsEmpty,
              onTap: () {
                setState(() {
                  categoriaIsEmpty = false;
                });
              },
              sugestoes: Produtos.instance.categorias(removeNaoAVenda: false),
              onSuggestionSelected: (String suggestion) {
                setState(() {
                  cCategoria.text = suggestion;
                });
              },
            ),
            // Descricao
            OkiTextField(
              label: 'Descricao',
              hint: 'Frango,\nQueijo,\n8 fatias,\nTamanho médio, etc...',
              maxLines: 10,
              controller: cDescricao,
            ),
            // Preço
            OkiTextField(
              label: 'Preço',
              hint: 'R\$: 0,00',
              helperText: 'Use somente números e ponto.',
              controller: cPreco,
              valueIsEmpty: precoIsEmpty,
              keyboardType: TextInputType.number,
              onTap: () {
                setState(() {
                  precoIsEmpty = false;
                });
              },
            ),
            // Tamanho
            TextFieldSugestion(
              label: 'Tamanho (Opcional)',
              hint: 'pequeno, médio, grande...',
              controller: cTamanho,
              sugestoes: Produtos.instance.tamanhos(),
              onSuggestionSelected: (String suggestion) {
                setState(() {
                  cTamanho.text = suggestion;
                });
              },
            ),

            OkiChechbox(
              text: 'Habilitar Venda',
              value: _canPublique,
              onChanged: _onCanPubliqueChanged,
            ),
          ],
        ),
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() :
      FloatingActionButton.extended(
        label: OkiAppBarText('Salvar'),
        onPressed: _onSave,
      ),
    );
  }

  //endregion

  //region metodos

  void _init() {
    if (produto != null) {
      _produto = Produto.fromJson(produto.toJson());
      _canSaveFoto = false;
    }

    if (_produto != null) {
      cNome.text = _produto.nome;
      cPreco.text = _produto.preco.toStringAsFixed(2);
      cCategoria.text = _produto.categoria;
      cDescricao.text = _produto.descricao;
      _canPublique = _produto.isAVenda;

      // if (_produto.isLocalFoto)
      //   _fotoFile = File(_produto.foto);

      if (produto == null)
        _produto.id = null;
    } else
      _produto = Produto();
  }

  /*void _onSelectFoto() async {
    var file = await Aplication.openCropImage(context, aspect: 1/1);
    if(file != null && await file.exists()) {
      _canSaveFoto = true;
      // _produto.foto = file.path;
      setState(() {
        // _fotoFile = file;
        // fotoIsEmpty = false;
      });
    }
  }*/

  void _onSave() async {
    Produto item = _criarObj();
    if (!_verificarDados(item))
      return;

    _setInProgress(true);

    if (await item.salvar(saveFoto: _canSaveFoto)) {
      Produtos.instance.add(produto: item);
      _perguntarLimparCampos();
      Log.snack('Produto Salvo');
    } else {
      Log.snack('Ocorreu um erro', isError: true);
    }

    _setInProgress(false);
  }

  void _onCanPubliqueChanged(bool value) {
    setState(() {
      _canPublique = value;
    });
  }

  Produto _criarObj() {
    var item = _produto;
    if (item == null)
      item = Produto();

    if (item.id == null)
      item.id = Cript.randomString();

    item.nome = cNome.text;
    // item.foto = (_fotoFile?.path ?? _produto.foto);
    item.categoria = cCategoria.text;
    item.descricao = cDescricao.text;
    item.tamanho = cTamanho.text;
    item.preco = double.tryParse(cPreco.text) ?? -1;
    item.isAVenda = _canPublique;
    return item;
  }

  bool _verificarDados(Produto item) {
    try {

      precoIsEmpty = item.preco < 0;
      nomeIsEmpty = item.nome.isEmpty;
      // fotoIsEmpty = item.foto.isEmpty;
      categoriaIsEmpty = item.categoria.isEmpty;

      setState(() {});

      // if (fotoIsEmpty) throw ('');
      if (nomeIsEmpty) throw ('');
      if (precoIsEmpty) throw ('');
      if (categoriaIsEmpty) throw ('');

      return true;
    } catch(e) {
      return false;
    }
  }

  void _perguntarLimparCampos() async {
    var title = 'Deseja limpar todos os campos de texto?';
    var result = await DialogBox.simNao(context, title: title);
    if (result.isPositive)
      _resetDados();
  }

  void _resetDados() {
    cNome.text =
    cPreco.text =
    cCategoria.text =
    cTamanho.text =
    cDescricao.text = '';

    _produto = null;
    // _fotoFile = null;
  }

  void _setInProgress(bool b) {
    if (!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}