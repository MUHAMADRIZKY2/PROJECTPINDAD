import 'package:flutter/material.dart';

class CategoryTabs extends StatefulWidget {
  final Function(String) onCategorySelected;

  // Konstruktor untuk menerima fungsi callback ketika kategori dipilih
  CategoryTabs({required this.onCategorySelected});

  @override
  _CategoryTabsState createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs> {
  int _selectedIndex = 0;

  // Daftar kategori yang tersedia
  final List<String> _categories = [
    "Kesehatan",
    "Teknologi",
    "Finansial",
    "Seni",
    "Olahraga" // Tambahkan kategori 'Olahraga' di sini
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: RawChip(
              label: Text(_categories[index]),
              selected: _selectedIndex == index,
              onSelected: (selected) {
                setState(() {
                  _selectedIndex = index;
                  // Panggil callback saat kategori dipilih
                  widget.onCategorySelected(_categories[index]);
                });
              },
              selectedColor: Colors.blue,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: _selectedIndex == index ? Colors.white : Colors.black,
                fontSize: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
                side: BorderSide(
                  color: _selectedIndex == index ? Colors.blue : Colors.grey,
                  width: 1.0,
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}
