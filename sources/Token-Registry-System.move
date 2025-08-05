module jas_addr::TokenRegistry {
    use aptos_framework::signer;
    use std::string::String;
    use aptos_framework::timestamp;
    use std::vector;

    /// Error codes
    const E_TOKEN_ALREADY_REGISTERED: u64 = 1;
    const E_TOKEN_NOT_FOUND: u64 = 2;
    const E_NOT_AUTHORIZED: u64 = 3;

    /// Struct representing a registered token contract
    struct TokenInfo has store, key {
        name: String,           // Token name
        symbol: String,         // Token symbol
        contract_address: address, // Token contract address
        owner: address,         // Token owner/creator
        is_verified: bool,      // Verification status
        registration_time: u64, // When the token was registered
    }

    /// Registry to store all registered tokens
    struct TokenRegistry has key {
        tokens: vector<address>, // List of registered token addresses
        admin: address,          // Registry admin
    }

    /// Function to initialize the token registry (called once by admin)
    public fun initialize_registry(admin: &signer) {
        let registry = TokenRegistry {
            tokens: vector::empty<address>(),
            admin: signer::address_of(admin),
        };
        move_to(admin, registry);
    }

    /// Function to register a new token contract
    public fun register_token(
        owner: &signer,
        registry_admin: &signer,
        name: String,
        symbol: String,
        contract_address: address
    ) acquires TokenRegistry {
        let owner_addr = signer::address_of(owner);
        let admin_addr = signer::address_of(registry_admin);
        
        // Check if token is already registered
        assert!(!exists<TokenInfo>(contract_address), E_TOKEN_ALREADY_REGISTERED);
        
        // Create token info
        let token_info = TokenInfo {
            name,
            symbol,
            contract_address,
            owner: owner_addr,
            is_verified: false,
            registration_time: timestamp::now_microseconds(),
        };
        
        // Store token info at the contract address
        move_to(owner, token_info);
        
        // Add to registry if it exists
        if (exists<TokenRegistry>(admin_addr)) {
            let registry = borrow_global_mut<TokenRegistry>(admin_addr);
            vector::push_back(&mut registry.tokens, contract_address);
        };
    }
}