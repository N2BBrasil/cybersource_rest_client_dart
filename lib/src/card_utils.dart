class CardUtils {
  static bool validateCardNumber(String ccNum) {
    if (ccNum.isEmpty) return false;

    ccNum = ccNum.replaceAll(RegExp(r'\D'), '');

    if (ccNum.length < 13 || ccNum.length > 19) {
      return false;
    }

    return checkLuhnValidity(ccNum);
  }

  static bool checkLuhnValidity(String ccNum) {
    int sum = 0;
    bool alternate = false;

    for (int i = ccNum.length - 1; i >= 0; i--) {
      int digit = int.parse(ccNum[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;

      alternate = !alternate;
    }

    return sum % 10 == 0;
  }
}
