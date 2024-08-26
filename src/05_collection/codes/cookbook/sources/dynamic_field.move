module cookbook::dynamic_field{
    use std::ascii::{Self, String};
    use sui::dynamic_field;

    public struct Bookshelf has key {
        id: UID,
        book_count: u64
    }

    public struct Book has store {
        title: String, 
        description: String,
    }

    // 创建书架共享对象
    public fun create_bookshelf(ctx: &mut TxContext) {
        transfer::share_object(Bookshelf {
            id: object::new(ctx),
            book_count: 0,
        });
	}

    // 放置书本到书架
    public fun add_book(bookshelf: &mut Bookshelf, title: vector<u8>, description: vector<u8>) {
        let book = Book {
            title: ascii::string(title),
            description: ascii::string(description)
        };

        dynamic_field::add<vector<u8>, Book>(&mut bookshelf.id,title, book); 
        bookshelf.book_count = bookshelf.book_count + 1;
    }

    public fun add_book_obj(bookshelf: &mut Bookshelf, book: Book) {
        dynamic_field::add<vector<u8>, Book>(&mut bookshelf.id,
            book.title.into_bytes(), book); 
        bookshelf.book_count = bookshelf.book_count + 1;
    }

    // 拿取书本
    public fun get_book(bookshelf: &Bookshelf, title: vector<u8>): &Book {
        dynamic_field::borrow(&bookshelf.id, title)
    }

    // 设置书本的描述信息
    public fun set_book_desc(bookshelf: &mut Bookshelf, title: vector<u8>, description: vector<u8>) {
        let book_mut_ref: &mut Book = dynamic_field::borrow_mut(&mut bookshelf.id, title);
        book_mut_ref.description = ascii::string(description);
    }

    // 判断书本是否存在
    public fun is_book_existed(bookshelf: &Bookshelf, title: vector<u8>): bool {
        dynamic_field::exists_(&bookshelf.id, title)
    }

    public fun is_book_exists_with_type(bookshelf: &Bookshelf, title: vector<u8>): bool {
        dynamic_field::exists_with_type<vector<u8>, Book>(&bookshelf.id, title)
    }

    // 从书架上移除书本
    public fun remove_book(bookshelf: &mut Bookshelf, title: vector<u8>): Book {
        bookshelf.book_count = bookshelf.book_count - 1;
        dynamic_field::remove<vector<u8>, Book>(&mut bookshelf.id, title)
    }

    // 如果存在指定标题书本，则从书架上移除书本
    public fun remove_if_book_exists(bookshelf: &mut Bookshelf, title: vector<u8>): Option<Book> {
        bookshelf.book_count = bookshelf.book_count - 1;
        dynamic_field::remove_if_exists<vector<u8>, Book>(&mut bookshelf.id, title)
    }

    public fun get_book_count(bookshelf: &Bookshelf): u64{
        bookshelf.book_count
    }

    public fun get_book_title(book: &Book): String {
        book.title
    }

    public fun get_book_desc(book: &Book): String {
        book.description
    }
}
