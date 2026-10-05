import 'package:flutter/material.dart';

import '../common/hub_content_frame.dart';
import '../hub_style.dart';
import 'hub_navigation_button.dart';
import 'hub_tab.dart';

class HubNavigationBar extends StatelessWidget {
  const HubNavigationBar({
    required this.selectedTab,
    required this.hasClaimableQuest,
    required this.onTabSelected,
    super.key,
  });

  static const _topRadius = Radius.circular(26);

  final HubTab selectedTab;
  final bool hasClaimableQuest;
  final ValueChanged<HubTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: HubStyle.navigationBar,
        borderRadius: BorderRadius.only(
          topLeft: _topRadius,
          topRight: _topRadius,
        ),
        border: Border(top: BorderSide(color: HubStyle.panelBorder, width: 2)),
        boxShadow: [BoxShadow(color: HubStyle.deepNavy, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: HubContentFrame(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final tab in HubTab.values)
                  Expanded(
                    child: HubNavigationButton(
                      tab: tab,
                      isSelected: tab == selectedTab,
                      hasBadge: tab == HubTab.quests && hasClaimableQuest,
                      onTap: () => onTabSelected(tab),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
