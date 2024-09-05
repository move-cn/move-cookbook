module oracle::simple_weather {
    use std::string::{Self, String};
    use sui::dynamic_object_field as dof;
    use sui::package;

    /// Define a capability for the admin of the oracle.
    public struct AdminCap has key, store { id: UID }

    /// // Define a one-time witness to create the `Publisher` of the oracle.
    public struct SIMPLE_WEATHER has drop {}

    // Define a struct for the weather oracle
    public struct WeatherOracle has key {
        id: UID,
        /// The address of the oracle.
        address: address,
        /// The name of the oracle.
        name: String,
        /// The description of the oracle.
        description: String,
    }

    // Define a struct for each city that the oracle covers
    public struct CityWeatherOracle has key, store {
        id: UID,
        geoname_id: u32, // The unique identifier of the city
        name: String, // The name of the city
        country: String, // The country of the city
        pressure: u32, // The atmospheric pressure in hPa
        // ... 
    }

    /// Module initializer. Uses One Time Witness to create Publisher and transfer it to sender.
    fun init(otw: SIMPLE_WEATHER, ctx: &mut TxContext) {
        package::claim_and_keep(otw, ctx); // Claim ownership of the one-time witness and keep it

        let cap = AdminCap { id: object::new(ctx) }; // Create a new admin capability object
        transfer::share_object(WeatherOracle {
            id: object::new(ctx),
            address: tx_context::sender(ctx),
            name: string::utf8(b"SuiMeteo"),
            description: string::utf8(b"A weather oracle for posting weather updates (temperature, pressure, humidity, visibility, wind metrics and cloud state) for major cities around the world. Currently the data is fetched from https://openweathermap.org. SuiMeteo provides the best available information, but it does not guarantee its accuracy, completeness, reliability, suitability, or availability. Use it at your own risk and discretion."),
        });
        transfer::public_transfer(cap, tx_context::sender(ctx)); // Transfer the admin capability to the sender.
    }

    // Public function for adding a new city to the oracle
    public fun add_city(
        _: &AdminCap, // The admin capability
        oracle: &mut WeatherOracle, // A mutable reference to the oracle object
        geoname_id: u32, // The unique identifier of the city
        name: String, // The name of the city
        country: String, // The country of the city
        ctx: &mut TxContext // A mutable reference to the transaction context
    ) {
        dof::add(&mut oracle.id, geoname_id, // Add a new dynamic object field to the oracle object with the geoname ID as the key and a new city weather oracle object as the value.
            CityWeatherOracle {
                id: object::new(ctx), // Assign a unique ID to the city weather oracle object 
                geoname_id, // Set the geoname ID of the city weather oracle object
                name,  // Set the name of the city weather oracle object
                country,  // Set the country of the city weather oracle object
                pressure: 0, // Initialize the pressure to be zero 
            }
        );
    }

    // Public function for removing an existing city from the oracle
    public fun remove_city(_: &AdminCap, oracle: &mut WeatherOracle, geoname_id: u32) {
        let CityWeatherOracle { id, geoname_id: _, name: _, country: _, pressure: _} = dof::remove(&mut oracle.id, geoname_id);
        object::delete(id);
    }

    // Public function for updating the weather conditions of a city
    public fun update(
        _: &AdminCap,
        oracle: &mut WeatherOracle,
        geoname_id: u32,
        pressure: u32,
    ) {
        let city_weather_oracle_mut = dof::borrow_mut<u32, CityWeatherOracle>(&mut oracle.id, geoname_id); // Borrow a mutable reference to the city weather oracle object with the geoname ID as the key
        city_weather_oracle_mut.pressure = pressure;
    }

    /// Returns the `pressure` of the `CityWeatherOracle` with the given `geoname_id`.
    public fun city_weather_oracle_pressure(
        weather_oracle: &WeatherOracle, 
        geoname_id: u32
    ): u32 {
        let city_weather_oracle = dof::borrow<u32, CityWeatherOracle>(&weather_oracle.id, geoname_id);
        city_weather_oracle.pressure
    }

    // This function updates the name of a weather oracle contract.
    // It takes an admin capability, a mutable reference to the weather oracle, and a new name as arguments.
    // It assigns the new name to the weather oracle's name field.
    public fun update_name(_: &AdminCap, weather_oracle: &mut WeatherOracle, name: String) {
        weather_oracle.name = name;
    }

    // This function updates the description of a weather oracle contract.
    // It takes an admin capability, a mutable reference to the weather oracle, and a new description as arguments.
    // It assigns the new description to the weather oracle's description field.
    public fun update_description(_: &AdminCap, weather_oracle: &mut WeatherOracle, description: String) {
        weather_oracle.description = description;
    }
}