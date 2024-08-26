module cookbook::string_2_num {
    public fun string_to_num(bytes: vector<u8>): u64 {
        let mut num: u64 = 0;

        let len = bytes.length();
        let mut idx = 0;

        while (len - idx > 0) {

            // ASCII value of 0 is 48, ASCII value of 9 is 57
            if (bytes[idx] >= 48 && bytes[idx] <= 57) {
                num = num * 10 + ((bytes[idx] - 48) as u64);
            } else {
                break // Stop parsing when encountering a non-digit character
            };

            idx = idx + 1;
        };

        num
    }
}