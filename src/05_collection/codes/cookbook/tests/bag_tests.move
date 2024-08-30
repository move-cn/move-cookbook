#[test_only]
module cookbook::bag_tests {
    use std::ascii;
    use sui::test_scenario as ts;
    use cookbook::bag::{Bookshelf, create_bookshelf, destroy_empty_bookshelf, 
        add_book, add_toy, get_book, get_toy, set_book_desc, is_book_existed, 
        remove_book, is_bookshelf_empty, get_count, get_book_title, get_book_desc,
        remove_toy, get_toy_name, get_toy_category};

    #[test_only]
    use sui::test_utils::assert_eq;

    #[test]
    public fun test_bag() {
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
                ts.ctx(),
            );

            assert_eq(bookshelf.get_count(), 1);
            assert_eq(bookshelf.is_bookshelf_empty(), false);

            ts::return_shared(bookshelf);
        };

        // 放置玩具到书架
        let expected_name= b"Lego set";
        let expected_category= b"Building Blocks";

        {
            ts.next_tx(alice);
            let mut bookshelf: Bookshelf = ts.take_shared();

            add_toy(
                &mut bookshelf, 
                expected_name, 
                expected_category,
                ts.ctx(),
            );

            assert_eq(bookshelf.get_count(), 2);

            ts::return_shared(bookshelf);
        };

        // 拿取书本和玩具
        {
            ts.next_tx(alice);
            let bookshelf: Bookshelf = ts.take_shared();

            {
                let book = get_book(
                    &bookshelf, 
                    expected_title, 
                );
                assert_eq(book.get_book_title(), ascii::string(expected_title));
                assert_eq(book.get_book_desc(), ascii::string(expected_description));
            };

            {
                let toy = get_toy(
                    &bookshelf, 
                    expected_name, 
                );
                assert_eq(toy.get_toy_name(), ascii::string(expected_name));
                assert_eq(toy.get_toy_category(), ascii::string(expected_category));
            };

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

            ts::return_shared(bookshelf);
        };

        // 从书架上拿走书本和玩具
        {
            ts.next_tx(alice);
            let mut bookshelf: Bookshelf = ts.take_shared();

            {
                assert_eq(bookshelf.get_count(), 2);
                let book = remove_book(
                    &mut bookshelf, 
                    expected_title, 
                );
                assert_eq(bookshelf.get_count(), 1);
                assert_eq(book.get_book_title(), ascii::string(expected_title));
                assert_eq(book.get_book_desc(), ascii::string(expected_new_description));
                transfer::public_transfer(book, alice);
            };

            {
                assert_eq(bookshelf.get_count(), 1);
                let toy = remove_toy(
                    &mut bookshelf, 
                    expected_name, 
                );
                assert_eq(bookshelf.get_count(), 0);
                assert_eq(toy.get_toy_name(), ascii::string(expected_name));
                assert_eq(toy.get_toy_category(), ascii::string(expected_category));
                transfer::public_transfer(toy, alice);
            };

            ts::return_shared(bookshelf);
        };

        // 销毁书架
        {
            ts.next_tx(alice);
            let bookshelf: Bookshelf = ts.take_shared();
            destroy_empty_bookshelf(bookshelf);
        };

        ts.end();
    }
}