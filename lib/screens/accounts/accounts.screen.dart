import 'package:events_emitter/events_emitter.dart';
import 'package:expensio/dao/account_dao.dart';
import 'package:expensio/events.dart';
import 'package:expensio/model/account.model.dart';
import 'package:expensio/theme/colors.dart';
import 'package:expensio/widgets/currency.dart';
import 'package:expensio/widgets/dialog/account_form.dialog.dart';
import 'package:expensio/widgets/dialog/confirm.modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

maskAccount(String value, [int lastLength = 4]) {
  if (value.length < 4) return value;
  int length = value.length - lastLength;
  String generated = "";
  if (length > 0) {
    generated +=
        value.substring(0, length).split("").map((e) => e == " " ? " " : "X").join("");
  }
  generated += value.substring(length);
  return generated;
}

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final AccountDao _accountDao = AccountDao();
  EventListener? _accountEventListener;
  List<Account> _accounts = [];

  void loadData() async {
    List<Account> accounts = await _accountDao.find(withSummery: true);
    setState(() {
      _accounts = accounts;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();

    _accountEventListener = globalEvent.on("account_update", (data) {
      debugPrint("accounts are changed");
      loadData();
    });
  }

  @override
  void dispose() {
    _accountEventListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Accounts",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: AnimatedSwitcher(
        duration: 500.ms,
        child: ListView.builder(
          key: ValueKey(_accounts.length),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          itemCount: _accounts.length,
          itemBuilder: (context, index) {
            Account account = _accounts[index];
            GlobalKey accKey = GlobalKey();
            return Animate(
              effects: [FadeEffect(duration: 300.ms), SlideEffect(begin: Offset(0.2, 0))],
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: account.color.withOpacity(0.3),
                            child: Icon(account.icon, color: account.color),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.holderName.isEmpty ? "---" : account.holderName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                Text(account.name),
                                Text(maskAccount(account.accountNumber)),
                              ],
                            ),
                          ),
                          IconButton(
                            key: accKey,
                            onPressed: () {
                              final RenderBox renderBox =
                              accKey.currentContext?.findRenderObject() as RenderBox;
                              final Size size = renderBox.size;
                              final Offset offset = renderBox.localToGlobal(Offset.zero);

                              showMenu(
                                context: context,
                                position: RelativeRect.fromLTRB(
                                  offset.dx,
                                  offset.dy + size.height,
                                  offset.dx + size.width,
                                  offset.dy + size.height,
                                ),
                                items: [
                                  PopupMenuItem<String>(
                                    value: '1',
                                    child: const Text('Edit'),
                                    onTap: () {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        showDialog(
                                          context: context,
                                          builder: (builder) => AccountForm(account: account),
                                        );
                                      });
                                    },
                                  ),
                                  PopupMenuItem<String>(
                                    value: '2',
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: ThemeColors.error),
                                    ),
                                    onTap: () {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        ConfirmModal.showConfirmDialog(
                                          context,
                                          title: "Are you sure?",
                                          content: const Text(
                                            "All the payments will be deleted that belong to this account",
                                          ),
                                          onConfirm: () async {
                                            Navigator.pop(context);
                                            await _accountDao.delete(account.id!);
                                            globalEvent.emit("account_update");
                                          },
                                          onCancel: () {
                                            Navigator.pop(context);
                                          },
                                        );
                                      });
                                    },
                                  ),
                                ],
                              );
                            },
                            icon: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                      const Divider(height: 30),
                      Text("Total Balance",
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.w600,
                          )),
                      CurrencyText(
                        account.balance ?? 0,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Income",
                                    style: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w600)),
                                CurrencyText(
                                  account.income ?? 0,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: ThemeColors.success),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Expense",
                                    style: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w600)),
                                CurrencyText(
                                  account.expense ?? 0,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: ThemeColors.error),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (builder) => const AccountForm());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}