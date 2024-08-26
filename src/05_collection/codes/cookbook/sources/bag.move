module cookbook::bag {
    use sui::bag::{Self, Bag};
    use std::ascii::{Self, String};

    public struct Bookshelf has key {
        id: UID,
        items: Bag,
    }

    // 书籍
    public struct Book has key, store {
        id: UID,
        title: String, 
        description: String,
    }

    // 玩具
    public struct Toy has key, store {
        id: UID,
        name: String, 
        category: String,
    }

    // 创建书架
    public fun create_bookshelf(ctx: &mut TxContext) {
        transfer::share_object(Bookshelf {
            id: object::new(ctx),
            items: bag::new(ctx),
        });
	}

    // 销毁空书架
    public fun destroy_empty_bookshelf(bookshelf: Bookshelf) {
        let Bookshelf {id, items} = bookshelf;
        items.destroy_empty();
        id.delete()
    }

    // 放置书籍
    public fun add_book(bookshelf: &mut Bookshelf, title: vector<u8>, description: vector<u8>, ctx: &mut TxContext) {
        let book = Book {
            id: object::new(ctx),
            title: ascii::string(title),
            description: ascii::string(description)
        };

        bookshelf.items.add(book.title, book);
    }

    // 放置玩具
    public fun add_toy(bookshelf: &mut Bookshelf, name: vector<u8>, category: vector<u8>, ctx: &mut TxContext) {
        let toy = Toy {
            id: object::new(ctx),
            name: ascii::string(name),
            category: ascii::string(category)
        };

        bookshelf.items.add(toy.name, toy);
    }

    // 拿取书本
    public fun get_book(bookshelf: &Bookshelf, title: vector<u8>): &Book {
        bookshelf.items.borrow(ascii::string(title))
    }

    // 拿取玩具
    public fun get_toy(bookshelf: &Bookshelf, name: vector<u8>): &Toy{
        bookshelf.items.borrow(ascii::string(name))
    }

    // 设置书本描述
    public fun set_book_desc(bookshelf: &mut Bookshelf, title: vector<u8>, description: vector<u8>) {
        let book_mut_ref = bookshelf.items.borrow_mut<_, Book>(ascii::string(title));
        book_mut_ref.description = ascii::string(description);
    }

    // 从书架上移除书本
    public fun remove_book(bookshelf: &mut Bookshelf, title: vector<u8>): Book {
        bookshelf.items.remove(ascii::string(title))
    }

    // 从书架上移除玩具
    public fun remove_toy(bookshelf: &mut Bookshelf, name: vector<u8>): Toy{
        bookshelf.items.remove(ascii::string(name))
    }

    // 判断书本是否存在
    public fun is_book_existed(bookshelf: &Bookshelf, title: vector<u8>): bool {
        bookshelf.items.contains(ascii::string(title))
    }

    // 判断书架是否为空
    public fun is_bookshelf_empty(bookshelf: &Bookshelf): bool {
        bookshelf.items.is_empty()
    }

    public fun get_count(bookshelf: &Bookshelf): u64{
        bookshelf.items.length()
    }

    public fun get_book_title(book: &Book): String {
        book.title
    }

    public fun get_book_desc(book: &Book): String {
        book.description
    }

    public fun get_toy_name(toy: &Toy): String {
        toy.name
    }

    public fun get_toy_category(toy: &Toy): String {
        toy.category
    }
}