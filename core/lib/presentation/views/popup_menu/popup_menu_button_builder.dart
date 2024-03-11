import 'package:core/presentation/action/popup_menu_action.dart';
import 'package:core/presentation/views/popup_menu/popup_menu_item_widget.dart';
import 'package:flutter/material.dart';

class PopupMenuButtonBuilder<T> extends StatelessWidget {

  final Widget child;
  final List<PopupMenuAction<T>> listAction;

  const PopupMenuButtonBuilder({
    super.key,
    required this.child,
    required this.listAction,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      position: PopupMenuPosition.under,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      padding: EdgeInsets.zero,
      tooltip: '',
      constraints: const BoxConstraints(minWidth: 256),
      itemBuilder: (_) => listAction
        .map((action) => _buildPopupMenuItem(context, action))
        .toList(),
      child: child,
    );
  }

  PopupMenuEntry<T> _buildPopupMenuItem(BuildContext context, PopupMenuAction<T> action) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      height: 36,
      child: PopupMenuItemWidget(
        name: action.name,
        icon: action.icon,
        height: 36,
        iconColor: Colors.black87,
        onCallbackAction: () => action.onSelected(action.value)
      )
    );
  }
}