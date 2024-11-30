const dbMigrationUp = <int, List<String>>{
  1: <String>[
    '''CREATE TABLE `order_stash` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  createdAt INTEGER NOT NULL,
  encodedProducts BLOB NOT NULL
);
''',
  ],
  6: <String>[
    'ALTER TABLE `order_stash` ADD COLUMN `encodedAttributes` BLOB DEFAULT "";',
  ],
  8: <String>[
    '''CREATE TABLE `order_records` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  paid REAL NOT NULL DEFAULT 0,
  price REAL NOT NULL DEFAULT 0,
  cost REAL NOT NULL DEFAULT 0,
  revenue REAL NOT NULL DEFAULT 0,
  productsPrice REAL NOT NULL DEFAULT 0,
  productsCount INTEGER NOT NULL DEFAULT 0,
  attributesPrice REAL NOT NULL DEFAULT 0,
  createdAt INTEGER NOT NULL DEFAULT 0);''',
    '''CREATE TABLE `order_products` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  orderId INTEGER NOT NULL,
  productName BLOB NOT NULL DEFAULT "",
  catalogName BLOB NOT NULL DEFAULT "",
  count INTEGER NOT NULL DEFAULT 0,
  singleCost REAL NOT NULL DEFAULT 0,
  singlePrice REAL NOT NULL DEFAULT 0,
  originalPrice REAL NOT NULL DEFAULT 0,
  isDiscount INTEGER NOT NULL DEFAULT 0,
  createdAt INTEGER NOT NULL DEFAULT 0);''',
    '''CREATE TABLE `order_ingredients` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  orderId INTEGER NOT NULL,
  orderProductId INTEGER NOT NULL,
  ingredientName BLOB NOT NULL DEFAULT "",
  quantityName BLOB DEFAULT NULL,
  additionalPrice REAL NOT NULL DEFAULT 0,
  additionalCost REAL NOT NULL DEFAULT 0,
  amount REAL NOT NULL DEFAULT 0,
  createdAt INTEGER NOT NULL DEFAULT 0);''',
    '''CREATE TABLE `order_attributes` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  orderId INTEGER NOT NULL,
  name BLOB NOT NULL DEFAULT "",
  optionName BLOB NOT NULL DEFAULT "",
  mode INTEGER NOT NULL DEFAULT 0,
  modeValue REAL DEFAULT NULL,
  createdAt INTEGER NOT NULL DEFAULT 0);''',
    '''CREATE INDEX idx_order_records_created_at ON `order_records` (createdAt);''',
    '''CREATE INDEX idx_order_products_created_at ON `order_products` (createdAt);''',
    '''CREATE INDEX idx_order_ingredients_created_at ON `order_ingredients` (createdAt);''',
    '''CREATE INDEX idx_order_attributes_created_at ON `order_attributes` (createdAt);''',
  ],
  9: <String>[
    'ALTER TABLE `order_records` ADD COLUMN `note` BLOB DEFAULT "";',
    'ALTER TABLE `order_stash` ADD COLUMN `note` BLOB DEFAULT "";',
  ],
};
