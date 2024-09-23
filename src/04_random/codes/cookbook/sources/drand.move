module cookbook::drand{
    use sui::event;
    use cookbook::drand_lib::{derive_randomness, 
        verify_drand_signature, safe_selection};

    public struct Dice has key, store {
        id: UID,
        value: u8,
    }

    public struct DiceEvent has copy, drop {
        value: u8,
    }

    entry fun roll_dice(current_round: u64, drand_sig: vector<u8>): u8 {
        verify_drand_signature(drand_sig, current_round);

        let digest = derive_randomness(drand_sig);
        let random_index = safe_selection(6, &digest);

        (random_index as u8) + 1
    }

    entry fun roll_dice_nft(current_round: u64, drand_sig: vector<u8>, ctx: &mut TxContext) {
        let value = roll_dice(current_round, drand_sig);
        let dice = Dice {
            id: object::new(ctx),
            value,
        };

        event::emit(DiceEvent { value });

        transfer::transfer(dice, tx_context::sender(ctx));
    }
}
