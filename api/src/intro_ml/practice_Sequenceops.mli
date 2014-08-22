val index_find_i : ?ndx:(int) -> ('a -> bool) -> 'a list -> 
    (int option * 'a option)
val index_find_r : ?ndx:(int) -> ('a -> bool) -> 'a list -> 
    (int option * 'a option)
val findi_i : ('a -> bool) -> 'a list -> int option
val findi_r : ('a -> bool) -> 'a list -> int option

val rev_i : 'a list -> 'a list
val rev_r : 'a list -> 'a list
