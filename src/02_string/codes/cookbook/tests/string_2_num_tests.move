module cookbook::string_2_num_test {
    use cookbook::string_2_num::{string_to_num};

    #[test_only]
    use sui::test_utils::assert_eq;

    #[test]
    fun test_string_2_num() {
        let bytes = b"123456789";
        let num = string_to_num(bytes);
        assert_eq(num, 123456789);

        let bytes = b"123456789123456789";
        let num = string_to_num(bytes);
        assert_eq(num, 123456789123456789);

        let bytes = b"123456789ABCD";
        let num = string_to_num(bytes);
        assert_eq(num, 123456789);
    }
}