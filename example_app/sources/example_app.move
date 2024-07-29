module example_addr::example
{
    use std::string::{String};
    use std::signer;
    
    struct Message has key
    {
        my_message : String
    }

    #[view]
    public fun get_message(account: address): String acquires Message {
        borrow_global<Message>(account).my_message
    }

    public entry fun  create_message(account: &signer, msg: String)  acquires Message {
        let signer_address = signer::address_of(account);
        
        if(!exists<Message>(signer_address))
        {
            let message = Message {
                my_message : msg
            };
            move_to(account,message);
        }
        else
        {
            let message = borrow_global_mut<Message>(signer_address);
            message.my_message = msg;
        }
    }
}