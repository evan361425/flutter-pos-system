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
  10: <String>[
    '''ALTER TABLE `order_records` ADD COLUMN `periodSeq` INTEGER DEFAULT 0;''',
    '''UPDATE order_records SET `periodSeq` = `id`;''',
  ],
  11: <String>[
    '''CREATE TABLE `sync_queue` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  payload TEXT NOT NULL,
  endpoint TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  retry_count INTEGER NOT NULL DEFAULT 0,
  error_message TEXT DEFAULT NULL,
  created_at INTEGER NOT NULL
);''',
    '''CREATE INDEX idx_sync_queue_status ON `sync_queue` (status);''',
    '''CREATE INDEX idx_sync_queue_created_at ON `sync_queue` (created_at);''',
  ],
  12: <String>[
    'ALTER TABLE `order_records` ADD COLUMN `payments` TEXT DEFAULT NULL;',
    'ALTER TABLE `order_records` ADD COLUMN `totalTax` REAL NOT NULL DEFAULT 0;',
    'ALTER TABLE `order_products` ADD COLUMN `taxRate` REAL NOT NULL DEFAULT 0;',
  ],
  13: <String>[
    '''CREATE TABLE `rooms` (
  id TEXT PRIMARY KEY NOT NULL,
  name BLOB NOT NULL DEFAULT "",
  sequence INTEGER NOT NULL DEFAULT 0
);''',
    '''CREATE TABLE `dining_tables` (
  id TEXT PRIMARY KEY NOT NULL,
  room_id TEXT NOT NULL,
  name BLOB NOT NULL DEFAULT "",
  seats INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'available'
);''',
    'CREATE INDEX idx_dining_tables_room_id ON `dining_tables` (room_id);',
    'ALTER TABLE `order_records` ADD COLUMN `table_id` TEXT DEFAULT NULL;',
    'ALTER TABLE `order_records` ADD COLUMN `pax` INTEGER DEFAULT NULL;',
    'ALTER TABLE `order_stash` ADD COLUMN `table_id` TEXT DEFAULT NULL;',
    'ALTER TABLE `order_stash` ADD COLUMN `pax` INTEGER DEFAULT NULL;',
    'CREATE INDEX idx_order_stash_table_id ON `order_stash` (table_id);',
  ],
  14: <String>[
    '''CREATE TABLE `employees` (
  id TEXT PRIMARY KEY NOT NULL,
  name BLOB NOT NULL DEFAULT "",
  passcode TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'server'
);''',
    'CREATE UNIQUE INDEX idx_employees_passcode ON `employees` (passcode);',
    'ALTER TABLE `order_records` ADD COLUMN `employee_id` TEXT DEFAULT NULL;',
    'ALTER TABLE `order_stash` ADD COLUMN `employee_id` TEXT DEFAULT NULL;',
    'CREATE INDEX idx_order_records_employee_id ON `order_records` (employee_id);',
    'CREATE INDEX idx_order_stash_employee_id ON `order_stash` (employee_id);',
  ],
  15: <String>[
    '''CREATE TABLE `shifts` (
  id TEXT PRIMARY KEY NOT NULL,
  employee_id TEXT NOT NULL,
  start_time INTEGER NOT NULL,
  end_time INTEGER DEFAULT NULL,
  starting_cash REAL NOT NULL DEFAULT 0,
  actual_ending_cash REAL DEFAULT NULL,
  status TEXT NOT NULL DEFAULT 'open'
);''',
    'CREATE INDEX idx_shifts_status ON `shifts` (status);',
    'CREATE INDEX idx_shifts_employee_id ON `shifts` (employee_id);',
    'ALTER TABLE `order_records` ADD COLUMN `shift_id` TEXT DEFAULT NULL;',
    'CREATE INDEX idx_order_records_shift_id ON `order_records` (shift_id);',
  ],
  16: <String>[
    '''CREATE TABLE `product_mappings` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  local_product_id TEXT NOT NULL,
  external_product_id TEXT NOT NULL,
  external_variant_id TEXT DEFAULT NULL
);''',
    'CREATE UNIQUE INDEX idx_product_mappings_local ON `product_mappings` (local_product_id);',
    'CREATE INDEX idx_product_mappings_external ON `product_mappings` (external_product_id, external_variant_id);',
  ],
  17: <String>[
    'ALTER TABLE `order_products` ADD COLUMN `note` BLOB DEFAULT "";',
  ],
};
