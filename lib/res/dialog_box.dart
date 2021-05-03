import 'package:delivery/res/strings.dart';
import 'package:flutter/material.dart';
import 'import.dart';

class DialogBox {
  static Future<DialogResult> simNao(BuildContext context, {String title, String notShowAgainText, String auxBtnText, List<Widget> content, EdgeInsets contentPadding, Function(bool value) onNotShowAgain}) async {
    return await _dialogAux(context, title: title,
        content: content,
        auxBtnText: auxBtnText,
        notShowAgainText: notShowAgainText,
        contentPadding: contentPadding,
        onNotShowAgain: onNotShowAgain,
        dialogType: DialogType.simNao
    );
  }

  static Future<DialogResult> cancelOK(BuildContext context, {String title, String notShowAgainText, String auxBtnText, String positiveButton, String negativeButton, List<Widget> content, EdgeInsets contentPadding}) async {
    return await _dialogAux(context, title: title,
        positiveButton: positiveButton,
        negativeButton: negativeButton,
        auxBtnText: auxBtnText,
        content: content,
        notShowAgainText: notShowAgainText,
        contentPadding: contentPadding,
        dialogType: DialogType.okCancel);
  }

  static Future<DialogResult> ok(BuildContext context, {String title, String notShowAgainText, String positiveButton, String auxBtnText, List<Widget> content, EdgeInsets contentPadding}) async {
    return await _dialogAux(context, title: title,
        positiveButton: positiveButton,
        auxBtnText: auxBtnText,
        content: content,
        notShowAgainText: notShowAgainText,
        contentPadding: contentPadding,
        dialogType: DialogType.ok);
  }

  static Future<DialogResult> cancel(BuildContext context, {String title, String notShowAgainText, String negativeButton, String auxBtnText, List<Widget> content, EdgeInsets contentPadding}) async {
    return await _dialogAux(context, title: title,
        negativeButton: negativeButton,
        auxBtnText: auxBtnText,
        content: content,
        notShowAgainText: notShowAgainText,
        contentPadding: contentPadding,
        dialogType: DialogType.cancel);
  }

  static Future<DialogResult> _dialogAux(BuildContext context, {
    String title,
    String auxBtnText,
    String positiveButton,
    String negativeButton,
    String notShowAgainText = 'Não mostrar novamente',
    List<Widget> content,
    EdgeInsets contentPadding,
    Function(bool value) onNotShowAgain,
    @required DialogType dialogType,
  }) async {
    //region variaveis
    auxBtnText ??= '';
    contentPadding ??= EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0);

    positiveButton ??=
    (dialogType == DialogType.sim || dialogType == DialogType.simNao) ?
    Strings.SIM : Strings.OK;

    negativeButton ??=
    (dialogType == DialogType.nao || dialogType == DialogType.simNao) ?
    Strings.NAO : Strings.CANCELAR;

    bool okButton = _showPositiveButton(dialogType);
    bool cancelButton = _showNegativeButton(dialogType);

    content ??= [];
    bool naoMostrarNovamente = false;

    //endregion

    return await showDialog(
      context: context,
      builder: (context) =>
          StatefulBuilder(
            builder: (context, setState) =>
                AlertDialog(
                  title: title == null ? null : OkiTitleText(title),
                  content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var item in content)
                            item,
                          if (onNotShowAgain != null)...[
                            Divider(),
                            Row(
                              children: [
                                Checkbox(value: naoMostrarNovamente, onChanged: (value) {
                                  setState(() {
                                    naoMostrarNovamente = value;
                                    onNotShowAgain.call(value);
                                  });
                                }),
                                GestureDetector(
                                  child: OkiText(notShowAgainText),
                                  onTap: () {
                                    setState(() {
                                      naoMostrarNovamente = !naoMostrarNovamente;
                                      onNotShowAgain.call(naoMostrarNovamente);
                                    });
                                  },
                                ),
                              ],
                            )
                          ]
                        ],
                      )
                  ),
                  contentPadding: contentPadding,
                  actions: [
                    if (auxBtnText.isNotEmpty) FlatButton(
                      child: OkiText(auxBtnText),
                      onPressed: () =>
                          Navigator.pop(
                              context, DialogResult.aux),
                    ),
                    if (cancelButton) FlatButton(
                      child: OkiText(negativeButton),
                      onPressed: () =>
                          Navigator.pop(
                              context, DialogResult.negative),
                    ),
                    if (okButton) FlatButton(
                      child: OkiText(positiveButton),
                      onPressed: () =>
                          Navigator.pop(
                              context, DialogResult.positive),
                    ),
                  ],
                ),
          ),
    ) ?? DialogResult.none;
  }

  static bool _showPositiveButton(DialogType dialogType) {
    return (dialogType == DialogType.sim || dialogType == DialogType.simNao) ||
        (dialogType == DialogType.ok || dialogType == DialogType.okCancel);
  }

  static bool _showNegativeButton(DialogType dialogType) {
    return (dialogType == DialogType.nao || dialogType == DialogType.simNao) ||
        (dialogType == DialogType.cancel || dialogType == DialogType.okCancel);
  }
}

class DialogResult {
  static const int noneValue = 50;
  static const int positiveValue = 12;
  static const int negativeValue = 22;
  static const int auxValue = 33;
  static const int aux2Value = 54;

  static DialogResult get none => DialogResult(noneValue);
  static DialogResult get positive => DialogResult(positiveValue);
  static DialogResult get negative => DialogResult(negativeValue);
  static DialogResult get aux => DialogResult(auxValue);
  static DialogResult get aux2 => DialogResult(aux2Value);

  DialogResult(this.value);

  int value;
  bool get isPositive => value == positiveValue;
  bool get isNegative => value == negativeValue;
  bool get isAux => value == auxValue;
  bool get isAux2 => value == aux2Value;
  bool get isNone => value == noneValue;
}

enum DialogType {
  ok,
  okCancel,
  cancel,
  sim,
  simNao,
  nao,
}

class DialogFullScreen {
  static void show(BuildContext context, List<Widget> content) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.3),
      pageBuilder: (context, anim1, anim2) { // your widget implementation
        return SizedBox.expand( // makes widget fullscreen
          child: Column(
            children: content,
          ),
        );
      },
    );
  }
}
