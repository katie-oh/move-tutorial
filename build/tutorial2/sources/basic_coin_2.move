module 0x58329c32bd6265543d9b525f5756f244e885983073a84c072597765acf56c4d9::basic_coin_2 {
    use std::signer;

    /// Error codes
    const ENOT_MODULE_OWNER: u64 = 0;
    const EINSUFFICIENT_BALANCE: u64 = 1;
    const EALREADY_HAS_BALANCE: u64 = 2;

    struct Coin<phantom CoinType> has store {
        value: u64,
    }

    struct Balance<phantom CoinType> has key {
        coin: Coin<CoinType>
    }

    public fun publish_balance<CoinType>(account: &signer) {
        let empty_coin = Coin<CoinType> { value: 0 };
        assert!(!exists<Balance<CoinType>>(signer::address_of(account)), EALREADY_HAS_BALANCE);
        move_to(account, Balance<CoinType> { coin:  empty_coin });
    }

    public fun mint<CoinType: drop>(mint_address: address, amount: u64, _witness: CoinType) acquires Balance {
        deposit(mint_address, Coin<CoinType> { value: amount });
    }

    public fun balance_of<CoinType>(addr: address): u64 acquires Balance {
        borrow_global<Balance<CoinType>>(addr).coin.value
    }

    public fun transfer<CoinType: drop>(from: &signer, to:address, amount: u64, _witness: CoinType) acquires Balance {
        let check = withdraw<CoinType>(signer::address_of(from), amount);
        deposit<CoinType>(to, check);
    }

    fun withdraw<CoinType>(addr: address, amount: u64): Coin<CoinType> acquires Balance {
        let balance = balance_of<CoinType>(addr);

        assert!(balance >= amount, EINSUFFICIENT_BALANCE);

        let balance_ref = &mut borrow_global_mut<Balance<CoinType>>(addr).coin.value;
        *balance_ref = balance - amount;
        Coin {value: amount}
    }

    fun deposit<CoinType>(_addr: address, check: Coin<CoinType>) acquires Balance {
        let balance = balance_of<CoinType>(_addr);
        let Coin { value: _amount } = check;

        let balance_ref = &mut borrow_global_mut<Balance<CoinType>>(_addr).coin.value;
        *balance_ref = balance + _amount;
    }
}