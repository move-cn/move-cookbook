module cookbook::weather_oracle {
    use sui::event;
    use simple_weather_oracle::simple_weather::{WeatherOracle};

    public struct Dice has key, store {
        id: UID,
        value: u32,
    }

    public struct DiceEvent has copy, drop {
        value: u32,
    }

    entry fun roll_dice(weather_oracle: &WeatherOracle, geoname_id: u32): u32 {
        let random_pressure_sz = 
            simple_weather_oracle::simple_weather::city_weather_oracle_pressure(weather_oracle, geoname_id);

        let result = random_pressure_sz % 6 + 1;
        result
    }

    entry fun roll_dice_nft(weather_oracle: &WeatherOracle, geoname_id: u32, ctx: &mut TxContext) {
        let value = roll_dice(weather_oracle, geoname_id);
        let dice = Dice {
            id: object::new(ctx),
            value,
        };

        event::emit(DiceEvent { value });

        transfer::transfer(dice, tx_context::sender(ctx));
    }
}
