import 'package:flutter/material.dart';

class FCSidebarItem {
  final String title;
  final IconData icon;
  final int notificationCount;

  FCSidebarItem({
    required this.title,
    required this.icon,
    this.notificationCount = 0,
  });
}

class FC25Sidebar extends StatelessWidget {
  final List<FCSidebarItem> items;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const FC25Sidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Event Management',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == selectedIndex;
                
                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: item.notificationCount > 0
                      ? Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${item.notificationCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : null,
                  selected: isSelected,
                  onTap: () => onItemSelected(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}