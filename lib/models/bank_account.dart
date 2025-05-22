class BankAccount {
  final int id;
  final int supermarketId;
  final String bankName;
  final String accountNumber;
  final String? iban;
  final String? accountHolderName;
  final String? bankLogo;

  BankAccount({
    required this.id,
    required this.supermarketId,
    required this.bankName,
    required this.accountNumber,
    this.iban,
    this.accountHolderName,
    this.bankLogo,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) => BankAccount(
    id: json['id'],
    supermarketId: json['supermarket_id'],
    bankName: json['bank_name'],
    accountNumber: json['account_number'],
    iban: json['iban'],
    accountHolderName: json['account_holder_name'],
    bankLogo: json['bank_logo'],
  );
}
