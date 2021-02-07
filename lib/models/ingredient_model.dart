class IngredientModel {
  String _name;
  double _amount;
  num _cost;
  IngredientModel(this._name, {amount, cost})
      : _amount = amount,
        _cost = cost;

  String get name => _name;
  void setName(String name) {
    _name = name;
  }

  double get amount => _amount;
  void setAmount(double amount) {
    _amount = amount;
  }

  num get cost => _cost;
  void setCost(num cost) {
    _cost = cost;
  }
}
