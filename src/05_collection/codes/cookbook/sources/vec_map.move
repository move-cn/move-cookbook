module cookbook::vec_map{
    use std::ascii::{Self, String};
    use sui::vec_map;

    public struct Bookshelf has key {
        id: UID,
        book_count: u64
    }

    public struct Book has store {
        title: String, 
        description: String,
    }
}