import 'package:events_emitter/listener.dart';
import 'package:expensio/dao/account_dao.dart';
import 'package:expensio/dao/category_dao.dart';
import 'package:expensio/dao/payment_dao.dart';
import 'package:expensio/events.dart';
import 'package:expensio/model/account.model.dart';
import 'package:expensio/model/category.model.dart';
import 'package:expensio/model/payment.model.dart';
import 'package:expensio/theme/colors.dart';
import 'package:expensio/widgets/currency.dart';
import 'package:expensio/widgets/dialog/account_form.dialog.dart';
import 'package:expensio/widgets/dialog/category_form.dialog.dart';
import 'package:expensio/widgets/buttons/button.dart';
import 'package:expensio/widgets/dialog/confirm.modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

typedef OnCloseCallback = Function(Payment payment);
final DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');
class PaymentForm extends StatefulWidget{
  final PaymentType  type;
  final Payment?  payment;
  final OnCloseCallback? onClose;

  const PaymentForm({super.key, required this.type, this.payment, this.onClose});

  @override
  State<PaymentForm> createState() => _PaymentForm();
}

class _PaymentForm extends State<PaymentForm>{
  bool _initialised = false;
  final PaymentDao _paymentDao = PaymentDao();
  final AccountDao _accountDao = AccountDao();
  final CategoryDao _categoryDao = CategoryDao();

  EventListener? _accountEventListener;
  EventListener? _categoryEventListener;

  List<Account> _accounts = [];
  List<Category> _categories = [];

  //values
  int? _id;
  String _title = "";
  String _description="";
  Account? _account;
  Category? _category;
  double _amount=0;
  PaymentType _type= PaymentType.credit;
  DateTime _datetime = DateTime.now();

  loadAccounts(){
    _accountDao.find().then((value){
      setState(() {
        _accounts = value;
      });
    });
  }

  loadCategories(){
    _categoryDao.find().then((value){
      setState(() {
        _categories = value;
      });
    });
  }

  void populateState() async{
    await loadAccounts();
    await loadCategories();
    if(widget.payment != null) {
      setState(() {
        _id = widget.payment!.id;
        _title = widget.payment!.title;
        _description = widget.payment!.description;
        _account = widget.payment!.account;
        _category = widget.payment!.category;
        _amount = widget.payment!.amount;
        _type = widget.payment!.type;
        _datetime = widget.payment!.datetime;
        _initialised = true;
      });
    }
    else
    {
      setState(() {
        _type =  widget.type;
        _initialised = true;
      });
    }

  }

  Future<void> chooseDate(BuildContext context) async {
    DateTime initialDate = _datetime;
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime.now()
    );
    if(picked!=null  && initialDate != picked) {
      setState(() {
        _datetime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            initialDate.hour,
            initialDate.minute
        );
      });
    }
  }

  Future<void> chooseTime(BuildContext context) async {
    DateTime initialDate = _datetime;
    TimeOfDay initialTime = TimeOfDay(hour: initialDate.hour, minute: initialDate.minute);
    final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: initialTime,
        initialEntryMode: TimePickerEntryMode.input
    );
    if (time != null && initialTime !=time) {
      setState(() {
        _datetime = DateTime(
            initialDate.year,
            initialDate.month,
            initialDate.day,
            time.hour,
            time.minute
        );
      });
    }
  }

  void handleSaveTransaction(context) async{
    Payment payment = Payment(id: _id,
        account: _account!,
        category: _category!,
        amount: _amount,
        type: _type,
        datetime: _datetime,
        title: _title,
        description: _description
    );
    await _paymentDao.upsert(payment);
    if (widget.onClose != null) {
      widget.onClose!(payment);
    }
    Navigator.of(context).pop();
    globalEvent.emit("payment_update");
  }


  @override
  void initState()  {
    super.initState();
    populateState();
    _accountEventListener = globalEvent.on("account_update", (data){
      debugPrint("accounts are changed");
      loadAccounts();
    });

    _categoryEventListener = globalEvent.on("category_update", (data){
      debugPrint("categories are changed");
      loadCategories();
    });
  }

  @override
  void dispose() {

    _accountEventListener?.cancel();
    _categoryEventListener?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(!_initialised) return const CircularProgressIndicator();

    return
      Scaffold(
          appBar: AppBar(
            title: Text("${widget.payment ==null? "New": "Edit"} Transaction", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            actions: [
              _id!=null ? IconButton(
                  onPressed: (){
                    ConfirmModal.showConfirmDialog(context, title: "Are you sure?", content: const Text("After deleting payment can't be recovered."),
                        onConfirm: (){
                          _paymentDao.deleteTransaction(_id!).then((value) {
                            globalEvent.emit("payment_update");
                            Navigator.pop(context);
                            Navigator.pop(context);
                          });
                        },
                        onCancel: (){
                          Navigator.pop(context);
                        }
                    );

                  }, icon: const Icon(Icons.delete, size: 20,), color: ThemeColors.error
              ) : const SizedBox()
            ],
          ),
          body: Column(
            children: [
              Expanded(
                  child:SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 25,),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Income button
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(45),
                                      boxShadow: [
                                        if (_type == PaymentType.credit)
                                          BoxShadow(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                      ],
                                    ),
                                    child: AnimatedScale(
                                      scale: _type == PaymentType.credit ? 1.05 : 1.0,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      child: AppButton(
                                        onPressed: () => setState(() => _type = PaymentType.credit),
                                        label: "Income",
                                        color: Theme.of(context).colorScheme.primary,
                                        type: _type == PaymentType.credit
                                            ? AppButtonType.filled
                                            : AppButtonType.outlined,
                                        borderRadius: BorderRadius.circular(45),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Expense button
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(45),
                                      boxShadow: [
                                        if (_type == PaymentType.debit)
                                          BoxShadow(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                      ],
                                    ),
                                    child: AnimatedScale(
                                      scale: _type == PaymentType.debit ? 1.05 : 1.0,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      child: AppButton(
                                        onPressed: () => setState(() => _type = PaymentType.debit),
                                        label: "Expense",
                                        color: Theme.of(context).colorScheme.primary,
                                        type: _type == PaymentType.debit
                                            ? AppButtonType.filled
                                            : AppButtonType.outlined,
                                        borderRadius: BorderRadius.circular(45),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

// — Title Field —
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: TextFormField(
                                  initialValue: _title,
                                  onChanged: (text) => setState(() => _title = text),
                                  decoration: InputDecoration(
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
                                      child: Icon(Icons.title, color: Theme.of(context).colorScheme.primary),
                                    ),
                                    hintText: 'Title',
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
                                  ),
                                ),
                              ),
                            ),

// — Description Field —
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: TextFormField(
                                  initialValue: _description,
                                  maxLines: null,
                                  onChanged: (text) => setState(() => _description = text),
                                  decoration: InputDecoration(
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(top: 14.0),
                                      child: Icon(Icons.notes, color: Theme.of(context).colorScheme.primary),
                                    ),
                                    hintText: 'Description',
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
                                  ),
                                ),
                              ),
                            ),
// — Amount Field —
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
                                  ],
                                  initialValue: _amount == 0 ? '' : _amount.toString(),
                                  onChanged: (text) => setState(() => _amount = double.parse(text.isEmpty ? '0' : text)),
                                  decoration: InputDecoration(
                                    hintText: '0.0',
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: CurrencyText(null),
                                    ),
                                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                                  ),
                                ),
                              ),
                            ),

// — Date & Time Pickers —
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(15),
                                        onTap: () => chooseDate(context),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.calendar_today, size: 18, color: Theme.of(context).colorScheme.primary),
                                              const SizedBox(width: 8),
                                              Text(
                                                DateFormat('dd/MM/yyyy').format(_datetime),
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(15),
                                        onTap: () => chooseTime(context),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.watch_later_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
                                              const SizedBox(width: 8),
                                              Text(
                                                DateFormat('hh:mm a').format(_datetime),
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Select Account',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 3,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 70,
                              margin: const EdgeInsets.only(bottom: 25),
                              width: double.infinity,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(left: 10, right: 10,),
                                children:List.generate(_accounts.length +1, (index){
                                  if(index == 0){
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // ↓ less vertical margin
                                      width: 160,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(18),
                                        onTap: () => showDialog(context: context, builder: (_) => const AccountForm()),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // ↓ less vertical padding
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                                child: const Icon(Icons.add, color: Colors.white, size: 20),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "New",
                                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                                    ),
                                                    Text(
                                                      "Create Account",
                                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  Account account = _accounts[index-1];
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _account?.id == account.id
                                          ? account.color.withOpacity(0.2)
                                          : Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: _account?.id == account.id
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: _account?.id == account.id ? 8 : 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(18),
                                      onTap: () => setState(() => _account = account),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: account.color.withOpacity(0.2),
                                            child: Icon(account.icon, color: account.color),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (account.holderName.isNotEmpty)
                                                Text(
                                                  account.holderName,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(fontWeight: FontWeight.w600),
                                                ),
                                              Text(
                                                account.name,
                                                style: Theme.of(context).textTheme.bodySmall,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Select Category',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 3,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // — Category Selector —
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  // “New Category” card
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(15),
                                      onTap: () => showDialog(context: context, builder: (_) => const CategoryForm()),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
                                          const SizedBox(width: 8),
                                          Text(
                                            'New Category',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Existing categories
                                  ..._categories.map((cat) {
                                    final selected = _category?.id == cat.id;
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? cat.color.withOpacity(0.2)
                                            : Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: selected ? cat.color : Colors.transparent,
                                          width: 2,
                                        ),
                                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(15),
                                        onTap: () => setState(() => _category = cat),
                                        onLongPress: () => showDialog(context: context, builder: (_) => CategoryForm(category: cat)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(cat.icon, color: cat.color),
                                            const SizedBox(width: 8),
                                            Text(
                                              cat.name,
                                              style: Theme.of(context).textTheme.bodyMedium,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),

                          ],
                        ) ,
                      )
                  )
              ),
              AnimatedOpacity(
                // Fade when disabled
                duration: const Duration(milliseconds: 300),
                opacity: (_amount > 0 && _account != null && _category != null) ? 1.0 : 0.5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: ElevatedButton(
                    onPressed: (_amount > 0 && _account != null && _category != null)
                        ? () => handleSaveTransaction(context)
                        : null,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: const Size.fromHeight(50),
                      elevation: 6,
                      shadowColor: Colors.black26,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      child: const Text('Save Transaction'),
                    ),
                  ),
                ),
              ),

            ],
          )
      );
  }
}