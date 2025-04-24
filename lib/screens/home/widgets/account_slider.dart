import 'package:expensio/model/account.model.dart';
import 'package:expensio/widgets/currency.dart';
import 'package:flutter/material.dart';

class AccountsSlider extends StatefulWidget {
  final List<Account> accounts;
  const AccountsSlider({super.key, required this.accounts});
  @override
  State<StatefulWidget> createState() => _AccountSlider();
}

class _AccountSlider extends State<AccountsSlider> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 180,
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.accounts.length,
            controller: _pageController,
            onPageChanged: (int index) {
              setState(() {
                _selected = index;
              });
            },
            itemBuilder: (BuildContext builder, int index) {
              final account = widget.accounts[index];
              return AnimatedScale(
                scale: index == _selected ? 1.0 : 0.95,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: index == _selected ? 1.0 : 0.6,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        stops: const [0.1, 0.9],
                        colors: [
                          account.color.withOpacity(0.7),
                          account.color.withOpacity(1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: account.color.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CurrencyText(
                            account.balance ?? 0,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text("Balance",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white.withOpacity(0.9))),
                          const Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account.holderName,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    account.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white.withOpacity(0.6)),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Icon(account.icon, color: Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.accounts.length > 1) const SizedBox(height: 10),
        if (widget.accounts.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.accounts.length, (index) {
              return AnimatedContainer(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 300),
                height: 6,
                width: _selected == index ? 22 : 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _selected == index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(30),
                ),
              );
            }),
          ),
      ],
    );
  }
}

