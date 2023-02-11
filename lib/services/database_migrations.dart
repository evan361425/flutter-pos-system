const dbMigrationUp = <int, List<String>>{
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
  4: <String>[
    '''CREATE TABLE `customer_settings` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  `name` TEXT NOT NULL,
  `index` INTEGER NOT NULL,
  isDelete INTEGER NOT NULL DEFAULT 0,
  mode INTEGER NOT NULL
);''',
    '''CREATE TABLE `customer_setting_options` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customerSettingId INTEGER,
  `name` TEXT NOT NULL,
  `index` INTEGER NOT NULL,
  isDefault INTEGER NOT NULL DEFAULT 0,
  modeValue REAL,
  isDelete INTEGER NOT NULL DEFAULT 0
);''',
    '''CREATE TABLE `customer_setting_combinations` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  combination TEXT NOT NULL UNIQUE
);''',
    'ALTER TABLE `order` ADD COLUMN customerSettingCombinationId INTEGER;',
    'ALTER TABLE `order` ADD COLUMN productsPrice REAL;',
    'ALTER TABLE `order_stash` ADD COLUMN customerSettingCombinationId INTEGER;',
    'CREATE INDEX idx_customer_setting_options_id ON `customer_setting_options` (customerSettingId);'
  ],
  5: <String>[
    'ALTER TABLE `order` ADD COLUMN `cost` INTEGER DEFAULT 0;',
  ],
  6: <String>[
    'ALTER TABLE `order` ADD COLUMN `encodedAttributes` BLOB DEFAULT "";',
    'ALTER TABLE `order_stash` ADD COLUMN `encodedAttributes` BLOB DEFAULT "";',
  ],
  7: <String>[
    'ALTER TABLE `order` DROP COLUMN `customerSettingCombinationId`;',
    'ALTER TABLE `order` ADD COLUMN `catalogName` BLOB DEFAULT "";',
    'ALTER TABLE `order_stash` DROP COLUMN `customerSettingCombinationId`;',
    'DROP TABLE `customer_settings`;',
    'DROP TABLE `customer_setting_options`;',
    'DROP TABLE `customer_setting_combinations`;',
  ],
};
