module cookbook::num_2_string_test {
    use cookbook::num_2_string::{u8_to_string, u16_to_string, u32_to_string, u64_to_string};

    #[test_only]
    use sui::test_utils::assert_eq;

    #[test]
    fun test_num_2_string() {
        let num: u8 = 255;
        let output = u8_to_string(num);
        assert_eq(output.to_ascii_string(), b"255".to_ascii_string());

        let num: u16 = 12345;
        let output = u16_to_string(num);
        assert_eq(output.to_ascii_string(), b"12345".to_ascii_string());

        let num: u32 = 123456789;
        let output = u32_to_string(num);
        assert_eq(output.to_ascii_string(), b"123456789".to_ascii_string());

        let num: u64 = 123456789123456789;
        let output = u64_to_string(num);
        assert_eq(output.to_ascii_string(), b"123456789123456789".to_ascii_string());
    }
}