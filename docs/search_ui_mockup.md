# Search UI Mockup

This document shows how the enhanced search interface will appear to users.

## Before (Current Implementation)
```
┌─────────────────────────────────────────┐
│ 🔍 Search products...                   │
└─────────────────────────────────────────┘

Search results for "tomato":
┌─────────────────────────────────────────┐
│ 🍕 Pizza Margherita                     │
│                                         │
│ 🍝 Pasta Arrabbiata                     │
│                                         │
│ 🥗 Tomato Salad                         │
└─────────────────────────────────────────┘
```

## After (With Highlighting)
```
┌─────────────────────────────────────────┐
│ 🔍 Search products...                   │
└─────────────────────────────────────────┘

Search results for "tomato":
┌─────────────────────────────────────────┐
│ 🍕 Pizza Margherita                     │
│    Matches:                             │
│    • Ingredient: [Tomato] Sauce         │
│                                         │
│ 🍝 Pasta Arrabbiata                     │
│    Matches:                             │
│    • Ingredient: [Tomato] Base          │
│                                         │
│ 🥗 [Tomato] Salad                       │
└─────────────────────────────────────────┘
```

## Complex Search Example
```
Search results for "italian cheese":
┌─────────────────────────────────────────┐
│ 🍕 Margherita Pizza                     │
│    Matches:                             │
│    • Catalog: [Italian] Food            │
│    • Ingredient: Mozzarella [Cheese]    │
│                                         │
│ 🧀 [Cheese] Platter                     │
│    Matches:                             │
│    • Catalog: [Italian] Appetizers      │
│                                         │
│ 🍝 [Cheese] Ravioli                     │
│    Matches:                             │
│    • Catalog: [Italian] Pasta           │
│    • Ricotta [Cheese] (Extra Large)     │
└─────────────────────────────────────────┘
```

Legend:
- `[text]` = Highlighted/bold text (yellow background in actual app)
- `🍕🍝🥗🧀` = Product type icons
- `Matches:` = Subtitle showing what matched the search
- `• Item` = Bulleted list of matching components

## Key UI Improvements

1. **Highlighted Text**: Search terms are visually emphasized with background color
2. **Match Details**: Subtitle shows exactly what parts matched
3. **Context Information**: Users understand why each result appeared
4. **Categorized Matches**: Clear distinction between catalog, ingredient, and quantity matches
5. **Preserved Layout**: Familiar list structure with enhanced information