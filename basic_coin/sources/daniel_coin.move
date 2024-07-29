module basic_coin_addr::daniel_coin {
    use basic_coin_addr::standard_coin;

    struct DanielCoin has drop {}

    public fun setup_and_mint(account: &signer, amount: u64) {
        standard_coin::init_account<DanielCoin>(account);
        standard_coin::mint<DanielCoin>(account, amount, DanielCoin {});
    }


    public fun transfer(from: &signer, to: address, amount: u64) {
        standard_coin::transfer<DanielCoin>(from, to, amount, DanielCoin {});
    }


    /*
        Unit tests
    */
    #[test(from = @0x42, to = @0x10)]
    fun test_mint_success(from: signer, to: signer) {
        setup_and_mint(&from, 42);
        setup_and_mint(&to, 10);

        // transfer an odd number of coins so this should succeed.
        transfer(&from, @0x10, 7);

        assert!(standard_coin::balance_of<DanielCoin>(@0x42) == 35, 0);
        assert!(standard_coin::balance_of<DanielCoin>(@0x10) == 17, 0);
    }
}