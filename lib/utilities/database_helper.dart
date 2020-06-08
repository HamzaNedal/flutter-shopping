import 'dart:io';
import 'package:scoped_model/scoped_model.dart';
import 'package:testonetest/models/Address.dart';
import 'package:testonetest/models/data.dart';
import 'package:testonetest/models/orderItem.dart';
import 'package:testonetest/models/orders.dart';
import 'package:testonetest/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:testonetest/model/Product.dart';


class DatabaseHelper extends Model {
  static Database _db;
  final String userTable = 'users';
  final String columnId = 'id';
  final String columnName = 'name';
  final String columnEmail = 'email';
  final String columnPassword = 'password';
  final String columnType = 'type';
  final String columnAddress = 'address';
  final String columnDateOfLogin = 'date_of_login';

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await intDB();

    return _db;
  }

  intDB() async {
    Directory dir = await getExternalStorageDirectory();
    String path = join(dir.path, 'shop.db');
    var myOwnDB = await openDatabase(path, version: 1, onCreate: _onCreate);
    return myOwnDB;
  }

  _onCreate(Database db, int newVersion) async {
    var sqlUserTable = '''
        CREATE TABLE $userTable 
        ($columnId INTEGER PRIMARY KEY autoincrement,
         $columnName TEXT,
         $columnEmail TEXT,
         $columnPassword TEXT,
         $columnAddress INTEGER,
         $columnType INTEGER DEFAULT 0,
         $columnDateOfLogin INTEGER DEFAULT 0
        )
        ''';
    var sqlCategoriesTable = '''
        CREATE TABLE categories 
        (
          category_id INTEGER PRIMARY KEY autoincrement,
	        category_name TEXT NOT NULL
        )
        ''';
    var sqlProductsTable = '''
        CREATE TABLE products (
          product_id INTEGER PRIMARY KEY autoincrement,
          title TEXT NOT NULL,
          description TEXT,
          price REAL,
          image BLOB,
          category_id INTEGER NOT NULL,
          user_id INTEGER NOT NULL,
          FOREIGN KEY (category_id) 
                REFERENCES categories (category_id) 
                ON DELETE CASCADE
        )
        ''';
    var sqlOrdersTable = '''
        CREATE TABLE orders 
        (
          order_id INTEGER  PRIMARY KEY autoincrement,
          customer_id INTEGER,
          product_id INTEGER,
          order_status INTEGER NOT NULL,
          order_date DATE,
          FOREIGN KEY (customer_id) 
                REFERENCES users (id) 
                ON DELETE CASCADE
        )
        ''';
    var sqlOrdersItemsTable = '''
       CREATE TABLE order_items(
        order_id INTEGER PRIMARY KEY autoincrement,
        product_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        address_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (product_id) 
              REFERENCES products (product_id) 
              ON DELETE CASCADE,
        FOREIGN KEY (address_id) 
              REFERENCES address (address_id) 
              ON DELETE CASCADE,
         FOREIGN KEY (user_id) 
              REFERENCES users (id) 
              ON DELETE CASCADE
      )
        ''';
    var sqlAddressTable = '''
       CREATE TABLE address(
        address_id INTEGER PRIMARY KEY,
        user_id INTEGER,
        name TEXT,
        addressline TEXT,
        city TEXT,
        zip INTEGER,
        phone INTEGER,
        FOREIGN KEY (user_id) 
              REFERENCES users (id) 
              ON DELETE CASCADE
      )
        ''';
    var sqlCart = '''CREATE TABLE cart_list ( 
        id INTEGER PRIMARY KEY,
        product_id INTEGER,
        user_id INTEGER,
        name TEXT,
        image Text,
        price REAL,
        quantity INTEGER,
        fav INTEGER,
        rating REAL,
        datetime DATETIME,
        FOREIGN KEY (user_id) 
              REFERENCES users (id) 
              ON DELETE CASCADE,
        FOREIGN KEY (product_id) 
              REFERENCES products (product_id) 
              ON DELETE CASCADE
        )''';
    await db.execute(sqlCart);
    await db.execute(sqlUserTable);
    await db.execute(sqlCategoriesTable);
    await db.execute(sqlProductsTable);
    await db.execute(sqlOrdersTable);
    await db.execute(sqlOrdersItemsTable);
    await db.execute(sqlAddressTable);

    await db
        .rawQuery("INSERT INTO categories (category_name) VALUES ('Mobile')");
    await db.rawQuery("INSERT INTO categories (category_name) VALUES ('PC')");
    await db
        .rawQuery("INSERT INTO categories (category_name) VALUES ('Games')");
    await db.rawQuery("INSERT INTO categories (category_name) VALUES ('Man')");
    await db
        .rawQuery("INSERT INTO categories (category_name) VALUES ('Women')");
    await db.rawQuery("INSERT INTO categories (category_name) VALUES ('Kid')");
  }

  Future<int> registerUser(User user) async {
    var dbregister = await db;
    int result = await dbregister.insert('$userTable', user.toMap());
    return result;
  }

  Future<int> insertCategory(String name) async {
    var dbregister = await db;
    int result = await dbregister
        .rawInsert("INSERT INTO categories (category_name) VALUES ('$name')");
    return result;
  }

  Future<List> login(String email, String password) async {
    var dbSaveSetting = await db;
    var sql =
        'select * from $userTable Where email = "$email" and password = "$password"';
    List result = await dbSaveSetting.rawQuery(sql);
    return result;
  }

  Future<int> saveProduct(Product product) async {
    var dbregister = await db;
    int result = await dbregister.insert('products', product.toMap());
    return result;
  }

  Future<dynamic> getProductsSeller(int id) async {
    var dbs = await db;
    var sql = 'select * from products Where user_id = $id';
    List result = await dbs.rawQuery(sql);
    return result;
  }

  Future<dynamic> getProductByID(int id) async {
    var dbs = await db;
    var sql = 'select * from products Where product_id = $id';
    List result = await dbs.rawQuery(sql);
    return result.first;
  }

  Future<dynamic> getProductByCategoryID(int id) async {
    var dbs = await db;
    var sql = 'select * from products Where category_id = $id';
    List result = await dbs.rawQuery(sql);
    return result;
  }

  Future<dynamic> getAllProducts() async {
    var dbs = await db;
    var sql = 'select * from products';
    List result = await dbs.rawQuery(sql);
    return result;
  }

  Future<int> editProduct(int id, Product product) async {
    print(id);
    var dbs = await db;
    int result = await dbs.rawUpdate(
        'UPDATE products SET title = ?, description = ? ,category_id = ? ,price = ? ,image = ? WHERE product_id = ?',
        [
          "${product.title}",
          "${product.description}",
          product.category_id,
          product.price,
          "${product.image}",
          id
        ]);
    return result;
  }

  Future<int> deleteProduct(int id) async {
    var dbs = await db;
    int result =
        await dbs.rawDelete("DELETE FROM products WHERE product_id = $id");
    return result;
  }

  Future<dynamic> getCategories() async {
    var dbs = await db;
    var sql = 'select * from categories';
    List result = await dbs.rawQuery(sql);
    return result;
  }

  Future<dynamic> getCategoryIdByName(String name) async {
    var dbs = await db;
    var sql =
        'select category_id from categories where category_name = "$name"';
    List result = await dbs.rawQuery(sql);
    return result.first;
  }

  Future<dynamic> InsertInCart(Data d) async {
    var dbs = await db;
    await dbs.transaction((tx) async {
      try {
        var qry =
            'INSERT INTO cart_list(product_id,user_id,quantity,name, price, image) VALUES(${d.product_id},${d.user_id},${d.quantity},"${d.title}",${d.price}, "${d.image}")';
        await tx.execute(qry);
      } catch (e) {
        print("ERRR @@ @@");
        print(e);
      }
    });
  }

  Future<dynamic> getDataCart(int id) async {
    var dbs = await db;
    var sql = 'select * from cart_list where user_id = $id';
    List result = await dbs.rawQuery(sql);
    return result;
  }

  Future<int> removeProductFoeUserFromCart(int id) async {
    var dbs = await db;
    var sql = 'DELETE FROM cart_list WHERE user_id = $id';
    int result = await dbs.rawDelete(sql);
    return result;
  }

  Future<int> saveAddress(AddressModel addess) async {
    var dbregister = await db;
    int result = await dbregister.insert('address', addess.toMap());
    return result;
  }

  Future<List> getDataAddeess(int id) async {
    var dbs = await db;
    var sql = 'select * from address where user_id = $id';
    List result = await dbs.rawQuery(sql);
    return result;
  }

  Future<int> saveOrders(Orders addess) async {
    var dbregister = await db;
    int result = await dbregister.insert('orders', addess.toMap());
    return result;
  }

  Future<int> saveOrdersItem(OrderItem addess) async {
    var dbregister = await db;
    int result = await dbregister.insert('order_items', addess.toMap());
    return result;
  }

  Future<List> getOrdersForCustomer(int id) async {
    var dbs = await db;
    var sql =
        '''SELECT  products.title,products.description,products.price,products.image,order_items.quantity,orders.order_status
                  FROM products
                  INNER JOIN order_items
                  ON order_items.product_id = products.product_id And order_items.user_id = $id
                  INNER JOIN orders
                  ON products.product_id = orders.product_id And orders.customer_id = $id''';
    List result = await dbs.rawQuery(sql);
    return result;
  }

  Future<List> getOrdersForSeller(int user_id) async {
    var dbs = await db;
    var sql =
        '''SELECT products.title,products.description,products.price,products.image,
          order_items.quantity,orders.order_status,orders.order_id,
          address.city,address.name,address.addressline
                  FROM products
                  INNER JOIN order_items
                  ON order_items.product_id = products.product_id
                  INNER JOIN orders
                  ON orders.product_id = products.product_id And order_status = 0
                  INNER JOIN address
                  ON address.address_id = order_items.address_id
                  And products.user_id = $user_id
                  ''';
    List result = await dbs.rawQuery(sql);
    return result;
  }
   Future<int> updateOrderStatus(int id, int order_status) async {
    var dbSaveSetting = await db;
    return await dbSaveSetting
        .rawUpdate('UPDATE orders SET order_status = ?  WHERE order_id = ?', [order_status, id]);
  }
  Future<dynamic> findByEmail(String email) async {
    var dbSaveSetting = await db;
    var sql = 'select * from $userTable Where email = "$email" ';
    var result = await dbSaveSetting.rawQuery(sql);
    if (result.length == 0) return null;
    return result.first;
  }

  Future<dynamic> findByID(int id) async {
    var dbSaveSetting = await db;
    var sql = 'select * from $userTable Where id = "$id" ';
    var result = await dbSaveSetting.rawQuery(sql);
    if (result.length == 0) return null;
    return result.first;
  }

  Future<int> update(int id, String path) async {
    var dbSaveSetting = await db;
    return await dbSaveSetting
        .rawUpdate('UPDATE $userTable SET path = ?  WHERE id = ?', [path, id]);
  }

  Future<void> close() async {
    var dbSaveSetting = await db;
    return await dbSaveSetting.close();
  }
}
