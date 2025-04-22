# Big Szef Menu Application Documentation

## Core Components

### 1. Menu Provider (`lib/features/menu/providers/menu_provider.dart`)
The central state management hub using Riverpod.

```dart
// Key Providers:
- menuProvider: StreamProvider<List<MenuItem>> // Real-time menu data from Firestore
- menuItemProvider: Provider.family<MenuItem?, String> // Single item lookup by ID
- menuItemsByCategoryProvider: Provider.family<List<MenuItem>, String> // Category filtering
```

**Important Notes:**
- Uses Firestore for real-time data synchronization
- Implements category filtering with 'All' as a special case
- Handles null cases with a mock item for better error handling

### 2. MenuItem Model (`lib/features/menu/models/menu_item.dart`)
Core data structure for menu items.

```dart
class MenuItem {
  final String id;
  final String name;
  final String category;
  final int cookTimeMinutes;
  final double price;
  final String imageUrl;
  final int gram;
  final double rating;
}
```

**Usage:**
- All fields are required to maintain data consistency
- Used throughout the app for type-safe data handling

### 3. HomeScreen (`lib/screens/home/home_screen.dart`)
Main entry point of the application.

**Key Features:**
- Responsive layout with breakpoints at 800px and 1200px
- Integrates category navigation and menu grid
- Handles cart state display
- Adapts layout between mobile and desktop views

### 4. ProductDetailScreen (`lib/features/menu/screens/product_detail_screen.dart`)
Detailed view for individual menu items.

**Features:**
- Displays comprehensive item information
- Uses menuItemProvider for data fetching
- Responsive layout for all screen sizes
- Loading state handling

### 5. MenuItemGrid (`lib/components/menu_item_grid.dart`)
Grid display component for menu items.

**Implementation Details:**
- Responsive grid layout (2-4 columns based on screen width)
- Handles navigation to ProductDetailScreen
- Integrates with cart functionality
- Implements loading states and error handling

### 6. CategoryScroll (`lib/components/category_scroll.dart`)
Navigation component for category filtering.

**Features:**
- Supports both horizontal and vertical layouts
- Maintains selected category state
- Responsive design adaptation

## State Management

### Provider Structure
```
menuProvider (root)
  ├─ menuItemProvider
  └─ menuItemsByCategoryProvider
```

### Data Flow
1. Firestore Stream → menuProvider
2. menuProvider → menuItemsByCategoryProvider → UI
3. menuProvider → menuItemProvider → ProductDetailScreen

## Styling and Theming

All styling is centralized in `lib/constants/app_theme.dart`:
- Primary colors
- Text styles
- Component-specific themes

## Best Practices for Modifications

1. **Adding New Features:**
   - Follow the existing feature folder structure
   - Implement providers before UI components
   - Use nullable types with appropriate fallbacks

2. **Modifying Existing Components:**
   - Maintain responsive breakpoints consistency
   - Keep grid layout calculations aligned
   - Preserve loading state handling

3. **Data Model Changes:**
   - Update both model and Firestore structure
   - Maintain JSON serialization
   - Consider migration strategy for existing data

## Firebase Integration

- Collection: 'products'
- Real-time updates enabled
- Requires appropriate security rules
- Handles offline persistence automatically

## Performance Considerations

- Grid images are loaded lazily
- Category filtering happens at the provider level
- Firestore queries are optimized for real-time updates
- Responsive images with appropriate aspect ratios

## Testing Guidelines

1. **Provider Testing:**
   - Mock Firestore responses
   - Test category filtering logic
   - Verify null handling

2. **UI Testing:**
   - Test responsive breakpoints
   - Verify loading states
   - Check navigation flow

3. **Integration Testing:**
   - Test Firestore integration
   - Verify real-time updates
   - Check offline behavior 