module cookbook::table {
    use sui::table::{Self, Table};
    use std::ascii::{Self, String};

    public struct Bookshelf has key {
        id: UID,
        books: Table<String, Book> 
    }

    public struct Book has key, store {
        id: UID,
        title: String, 
        description: String,
    }

    // 创建书架
    public fun create_bookshelf(ctx: &mut TxContext) {
        transfer::share_object(Bookshelf {
            id: object::new(ctx),
            books: table::new<String, Book>(ctx),
        });
	}

    // 销毁空书架
    public fun destroy_empty_bookshelf(bookshelf: Bookshelf) {
        let Bookshelf {id, books} = bookshelf;
        books.destroy_empty();
        id.delete()
    }

    // 添加书籍
    public fun add_book(bookshelf: &mut Bookshelf, title: vector<u8>, 
        description: vector<u8>, ctx: &mut TxContext) {
        let book = Book {
            id: object::new(ctx),
            title: ascii::string(title),
            description: ascii::string(description)
        };

        bookshelf.books.add(book.title, book);
    }

    // 拿取书本
    public fun get_book(bookshelf: &Bookshelf, title: vector<u8>): &Book {
        bookshelf.books.borrow(ascii::string(title))
    }

    // 设置书本描述
    public fun set_book_desc(bookshelf: &mut Bookshelf, title: vector<u8>, description: vector<u8>) {
        let book_mut_ref = bookshelf.books.borrow_mut(ascii::string(title));
        book_mut_ref.description = ascii::string(description);
    }

    // 从书架上移除书本
    public fun remove_book(bookshelf: &mut Bookshelf, title: vector<u8>): Book {
        bookshelf.books.remove(ascii::string(title))
    }

    // 判断书本是否存在
    public fun is_book_existed(bookshelf: &Bookshelf, title: vector<u8>): bool {
        bookshelf.books.contains(ascii::string(title))
    }

    // 判断书架是否为空
    public fun is_bookshelf_empty(bookshelf: &Bookshelf): bool {
        bookshelf.books.is_empty()
    }

    // 获取书本数量
    public fun get_book_count(bookshelf: &Bookshelf): u64{
        bookshelf.books.length()
    }

    public fun get_book_title(book: &Book): String {
        book.title
    }

    public fun get_book_desc(book: &Book): String {
        book.description
    }
}
