# Search Highlighting Feature

This document describes the new search highlighting functionality implemented for menu objects.

## Feature Overview

When searching for menu products, the system now highlights matching text in:
- Product names
- Catalog names  
- Ingredient names
- Quantity names

## Visual Examples

### 1. Product Name Match
**Search term:** "pizza"
**Result:**
```
🍕 **Pizza** Margherita
```

### 2. Catalog Name Match
**Search term:** "italian"
**Result:**
```
🍕 Pizza Margherita
   Matches:
   • Catalog: **Italian** Food
```

### 3. Ingredient Name Match
**Search term:** "tomato"
**Result:**
```
🍕 Pizza Margherita
   Matches:
   • Ingredient: **Tomato** Sauce
```

### 4. Quantity Name Match
**Search term:** "large"
**Result:**
```
🍕 Pizza
   Matches:
   • Cheese (Extra **Large**)
```

### 5. Multiple Matches
**Search term:** "special"
**Result:**
```
🍕 **Special** Pizza
   Matches:
   • Ingredient: **Special** Sauce
   • Cheese (**Special** Size)
```

## Technical Implementation

### Components
- **HighlightText**: A reusable component that highlights matching text patterns
- **SearchProductMatch**: Data model that analyzes and tracks match details
- **Enhanced SearchBarWrapper**: Updated to work with detailed match information

### Key Features
- Case-insensitive matching while preserving original case
- Handles overlapping and adjacent matches
- Supports multiple word search patterns
- Customizable highlight styles
- Comprehensive test coverage

### API Usage

```dart
// Basic highlighting
HighlightText(
  text: 'Pizza Margherita',
  pattern: 'pizza',
)

// Search with detailed matches
final matches = Menu.instance.searchProductsWithMatches(text: 'tomato');
for (final match in matches) {
  print('Product: ${match.product.name}');
  print('Has product match: ${match.productNameMatches}');
  print('Has catalog match: ${match.catalogNameMatches}');
  print('Ingredient matches: ${match.ingredientMatches.length}');
}
```

## Benefits

1. **Better User Experience**: Users can quickly see why a product appeared in search results
2. **Faster Navigation**: Clear visual indicators help users find what they're looking for
3. **Complete Context**: Shows matches in catalog names, ingredients, and quantities
4. **Accessibility**: Maintains semantic structure for screen readers
5. **Performance**: Efficient highlighting algorithm with minimal overhead