module cookbook::vec_map_and_vec_set{
use std::ascii::{Self, String};
use sui::vec_map::{Self, VecMap};
use sui::vec_set::{Self, VecSet};

public struct Bookshelf has key {
    id: UID,
    books: VecMap<String, Book>,  
    book_names: VecSet<String>,
}

public struct Book has key, store {
    id: UID,
    title: String, 
    description: String,
}

// 创建书架共享对象
public fun create_bookshelf(ctx: &mut TxContext) {
    transfer::share_object(Bookshelf {
        id: object::new(ctx),
        books: vec_map::empty(),
        book_names: vec_set::empty(),
    });
}

// 销毁空书架
public fun destroy_empty_bookshelf(bookshelf: Bookshelf) {
    let Bookshelf {id, books, book_names:_} = bookshelf;
    books.destroy_empty();
    id.delete()
}

// 放置书本到书架
public fun add_book(bookshelf: &mut Bookshelf, title: vector<u8>, 
    description: vector<u8>, ctx: &mut TxContext) {

    let book = Book {
        id: object::new(ctx),
        title: ascii::string(title),
        description: ascii::string(description)
    };

    bookshelf.books.insert(ascii::string(title), book);
    bookshelf.book_names.insert(ascii::string(title));
}

// 拿取书本
public fun get_book(bookshelf: &Bookshelf, title: &String): &Book {
    bookshelf.books.get(title)
}

// 取出最后一本放到书架上的书
public fun get_last_book(bookshelf: &mut Bookshelf): Book {
    let (_, book) = bookshelf.books.pop();
    book
}

// 设置书本的描述信息
public fun set_book_desc(bookshelf: &mut Bookshelf, title: vector<u8>, description: vector<u8>) {
    let book_mut_ref: &mut Book = bookshelf.books.get_mut(&ascii::string(title));
    book_mut_ref.description = ascii::string(description);
}

// 判断书本是否存在
public fun is_book_existed(bookshelf: &Bookshelf, title: vector<u8>): bool {
    // bookshelf.book_names.contains(&ascii::string(title))
    bookshelf.books.contains(&ascii::string(title))
}


// 判断书架是否为空
public fun is_bookshelf_empty(bookshelf: &Bookshelf): bool {
    // bookshelf.book_names.is_empty()
    bookshelf.books.is_empty()
}

// 从书架上移除书本
public fun remove_book(bookshelf: &mut Bookshelf, title: vector<u8>): Book {
    bookshelf.book_names.remove(&ascii::string(title));

    let (_, book) = bookshelf.books.remove(&ascii::string(title));
    book
}

public fun get_book_count(bookshelf: &Bookshelf): u64{
    // bookshelf.book_names.size()
    bookshelf.books.size()
}

public fun get_book_title(book: &Book): String {
    book.title
}

public fun get_book_desc(book: &Book): String {
    book.description
}
}