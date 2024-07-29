#[test_only]
module basic_coin_addr::basic_coin_test {
    use std::signer;
    use basic_coin_addr::basic_coin;

    #[test(account = @0xFA)]
    #[expected_failure(abort_code = basic_coin::ALREADY_HAS_BALANCE)]
    fun test_duplicated_account(account: signer) {
        basic_coin::init_account(&account);
        basic_coin::init_account(&account);
    }

    #[test(account = @0xFA)]
    #[expected_failure(abort_code = basic_coin::BALANCE_IS_NOT_EXIST)]
    fun test_mint_failure(account: signer) {
        let mint_amount = 10;
        // mint
        basic_coin::mint(&account, mint_amount);
    }

    #[test(account = @0xFA)]
    #[expected_failure(abort_code = basic_coin::BALANCE_IS_NOT_EXIST)]
    fun test_get_balance_failure(account: signer) {
        let addr = signer::address_of(&account);
        let mint_amount = 10;
        assert!(basic_coin::balance_of(addr) == mint_amount, 0);
    }

    #[test(account = @0x1)]
    fun test_init_account_has_zero(account: signer) {
        let addr = signer::address_of(&account);
        basic_coin::init_account(&account);
        assert!(basic_coin::balance_of(addr) == 0, 0);
    }

    #[test(account = @0xC0FFEE)]
    fun test_mint(account: signer) {
        let addr = signer::address_of(&account);
        let mint_amount = 10;

        // init account
        basic_coin::init_account(&account);

        // mint
        basic_coin::mint(&account, mint_amount);
        assert!(basic_coin::balance_of(addr) == mint_amount, 0);
        
        // mint again
        basic_coin::mint(&account, mint_amount);
        assert!(basic_coin::balance_of(addr) == mint_amount * 2, 0);
    }

    #[test(account = @0x1)]
    #[expected_failure(abort_code = basic_coin::INSUFFICIENT_BALANCE)]
    fun test_burn_too_much(account: signer) {
        basic_coin::init_account(&account);
        basic_coin::burn(&account, 1);
    }

    #[test(account = @0xCAFE)]
    fun test_can_burn_amount(account: signer) {
        basic_coin::init_account(&account);
        let amount = 1000;
        let addr = signer::address_of(&account);
        basic_coin::mint(&account, amount);
        let balance: u64 = basic_coin::balance_of(addr);
        assert!(balance == amount, 0);

        basic_coin::burn(&account, amount);
        let balance: u64 = basic_coin::balance_of(addr);
        assert!(balance == 0, 0);
    }


    #[test(account = @0x1)]
    #[expected_failure(abort_code = basic_coin::FAILED_EXECUTION)]
    fun test_transfer_to_origin(account: signer) {
        basic_coin::init_account(&account);
        let amount = 1000;
        let addr = signer::address_of(&account);
        basic_coin::mint(&account, amount);

        basic_coin::transfer(&account, addr, amount);
    }

    #[test(from = @0x1, to = @0x2)]
    #[expected_failure(abort_code = basic_coin::INSUFFICIENT_BALANCE)]
    fun test_transfer_too_much(from: signer, to: signer) {
        basic_coin::init_account(&from);
        basic_coin::init_account(&to);
        let amount = 1000;
        let to_addr = signer::address_of(&to);
        basic_coin::transfer(&from, to_addr, amount);
    }

    #[test(from = @0x1, to = @0x2)]
    fun test_transfer(from: signer, to: signer) {
        basic_coin::init_account(&from);
        basic_coin::init_account(&to);
        let amount = 1000;
        basic_coin::mint(&from, amount);

        let to_addr = signer::address_of(&to);
        basic_coin::transfer(&from, to_addr, amount);
        assert!(basic_coin::balance_of(to_addr) == amount, 0);
    }
}