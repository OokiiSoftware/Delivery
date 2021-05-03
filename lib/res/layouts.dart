import 'dart:ui';
import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';
import 'package:flutter/material.dart';
import 'import.dart';

class DropDownMenu extends StatelessWidget {
  final List<String> items;
  final Function(String) onChanged;
  final String value;
  DropDownMenu({@required this.items, @required this.onChanged, this.value});

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> temp = new List();
    for (String value in items) {
      temp.add(new DropdownMenuItem(value: value, child: new OkiText(value)));
    }
    return DropdownButton(value: value, disabledHint: OkiText(value), items: temp, onChanged: onChanged);
  }
}

class OkiChechbox extends StatelessWidget {
  final String text;
  final bool leftSide;
  final bool value;
  final Function(bool) onChanged;
  OkiChechbox({this.text, this.leftSide = false, @required this.value, @required this.onChanged});

  @override
  Widget build(BuildContext context) {
    var textAux = GestureDetector(
      child: OkiText(text),
      onTap: () => onChanged(!value),
    );
    return Row(
      children: [
        if (!leftSide)
          textAux,
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        if (leftSide)
          textAux,
      ],
    );
  }
}

class OkiTextField extends StatelessWidget{

  final String hint;
  final String label;
  final String helperText;
  final String prefixText;
  final TextEditingController controller;
  final Widget icon;
  final bool valueIsEmpty;
  final bool readOnly;
  final Function onTap;
  final int maxLines;
  final TextInputType keyboardType;

  OkiTextField({
    this.hint,
    this.label,
    this.helperText,
    this.prefixText = '',
    this.controller,
    this.icon,
    this.readOnly = false,
    this.valueIsEmpty = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var styleLabel = TextStyle(color: valueIsEmpty ? OkiTheme.textError : OkiTheme.text, fontSize: Config.fontSize);
    return Container(
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: 1,
        keyboardType: keyboardType,
        style: Styles.normalText,
        readOnly: readOnly,
        decoration: InputDecoration(
            suffixIcon: icon,
            prefixText: '$prefixText ',
            labelText: label,
            hintText: hint,
            helperText: valueIsEmpty ? helperText : null,
            helperStyle: styleLabel,
            labelStyle: styleLabel
        ),
        onTap: onTap,
      ),
    );
  }
}

class TextFieldSugestion extends StatelessWidget {

  final String hint;
  final String label;
  final TextEditingController controller;
  final Widget icon;
  final bool textIsEmpty;
  final Function onTap;
  final int maxLines;
  final TextInputType keyboardType;
  final List<String> sugestoes;
  final Function(String suggestion) onSuggestionSelected;

  TextFieldSugestion({
    this.hint,
    this.label,
    this.controller,
    this.icon,
    this.textIsEmpty = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onTap,
    this.sugestoes,
    this.onSuggestionSelected
  });

  @override
  Widget build(BuildContext context) {
    var styleLabel = TextStyle(color: textIsEmpty ? OkiTheme.textError : OkiTheme.text, fontSize: Config.fontSize);
    return TypeAheadField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        maxLines: maxLines,
        minLines: 1,
        keyboardType: keyboardType,
        style: Styles.normalText,
        decoration: InputDecoration(
            suffixIcon: icon,
            labelText: label,
            hintText: hint,
            // hintStyle: TextStyle(),
            labelStyle: styleLabel
        ),
        onTap: onTap,
      ),
      suggestionsCallback: (pattern) {
        List<String> list = [];
        sugestoes.forEach((element) {
          if (pattern.isEmpty || element.contains(pattern))
            list.add(element);
        });
        return list;
      },
      itemBuilder: (context, String suggestion) {
        return Padding(
          padding: EdgeInsets.all(10),
          child: OkiText(suggestion),
        );
      },
      onSuggestionSelected: onSuggestionSelected,
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var padding = Padding(padding: EdgeInsets.only(top: 20));
    return Scaffold(
      backgroundColor: OkiColors.launcherIconBacgground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(OkiIcons.ic_launcher_adaptive, width: 170),
            padding,
            Text(AppResources.APP_NAME, style: TextStyle(fontSize: 30, color: OkiColors.textDark)),
          ],
        ),
      ),
    );
  }
}
class ScreenLojaFechada extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var padding = Padding(padding: EdgeInsets.only(top: 20));
    return Scaffold(
      backgroundColor: OkiColors.launcherIconBacgground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(OkiIcons.ic_launcher_adaptive, width: 170),
            padding,
            Text('No momento estamos fechado devido ao sábado.',
              style: TextStyle(fontSize: 30, color: OkiColors.textDark),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class PesquisaLayout extends StatelessWidget {
  final String pesquisa;
  final PesquisaResult item;
  PesquisaLayout({this.item, this.pesquisa});

  @override
  Widget build(BuildContext context) {
    String normalText = item.text;
    String pesquisaText = '';

    List<String> textList = [];
    List<TextSpan> spanTextList = [];

    int inicio = normalText.toLowerCase().indexOf(pesquisa.toLowerCase());
    int fim = pesquisa.length + inicio;

    if (inicio > 0)
      pesquisaText = normalText.substring(inicio, fim);

    textList.addAll(normalText.split(pesquisaText));

    textList.forEach((element) {
      spanTextList.add(TextSpan(text: element));
      spanTextList.add(TextSpan(text: pesquisaText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: Config.fontSize, color: Colors.green)));
    });
    if (spanTextList.length > 0)
      spanTextList.removeAt(spanTextList.length -1);
    return RichText(
        text: TextSpan(
            style: new TextStyle(
              fontSize: Config.fontSize,
              color: OkiTheme.text,
            ),
            children: spanTextList
        )
    );
  }
}

class OkiClipRRect extends StatelessWidget {
  final Widget child;
  final double raduis;
  OkiClipRRect({this.child, this.raduis = 10});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(raduis),
      child: child,
    );
  }
}

class ComboLayout extends StatelessWidget {
  final Combo combo;
  final Function(Combo) onTap;
  final Widget trailing;
  ComboLayout(this.combo, {this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    String produtos = '';
    combo.itemsD.forEach((key, value) {
      produtos += '${value.nome} (${combo.items[key]}), ';
    });

    // Produto produto = combo.getProduto(0);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      decoration: Styles.decoration,
      child: ListTile(
        // leading: OkiClipRRect(child: Image.network(produto.foto)),
        title: OkiTitleText(combo.nome),
        trailing: trailing,
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('R\$: ${combo.preco.toStringAsFixed(2)}'),
            Text('$produtos'),
          ],
        ),
        onTap: () => onTap(combo),
      ),
    );
  }
}
class ProdutoGroupLayout extends StatelessWidget {
  final ProdutoGroup group;
  final bool showCategoria;
  final bool showPreco;
  final Function(ProdutoGroup item) onTap;
  ProdutoGroupLayout(this.group, {this.onTap, this.showCategoria = false, this.showPreco = true});
  @override
  Widget build(BuildContext context) {
    String precoMim = group.precoMim.toStringAsFixed(2);
    String precoMax = group.precoMax.toStringAsFixed(2);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      decoration: Styles.decoration,
      child: ListTile(
        // leading: OkiClipRRect(child: Image.network(produto.foto)),
        title: OkiText('${group.nome}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showPreco)
              OkiText('R\$ $precoMim - $precoMax'),
            if (showCategoria)
              Text(group.categoria),
            OkiText('${group.items.length} Tamanhos'),
          ],
        ),
        // trailing: trailing,
        onTap: () => onTap(group),
      ),
    );
  }
}
class ProdutoLayout extends StatelessWidget {
  final Produto produto;
  final Widget trailing;
  final bool showQuantidade;
  final bool showCategoria;
  final bool showTamanho;
  final bool showPreco;
  final Function(Produto item) onTap;
  ProdutoLayout(this.produto, {this.onTap, this.trailing, this.showQuantidade = false, this.showTamanho = false, this.showCategoria = false, this.showPreco = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      decoration: Styles.decoration,
      child: ListTile(
        // leading: OkiClipRRect(child: Image.network(produto.foto)),
        title: OkiText('${produto.nome} ${showQuantidade ? '(${produto.quantidade})' : ''}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showPreco)
              OkiText('R\$ ${produto.preco.toStringAsFixed(2)}'),
            if (showTamanho)
              Text(produto.tamanho),
            if (showCategoria)
              Text(produto.categoria),
          ],
        ),
        trailing: trailing,
        onTap: () => onTap(produto),
      ),
    );
  }
}
class PedidoLayout extends StatelessWidget {

  final Pedido pedido;
  final Function(Pedido item) onTap;

  PedidoLayout(this.pedido, {this.onTap});

  @override
  Widget build(BuildContext context) {
    bool semData = pedido.data.isEmpty;
    UserOki user = pedido.user;
    bool userNull = user == null;

    return Container(
      decoration: Styles.decoration,
      padding: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
            color: getIconColor(pedido.status),
            height: 30,
            width: 30,
            child: Center(child: OkiAppBarText(pedido.status.toString())),
          ),
        ),
        title: OkiTitleText(userNull? pedido.statusS : user.dados.nome),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OkiText(userNull ? 'R\$: ${pedido.total.toStringAsFixed(2)}' : pedido.statusS),
            OkiText('${semData ? 'Não finalizado' : pedido.data}'),
          ],
        ),
        onTap: () => onTap(pedido),
      ),
    );
  }

  Color getIconColor(int status) {
    switch(status) {
      case 0:
        return Colors.orange[900];
      case 1:
        return Colors.orange[700];
      case 2:
        return Colors.orange;
      case 3:
        return Colors.orange[300];
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
class UserLayout extends StatelessWidget {
  final UserOki user;
  final Function(UserOki) onTap;
  final Widget trailing;
  final bool isCliente;
  UserLayout({@required this.user, this.onTap, this.trailing, this.isCliente = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.network(
          user.dados.foto,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.person, size: 40);
          },
        ),
      ),
      title: OkiTitleText(user.dados.nome),
      subtitle: OkiText(isCliente? 'Clique para ver o endereço' : user.dados.email),
      trailing: trailing,
      onTap: () => onTap(user),
    );
  }
}

class OkiFlatButton extends StatelessWidget {
  final String text;
  final double height;
  final Function() onPressed;
  OkiFlatButton({@required this.text, this.height, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      minWidth: double.infinity,
      height: height,
      color: OkiTheme.accent,
      child: OkiAppBarText(text),
      onPressed: onPressed,
    );
  }
}

class OkiText extends StatelessWidget {
  final String text;
  OkiText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Styles.normalText);
  }
}
class OkiTitleText extends StatelessWidget {
  final String text;
  OkiTitleText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Styles.titleText);
  }
}
class OkiAppBarText extends StatelessWidget {
  final String text;
  OkiAppBarText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Styles.appBarText);
  }
}
class OkiErrorText extends StatelessWidget {
  final String text;
  OkiErrorText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Styles.textEror);
  }
}

class ShadowText extends StatelessWidget {
  ShadowText(this.text, { this.style }) : assert(text != null);

  final String text;
  final TextStyle style;

  Widget build(BuildContext context) {
    return new ClipRect(
      child: new Stack(
        children: [
          Text(
            text,
            style: style == null ? TextStyle(color: Colors.black.withOpacity(0.5)) :
            style.copyWith(color: Colors.black.withOpacity(0.5)),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Text(text, style: style),
          ),
        ],
      ),
    );
  }
}
