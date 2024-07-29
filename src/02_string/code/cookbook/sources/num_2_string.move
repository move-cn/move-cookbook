module cookbook::num_2_string {
    public fun u8_to_string(num: u8): vector<u8> {
        return num_to_string(num as u64)
    }

    public fun u16_to_string(num: u16): vector<u8> {
        return num_to_string(num as u64)
    }

    public fun u32_to_string(num: u32): vector<u8> {
        return num_to_string(num as u64)
    }

    public fun u64_to_string(num: u64): vector<u8> {
        return num_to_string(num)
    }

    public fun num_to_string(mut num: u64): vector<u8> {
        if (num == 0) {
            return b"0"
        };

        let mut bytes = vector::empty<u8>();
        while (num > 0) {
            let remainder = num % 10;                               // get the last digit
            num = num / 10;                                         // remove the last digit
            vector::push_back(&mut bytes, (remainder as u8) + 48);  // ASCII value of 0 is 48
        };

        vector::reverse(&mut bytes);
        return bytes
    }
}