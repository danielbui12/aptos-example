#[test_only]
module example_addr::example_test {
    use std::signer;
    use std::unit_test;
    use std::vector;
    use std::string;

    use example_addr::example;
    use aptos_framework::account;

    #[test(admin = @0x123)]
    public entry fun test_flow(admin: signer) 
    {
        let admin_addr = signer::address_of(&admin);
        account::create_account_for_test(admin_addr);
        example::create_message(&admin,string::utf8(b"This is my message"));
        example::create_message(&admin,string::utf8(b"I changed my message"));
        
        let message = example::get_message(admin_addr);
        assert!(message == string::utf8(b"I changed my message"),10);
    }


    fun get_account(): signer {
        vector::pop_back(&mut unit_test::create_signers_for_testing(1))
    }

    #[test]
    public entry fun sender_can_set_message() {
        let account = get_account();
        let addr = signer::address_of(&account);
        aptos_framework::account::create_account_for_test(addr);
        example::create_message(&account, string::utf8(b"Hello, Blockchain"));

        assert!(
          example::get_message(addr) == string::utf8(b"Hello, Blockchain"),
          0
        );
    }
}