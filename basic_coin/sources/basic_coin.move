module basic_coin_addr::basic_coin {
    use std::signer;

    const ALREADY_HAS_BALANCE:u64 = 1;
    const BALANCE_IS_NOT_EXIST:u64 = 2;
    const INSUFFICIENT_BALANCE:u64 = 3;
    const FAILED_EXECUTION:u64 = 4;

    struct Coin has store {
        value: u64
    }

    struct Balance has key {
        coin: Coin
    }

    public entry fun init_account(account: &signer) {
        assert!(!exists<Balance>(signer::address_of(account)), ALREADY_HAS_BALANCE);
        let empty_coin = Coin { value: 0 };
        move_to(account, Balance { coin: empty_coin });
    }

    public fun mint(account: &signer, value: u64) acquires Balance {
        assert!(exists<Balance>(signer::address_of(account)), BALANCE_IS_NOT_EXIST);
        let addr = signer::address_of(account);
        deposit(addr, Coin { value })
    }

    public fun transfer(from: &signer, to: address, amount: u64) acquires Balance {
        let from_addr = signer::address_of(from);
        assert!(exists<Balance>(from_addr), BALANCE_IS_NOT_EXIST);
        assert!(exists<Balance>(to), BALANCE_IS_NOT_EXIST);
        assert!(from_addr != to, FAILED_EXECUTION);
        let balance = balance_of(from_addr);
        assert!(balance >= amount, INSUFFICIENT_BALANCE);
        let checked_amount = withdraw(from_addr, amount);
        deposit(to, checked_amount);
    }

    public fun burn(account: &signer, amount: u64) acquires Balance {
        let addr = signer::address_of(account);
        assert!(exists<Balance>(addr), BALANCE_IS_NOT_EXIST);
        let balance = balance_of(addr);
        assert!(balance >= amount, INSUFFICIENT_BALANCE);
        let Coin { value } = withdraw(addr, amount);
        assert!(value == amount, FAILED_EXECUTION);
    }

    fun withdraw(addr: address, amount: u64): Coin acquires Balance {
        let balance = balance_of(addr);
        // balance must be greater than the withdraw amount
        assert!(balance >= amount, INSUFFICIENT_BALANCE);
        let balance_ref = &mut borrow_global_mut<Balance>(addr).coin.value;
        *balance_ref = balance - amount;
        Coin { value: amount }
    }

    fun deposit(addr: address, check: Coin) acquires Balance{
        let balance = balance_of(addr);
        let balance_ref = &mut borrow_global_mut<Balance>(addr).coin.value;
        let Coin { value } = check;
        *balance_ref = balance + value;
    }

    public fun balance_of(addr: address): u64 acquires Balance {
        assert!(exists<Balance>(addr), BALANCE_IS_NOT_EXIST);
        borrow_global<Balance>(addr).coin.value
    }
}