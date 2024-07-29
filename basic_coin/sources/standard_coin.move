module basic_coin_addr::standard_coin {
    use std::signer;

    const ALREADY_HAS_BALANCE:u64 = 1;
    const BALANCE_IS_NOT_EXIST:u64 = 2;
    const INSUFFICIENT_BALANCE:u64 = 3;
    const FAILED_EXECUTION:u64 = 4;

    struct Coin<phantom CoinType> has store {
        value: u64
    }

    struct Balance<phantom CoinType> has key {
        coin: Coin<CoinType>
    }

    /// Initialize an empty balance resource under `account`'s address. This function must be called before
    /// minting or transferring to the account.
    public entry fun init_account<CoinType>(account: &signer) {
        assert!(!exists<Balance<CoinType>>(signer::address_of(account)), ALREADY_HAS_BALANCE);
        let empty_coin = Coin<CoinType> { value: 0 };
        move_to(account, Balance<CoinType> { coin: empty_coin });
    }

    /// Mint `amount` tokens to `mint_addr`. This method requires a witness with `CoinType` so that the
    /// module that owns `CoinType` can decide the minting policy.
    public fun mint<CoinType: drop>(account: &signer, value: u64, _witnhess: CoinType) acquires Balance {
        assert!(exists<Balance<CoinType>>(signer::address_of(account)), BALANCE_IS_NOT_EXIST);
        let addr = signer::address_of(account);
        deposit(addr, Coin<CoinType> { value })
    }

    /// Transfers `amount` of tokens from `from` to `to`. This method requires a witness with `CoinType` so that the
    /// module that owns `CoinType` can decide the transferring policy.
    public fun transfer<CoinType: drop>(from: &signer, to: address, amount: u64, _witnhess: CoinType) acquires Balance {
        let from_addr = signer::address_of(from);
        assert!(exists<Balance<CoinType>>(from_addr), BALANCE_IS_NOT_EXIST);
        assert!(exists<Balance<CoinType>>(to), BALANCE_IS_NOT_EXIST);
        assert!(from_addr != to, FAILED_EXECUTION);
        let balance = balance_of<CoinType>(from_addr);
        assert!(balance >= amount, INSUFFICIENT_BALANCE);
        let checked_amount = withdraw<CoinType>(from_addr, amount);
        deposit<CoinType>(to, checked_amount);
    }

    public fun burn<CoinType: drop>(account: &signer, amount: u64, _witnhess: CoinType) acquires Balance {
        let addr = signer::address_of(account);
        assert!(exists<Balance<CoinType>>(addr), BALANCE_IS_NOT_EXIST);
        let balance = balance_of<CoinType>(addr);
        assert!(balance >= amount, INSUFFICIENT_BALANCE);
        let Coin { value } = withdraw<CoinType>(addr, amount);
        assert!(value == amount, FAILED_EXECUTION);
    }

    fun withdraw<CoinType>(addr: address, amount: u64): Coin<CoinType> acquires Balance {
        let balance = balance_of<CoinType>(addr);
        // balance must be greater than the withdraw amount
        assert!(balance >= amount, INSUFFICIENT_BALANCE);
        let balance_ref = &mut borrow_global_mut<Balance<CoinType>>(addr).coin.value;
        *balance_ref = balance - amount;
        Coin<CoinType> { value: amount }
    }

    fun deposit<CoinType>(addr: address, check: Coin<CoinType>) acquires Balance{
        let balance = balance_of<CoinType>(addr);
        let balance_ref = &mut borrow_global_mut<Balance<CoinType>>(addr).coin.value;
        let Coin<CoinType> { value } = check;
        *balance_ref = balance + value;
    }

    public fun balance_of<CoinType>(addr: address): u64 acquires Balance {
        assert!(exists<Balance<CoinType>>(addr), BALANCE_IS_NOT_EXIST);
        borrow_global<Balance<CoinType>>(addr).coin.value
    }
}