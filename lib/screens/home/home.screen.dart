import 'package:events_emitter/events_emitter.dart';
import 'package:expensio/bloc/cubit/app_cubit.dart';
import 'package:expensio/dao/account_dao.dart';
import 'package:expensio/dao/payment_dao.dart';
import 'package:expensio/events.dart';
import 'package:expensio/model/account.model.dart';
import 'package:expensio/model/category.model.dart';
import 'package:expensio/model/payment.model.dart';
import 'package:expensio/screens/home/widgets/account_slider.dart';
import 'package:expensio/screens/home/widgets/payment_list_item.dart';
import 'package:expensio/screens/payment_form.screen.dart';
import 'package:expensio/theme/colors.dart';
import 'package:expensio/widgets/currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) return 'Morning';
  if (hour < 17) return 'Afternoon';
  return 'Evening';
}

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  const HomeScreen({super.key, this.onSettingsTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final PaymentDao _paymentDao = PaymentDao();
  final AccountDao _accountDao = AccountDao();
  EventListener? _accountEventListener;
  EventListener? _categoryEventListener;
  EventListener? _paymentEventListener;
  List<Payment> _payments = [];
  List<Account> _accounts = [];
  double _income = 0;
  double _expense = 0;
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(Duration(days: DateTime.now().day - 1)),
    end: DateTime.now(),
  );
  Account? _account;
  Category? _category;
  late AnimationController _animationController;

  void openAddPaymentPage(PaymentType type) async {
    Navigator.of(context).push(MaterialPageRoute(builder: (builder) => PaymentForm(type: type)));
  }

  void handleChooseDateRange() async {
    final selected = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() {
        _range = selected;
        _fetchTransactions();
      });
    }
  }

  void _fetchTransactions() async {
    List<Payment> trans = await _paymentDao.find(range: _range, category: _category, account: _account);
    double income = 0;
    double expense = 0;
    for (var payment in trans) {
      if (payment.type == PaymentType.credit) income += payment.amount;
      if (payment.type == PaymentType.debit) expense += payment.amount;
    }
    List<Account> accounts = await _accountDao.find(withSummery: true);

    setState(() {
      _payments = trans;
      _income = income;
      _expense = expense;
      _accounts = accounts;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
    _accountEventListener = globalEvent.on("account_update", (_) => _fetchTransactions());
    _categoryEventListener = globalEvent.on("category_update", (_) => _fetchTransactions());
    _paymentEventListener = globalEvent.on("payment_update", (_) => _fetchTransactions());

    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 800))..forward();
  }

  @override
  void dispose() {
    _accountEventListener?.cancel();
    _categoryEventListener?.cancel();
    _paymentEventListener?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: widget.onSettingsTap,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _animationController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hi! Good ${greeting()}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                  BlocBuilder<AppCubit, AppState>(
                    builder: (context, state) => Text(
                      state.username ?? "Guest",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AccountsSlider(accounts: _accounts),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Payments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton.icon(
                  onPressed: handleChooseDateRange,
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(
                    "${DateFormat("dd MMM").format(_range.start)} - ${DateFormat("dd MMM").format(_range.end)}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ThemeColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Income", style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 5),
                        CurrencyText(_income, style: const TextStyle(fontSize: 16, color: ThemeColors.success)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ThemeColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Expense", style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 5),
                        CurrencyText(_expense, style: const TextStyle(fontSize: 16, color: ThemeColors.error)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _payments.isEmpty
                ? Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 25), child: Text("No payments yet!", style: TextStyle(fontSize: 18))))
                : ListView.separated(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _payments.length,
              separatorBuilder: (_, __) => Divider(color: Colors.grey.withAlpha(25), indent: 75),
              itemBuilder: (context, index) => PaymentListItem(
                payment: _payments[index],
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PaymentForm(type: _payments[index].type, payment: _payments[index]))),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: ThemeColors.primary,
        children: [
          SpeedDialChild(
            child: Icon(Icons.add, color: Colors.white),
            label: 'Add Income',
            backgroundColor: ThemeColors.success,
            onTap: () => openAddPaymentPage(PaymentType.credit),
          ),
          SpeedDialChild(
            child: Icon(Icons.remove, color: Colors.white),
            label: 'Add Expense',
            backgroundColor: ThemeColors.error,
            onTap: () => openAddPaymentPage(PaymentType.debit),
          ),
        ],
      ),
    );
  }
}
