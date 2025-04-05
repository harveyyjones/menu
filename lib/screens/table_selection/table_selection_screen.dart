import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class TableSelectionScreen extends StatefulWidget {
  const TableSelectionScreen({Key? key}) : super(key: key);

  @override
  State<TableSelectionScreen> createState() => _TableSelectionScreenState();
}

class _TableSelectionScreenState extends State<TableSelectionScreen> {
  List<int> _occupiedTables = [];
  List<int> _reservedTables = [];
  List<int> _availableTables = [];
  int? _selectedTable;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTableData();
  }

  Future<void> _loadTableData() async {
    try {
      final String jsonString = await rootBundle.loadString('mock_data/restaurant_meta.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      setState(() {
        _occupiedTables = List<int>.from(jsonData['occupiedTables']);
        _reservedTables = List<int>.from(jsonData['reservedTables']);
        _availableTables = List<int>.from(jsonData['availableTables']);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading table data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTable(int tableNumber) {
    final bool isOccupied = _occupiedTables.contains(tableNumber);
    final bool isReserved = _reservedTables.contains(tableNumber);
    final bool isAvailable = _availableTables.contains(tableNumber);
    final bool isSelected = _selectedTable == tableNumber;

    Color backgroundColor = Colors.white;
    Color borderColor = AppTheme.divider;
    double opacity = 1.0;

    if (isOccupied) {
      backgroundColor = AppTheme.disabledBackground;
      opacity = 0.5;
    } else if (isReserved) {
      borderColor = AppTheme.accent;
      borderColor = borderColor.withOpacity(0.5);
    } else if (isSelected) {
      backgroundColor = AppTheme.accent.withOpacity(0.1);
      borderColor = AppTheme.accent;
    }

    return GestureDetector(
      onTap: isAvailable ? () {
        setState(() {
          _selectedTable = tableNumber;
        });
      } : null,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: isReserved ? 2 : 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Opacity(
          opacity: opacity,
          child: Center(
            child: Text(
              tableNumber.toString(),
              style: AppTheme.subheadingStyle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: Text('Select Table', style: AppTheme.headingStyle),
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Tables',
                  style: AppTheme.subheadingStyle,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildLegendItem('Available', Colors.white, AppTheme.divider),
                    const SizedBox(width: 16),
                    _buildLegendItem('Occupied', AppTheme.disabledBackground, AppTheme.divider),
                    const SizedBox(width: 16),
                    _buildLegendItem('Reserved', Colors.white, AppTheme.accent, isDashed: true),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 30,
              itemBuilder: (context, index) {
                return _buildTable(index + 1);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedTable != null
                    ? () {
                        // TODO: Navigate to order confirmation
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _selectedTable != null
                      ? 'Continue with Table ${_selectedTable}'
                      : 'Select a Table',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color backgroundColor, Color borderColor, {bool isDashed = false}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: borderColor,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTheme.bodyStyle.copyWith(
            color: AppTheme.secondaryText,
          ),
        ),
      ],
    );
  }
} 