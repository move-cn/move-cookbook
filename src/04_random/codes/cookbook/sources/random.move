module cookbook::random{
    use sui::random::{Self, Random, new_generator};
    use sui::event;

    public struct Dice has key, store {
        id: UID,
        value: u8,
    }

    public struct DiceEvent has copy, drop {
        value: u8,
    }

    entry fun roll_dice(r: &Random, ctx: &mut TxContext): u8 {
        let mut generator = new_generator(r, ctx); 
        let result = random::generate_u8_in_range(&mut generator, 1, 6);
        result
    }

    entry fun roll_dice_nft(r: &Random, ctx: &mut TxContext) {
        let value = roll_dice(r, ctx);
        let dice = Dice {
            id: object::new(ctx),
            value,
        };

        event::emit(DiceEvent { value });

        transfer::transfer(dice, tx_context::sender(ctx));
    }
}
