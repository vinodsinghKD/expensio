import 'package:currency_picker/currency_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:expensio/bloc/cubit/app_cubit.dart';
import 'package:expensio/helpers/color.helper.dart';
import 'package:expensio/helpers/db.helper.dart';
import 'package:expensio/widgets/buttons/button.dart';
import 'package:expensio/widgets/dialog/confirm.modal.dart';
import 'package:expensio/widgets/dialog/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context); // Get current theme for consistency

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          // Profile Settings - Allows user to change the name
          ListTile(
            dense: true,
            onTap: () {
              // Show a dialog for the user to change their name
              showDialog(
                context: context,
                builder: (context) {
                  TextEditingController controller = TextEditingController(
                    text: context.read<AppCubit>().state.username,
                  );

                  return AlertDialog(
                    title: const Text(
                      "Profile",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "What should we call you?",
                          style: theme.textTheme.bodyLarge!.apply(
                            color: ColorHelper.darken(theme.textTheme.bodyLarge!.color!),
                            fontWeightDelta: 1,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            label: const Text("Name"),
                            hintText: "Enter your name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 15),
                          ),
                        )
                      ],
                    ),
                    actions: [
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              onPressed: () {
                                // Check if input is empty, show snackbar if true
                                if (controller.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Please enter name")));
                                } else {
                                  // Save new username in AppCubit
                                  context.read<AppCubit>().updateUsername(controller.text);
                                  Navigator.of(context).pop();
                                }
                              },
                              height: 45,
                              label: "Save",
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
            leading: const CircleAvatar(
              child: Icon(Symbols.person),
            ),
            title: Text(
              'Name',
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ),
            subtitle: BlocBuilder<AppCubit, AppState>(
              builder: (context, state) {
                return Text(
                  state.username!,
                  style: Theme.of(context).textTheme.bodySmall?.apply(
                    color: Colors.grey,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),

          // Currency Settings - Allows user to select currency
          ListTile(
            dense: true,
            onTap: () {
              // Show currency picker dialog
              showCurrencyPicker(
                context: context,
                onSelect: (Currency currency) {
                  // Update selected currency in AppCubit
                  context.read<AppCubit>().updateCurrency(currency.code);
                },
              );
            },
            leading: BlocBuilder<AppCubit, AppState>(
              builder: (context, state) {
                Currency? currency = CurrencyService().findByCode(state.currency!);
                return CircleAvatar(
                  child: Text(currency!.symbol),
                );
              },
            ),
            title: Text(
              'Currency',
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ),
            subtitle: BlocBuilder<AppCubit, AppState>(
              builder: (context, state) {
                Currency? currency = CurrencyService().findByCode(state.currency!);
                return Text(
                  currency!.name,
                  style: Theme.of(context).textTheme.bodySmall?.apply(
                    color: Colors.grey,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),

          // Export Data - Allows user to export data to a file
          ListTile(
            dense: true,
            onTap: () async {
              // Show a confirmation dialog before exporting
              ConfirmModal.showConfirmDialog(
                context,
                title: "Are you sure?",
                content: const Text("Want to export all the data to a file"),
                onConfirm: () async {
                  Navigator.of(context).pop();
                  LoadingModal.showLoadingDialog(context, content: const Text("Exporting data, please wait"));

                  await export().then((value) {
                    // Notify user about file save location
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("File has been saved in $value")));
                  }).catchError((err) {
                    // Show error message if something goes wrong
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Something went wrong while exporting data")));
                  }).whenComplete(() {
                    Navigator.of(context).pop();
                  });
                },
                onCancel: () {
                  Navigator.of(context).pop();
                },
              );
            },
            leading: const CircleAvatar(
              child: Icon(Symbols.download),
            ),
            title: Text(
              'Export',
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ),
            subtitle: Text(
              "Export to file",
              style: Theme.of(context).textTheme.bodySmall?.apply(
                color: Colors.grey,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Import Data - Allows user to import data from a file
          ListTile(
            dense: true,
            onTap: () async {
              // Open file picker to allow the user to select a file
              await FilePicker.platform.pickFiles(
                dialogTitle: "Pick file",
                allowMultiple: false,
                allowCompression: false,
                type: FileType.custom,
                allowedExtensions: ["json"],
              ).then((pick) {
                if (pick == null || pick.files.isEmpty) {
                  return ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select file")));
                }
                PlatformFile file = pick.files.first;
                // Show a confirmation dialog before importing
                ConfirmModal.showConfirmDialog(
                  context,
                  title: "Are you sure?",
                  content: const Text(
                    "All payment data, categories, and accounts will be erased and replaced with the information imported from the backup.",
                  ),
                  onConfirm: () async {
                    Navigator.of(context).pop();
                    LoadingModal.showLoadingDialog(context, content: const Text("Importing data, please wait"));

                    await import(file.path!).then((value) {
                      // Notify user on successful import
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Successfully imported.")));
                      Navigator.of(context).pop();
                    }).catchError((err) {
                      // Handle errors during import
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Something went wrong while importing data")));
                    });
                  },
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                );
              }).catchError((err) {
                // Show error message if something goes wrong
                return ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Something went wrong while importing data")));
              });
            },
            leading: const CircleAvatar(
              child: Icon(Symbols.upload),
            ),
            title: Text(
              'Import',
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ),
            subtitle: Text(
              "Import from backup file",
              style: Theme.of(context).textTheme.bodySmall?.apply(
                color: Colors.grey,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

