import 'package:events_emitter/events_emitter.dart';
import 'package:expensio/dao/category_dao.dart';
import 'package:expensio/events.dart';
import 'package:expensio/model/category.model.dart';
import 'package:expensio/widgets/dialog/category_form.dialog.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryDao _categoryDao = CategoryDao();
  EventListener? _categoryEventListener;
  List<Category> _categories = [];

  void loadData() async {
    List<Category> categories = await _categoryDao.find();
    setState(() {
      _categories = categories;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();

    _categoryEventListener = globalEvent.on("category_update", (data) {
      debugPrint("categories are changed");
      loadData();
    });
  }

  @override
  void dispose() {
    _categoryEventListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Categories",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: ListView.separated(
        itemCount: _categories.length,
        itemBuilder: (builder, index) {
          Category category = _categories[index];
          double expenseProgress = (category.expense ?? 0) / (category.budget ?? 0);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Material(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (builder) => CategoryForm(category: category),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: category.color.withOpacity(0.15),
                        child: Icon(category.icon, color: category.color),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            (expenseProgress.isFinite)
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: expenseProgress,
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                color: category.color,
                              ),
                            )
                                : Text(
                              "No budget",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: 4);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (builder) => const CategoryForm(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

}