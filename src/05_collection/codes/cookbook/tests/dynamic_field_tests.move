#[test_only]
module cookbook::dynamic_field_tests {
    use std::ascii;
    use sui::test_scenario as ts;
    use cookbook::dynamic_field::{Bookshelf, create_bookshelf, add_book, get_book, 
        set_book_desc, is_book_existed, is_book_exists_with_type, remove_book,
        get_book_count, get_book_title, get_book_desc};

    #[test_only]
    use sui::test_utils::assert_eq;

    #[test]
    public fun test_dynamic_field() {
        let alice = @0xa;    

        let mut ts = ts::begin(alice);

        // 创建书架
        {
            create_bookshelf(ts.ctx());
        };

        // 放置书本到书架
        let expected_title = b"Mastering Bitcoin";
        let expected_description= b"1st Edition";
        let expected_new_description= b"3rd Edition";

        {
            ts.next_tx(alice);
            let mut bookshelf: Bookshelf = ts.take_shared();

            add_book(
                &mut bookshelf, 
                expected_title, 
                expected_description,
            );

            assert_eq(bookshelf.get_book_count(), 1);

            ts::return_shared(bookshelf);
        };

        // 拿取书本
        {
            ts.next_tx(alice);
            let bookshelf: Bookshelf = ts.take_shared();

            let book = get_book(
                &bookshelf, 
                expected_title, 
            );

            assert_eq(book.get_book_title(), ascii::string(expected_title));
            assert_eq(book.get_book_desc(), ascii::string(expected_description));

            ts::return_shared(bookshelf);
        };

        // 设置书本的描述信息
        {
            ts.next_tx(alice);
            let mut bookshelf: Bookshelf = ts.take_shared();

            set_book_desc(
                &mut bookshelf, 
                expected_title, 
                expected_new_description,
            );

            let book = get_book(
                &bookshelf, 
                expected_title, 
            );

            assert_eq(book.get_book_title(), ascii::string(expected_title));
            assert_eq(book.get_book_desc(), ascii::string(expected_new_description));

            ts::return_shared(bookshelf);
        };

        // 判断书本是否存在
        {
            ts.next_tx(alice);
            let bookshelf: Bookshelf = ts.take_shared();

            let is_existed = is_book_existed(
                &bookshelf, 
                expected_title, 
            );
            assert_eq(is_existed, true);

            let is_existed = is_book_exists_with_type(
                &bookshelf, 
                expected_title, 
            );
            assert_eq(is_existed, true);

            ts::return_shared(bookshelf);
        };

        // 从书架上移除书本
        {
            ts.next_tx(alice);
            let mut bookshelf: Bookshelf = ts.take_shared();

            assert_eq(bookshelf.get_book_count(), 1);

            let book = remove_book(
                &mut bookshelf, 
                expected_title, 
            );

            assert_eq(bookshelf.get_book_count(), 0);
            assert_eq(book.get_book_title(), ascii::string(expected_title));
            assert_eq(book.get_book_desc(), ascii::string(expected_new_description));

            bookshelf.add_book_obj(book);

            ts::return_shared(bookshelf);
        };

        ts.end();
    }
}
