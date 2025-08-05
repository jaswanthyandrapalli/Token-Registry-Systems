module jaswanth_add::sendmessage{
    public entry fun store(account: &signer, message: string) acquires Message{
        let singer_addres = signer::address_of(account);
       if (!exists<Message>(singer_addres)) {
           let message= Message {
               my_message =msg;
           };
}