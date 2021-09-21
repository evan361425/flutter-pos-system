const DB_MIG_UP = <int, List<String>>{
  1: <String>[
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
  ],
  2: <String>[
    '''CREATE TABLE `customer_settings` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  `name` TEXT NOT NULL,
  `index` INTEGER NOT NULL,
  mode TEXT NOT NULL
);''',
    '''CREATE TABLE `customer_setting_options` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customerSettingId INTEGER,
  `name` TEXT NOT NULL,
  `index` INTEGER NOT NULL,
  isDefault INTEGER NOT NULL,
  modeValue REAL
);''',
    '''CREATE TABLE `customer_setting_combinations` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  combination TEXT NOT NULL UNIQUE
);''',
    '''ALTER TABLE `order`
ADD COLUMN customerSettingCombinationId INTEGER;''',
  ],
  3: <String>[
    '''CREATE TABLE `menu_catalogs` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  `name` TEXT NOT NULL,
  `index` INTEGER NOT NULL,
  createdAt INTEGER NOT NULL,
  deletedAt INTEGER
);''',
// Add index on catalogId
    '''CREATE TABLE `menu_products` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  catalogId INTEGER NOT NULL,
  `name` TEXT NOT NULL,
  `index` INTEGER NOT NULL,
  price REAL NOT NULL,
  cost REAL NOT NULL,
  createdAt INTEGER NOT NULL,
  deletedAt INTEGER,
  searchedAt INTEGER
);''',
//  Add index on productId
    '''CREATE TABLE `menu_product_ingredients` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  productId INTEGER NOT NULL,
  ingredientId INTEGER NOT NULL,
  amount REAL NOT NULL,
  deletedAt INTEGER
);''',
// 123:12,321:2 代表「成分 123 配上 份量 12」和「成分 321 配上 份量 2」
// Add index on productId
    '''CREATE TABLE `product_ingredient_combinations` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  productId INTEGER NOT NULL,
  combinations TEXT NOT NULL
);''',
// Add index on productIngredientId
    '''CREATE TABLE `menu_product_quantities` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  productIngredientId INTEGER NOT NULL,
  quantityId INTEGER NOT NULL,
  amount REAL NOT NULL,
  additionalPrice REAL NOT NULL,
  additionalCost REAL NOT NULL,
  deletedAt INTEGER
);''',
    '''CREATE TABLE `ingredients` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  `name` TEXT NOT NULL,
  currentAmount REAL,
  warningAmount REAL,
  alertAmount REAL,
  lastAmount REAL,
  lastAddAmount REAL,
  createdAt INTEGER NOT NULL,
  deletedAt INTEGER,
  updatedAt INTEGER
);''',
    '''CREATE TABLE `quantities` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  `name` TEXT NOT NULL,
  defaultProportion REAL NOT NULL
);''',
    '''CREATE TABLE `replenishers` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  `name` TEXT NOT NULL
);''',
    '''CREATE TABLE `replenisher_items` (
  replenisherId INTEGER NOT NULL,
  ingredientId INTEGER NOT NULL,
  amount REAL NOT NULL
);''',
    '''CREATE TABLE `cashier` (
  unit REAL NOT NULL,
  `count` INTEGER NOT NULL
);''',
    '''CREATE TABLE `changer` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  `index` INTEGER NOT NULL,
  sourceUnit REAL NOT NULL,
  sourceCount INTEGER NOT NULL,
  detination TEXT NOT NULL
);''',
// day: 1~7
    '''CREATE TABLE `dates` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  `year` INTEGER NOT NULL,
  `month` INTEGER NOT NULL,
  `day` INTEGER NOT NULL,
  `weekday` INTEGER NOT NULL
);''',
    '''CREATE TABLE `order` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customerCombinationId INTEGER NOT NULL,
  paid REAL NOT NULL,
  totalPrice REAL NOT NULL,
  totalCount INTEGER NOT NULL,
  dateId INTEGER NOT NULL,
  createdTime INTEGER NOT NULL,
  deletedAt INTEGER
);''',
    '''CREATE TABLE `order_products` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  `index` INTEGER NOT NULL,
  orderId INTEGER NOT NULL,
  productId INTEGER NOT NULL,
  ingredientCombinationId INTEGER
);''',
  ],
};
