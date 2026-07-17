import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/app/features/auth_and_validation/presentation/controller/auth_store.dart';
import 'package:pora/app/internal/widgets/pora_snackbar.dart';

/// Слушает [AuthStore] и показывает [PoraSnackbar] при смене статуса:
///  • `success == false` → ошибка ([AuthStore.scaffoldMessage]);
///  • `success == true` и задан [successMessage] → успех.
///
/// Оборачивает контент экрана — реакции живут, пока экран в дереве.
class AuthStoreSnackListener extends StatefulWidget {
  const AuthStoreSnackListener({
    super.key,
    required this.authStore,
    required this.child,
    this.successMessage,
  });

  final AuthStore authStore;
  final Widget child;
  final String? successMessage;

  @override
  State<AuthStoreSnackListener> createState() => _AuthStoreSnackListenerState();
}

class _AuthStoreSnackListenerState extends State<AuthStoreSnackListener> {
  ReactionDisposer? _disposer;

  @override
  void initState() {
    super.initState();
    _disposer = reaction<bool?>(
      (_) => widget.authStore.success,
      _onSuccessChanged,
    );
  }

  void _onSuccessChanged(bool? ok) {
    if (!mounted || ok == null) return;
    if (ok) {
      final msg = widget.successMessage;
      if (msg != null) {
        PoraSnackbar.show(context, message: msg, type: PoraSnackType.success);
      }
    } else {
      PoraSnackbar.show(
        context,
        //! Localize
        message: widget.authStore.scaffoldMessage ?? 'Что-то пошло не так',
        type: PoraSnackType.failure,
      );
    }
  }

  @override
  void dispose() {
    _disposer?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
