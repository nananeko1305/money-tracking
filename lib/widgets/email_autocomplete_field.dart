import 'package:flutter/material.dart';

import '../app_scope.dart';

/// Email field that suggests emails used on this phone before while typing
/// (or all of them when empty and focused). Each suggestion can be removed.
class EmailAutocompleteField extends StatelessWidget {
  const EmailAutocompleteField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.suggestions,
    required this.onSelected,
    required this.onRemove,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> suggestions;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (value) {
        final q = value.text.trim().toLowerCase();
        return suggestions.where((e) => e.contains(q) && e != q);
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          onFieldSubmitted: (_) => onSubmit(),
          decoration: InputDecoration(
            labelText: t.email,
            prefixIcon: const Icon(Icons.alternate_email),
          ),
          validator: (v) =>
              (v == null || !v.contains('@')) ? t.invalidEmail : null,
        );
      },
      optionsViewBuilder: (context, onSelect, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 260,
                // Same width as the field (screen minus the page padding).
                maxWidth: MediaQuery.sizeOf(context).width - 56,
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  for (final email in options)
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(email, overflow: TextOverflow.ellipsis),
                      onTap: () => onSelect(email),
                      trailing: IconButton(
                        tooltip: t.delete,
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => onRemove(email),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
