import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/pages/sign_in.dart';

import '../blocs/sign_in_bloc.dart';
import '../utils/next_screen.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({Key? key}) : super(key: key);

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _isLoading = false;

  _openDeleteDialog() {
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('account-delete-title', style: _textStyleMedium).tr(),
            content:
                Text('account-delete-subtitle', style: _textStyleMedium).tr(),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleDeleteAccount();
                },
                child: Text('account-delete-confirm', style: _textStyleMedium)
                    .tr(),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('cancel', style: _textStyleMedium).tr())
            ],
          );
        });
  }

  _handleDeleteAccount() async {
    setState(() => _isLoading = true);
    await context
        .read<SignInBloc>()
        .deleteUserDatafromDatabase()
        .then((_) async => await context.read<SignInBloc>().userSignout())
        .then((_) => context.read<SignInBloc>().afterUserSignOut())
        .then((_) {
      setState(() => _isLoading = false);
      Future.delayed(Duration(seconds: 1))
          .then((value) => nextScreenCloseOthers(context, SignInPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Scaffold(
      appBar: AppBar(
        title: Text('security', style: _textStyleMedium).tr(),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              ListTile(
                title: Text('delete-user-data', style: _textStyleMedium).tr(),
                leading: Icon(
                  Feather.trash,
                  size: 20,
                ),
                onTap: _openDeleteDialog,
              ),
            ],
          ),
          Align(
            child:
                _isLoading == true ? CircularProgressIndicator() : Container(),
          )
        ],
      ),
    );
  }
}