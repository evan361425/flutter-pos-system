const up = <String>[
  '''CREATE TABLE `order` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  paid REAL NOT NULL,
  totalPrice REAL NOT NULL,
  totalCount INTEGER NOT NULL,
  createdAt INTEGER NOT NULL,
  usedProducts TEXT NOT NULL,
  usedIngredients TEXT NOT NULL,
  encodedProducts BLOB NOT NULL
);
''',
  '''CREATE TABLE `order_stash` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  createdAt INTEGER NOT NULL,
  encodedProducts BLOB NOT NULL
);
''',
  '''CREATE INDEX idx_order_created_at
ON `order` (createdAt);
''',
];
