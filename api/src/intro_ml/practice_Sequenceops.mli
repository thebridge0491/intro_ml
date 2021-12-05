val tabulate_i : (int -> 'a) -> int -> 'a list
val tabulate_r : (int -> 'a) -> int -> 'a list

val length_i : 'a list -> int
val length_r : 'a list -> int

val nth_i : int -> 'a list -> 'a option
val nth_r : int -> 'a list -> 'a option

val index_find_i : ?ndx:(int) -> ('a -> bool) -> 'a list -> 
    (int option * 'a option)
val index_find_r : ?ndx:(int) -> ('a -> bool) -> 'a list -> 
    (int option * 'a option)
val findi_i : ('a -> bool) -> 'a list -> int option
val findi_r : ('a -> bool) -> 'a list -> int option
val find_i : ('a -> bool) -> 'a list -> 'a option
val find_r : ('a -> bool) -> 'a list -> 'a option

val min_i : 'a list -> 'a
val min_r : 'a list -> 'a
val max_i : 'a list -> 'a
val max_r : 'a list -> 'a

val rev_i : 'a list -> 'a list
val rev_r : 'a list -> 'a list
val copy_i : 'a list -> 'a list
val copy_r : 'a list -> 'a list

val splitn_i : int -> 'a list -> ('a list * 'a list)
val take_i : int -> 'a list -> 'a list
val drop_i : int -> 'a list -> 'a list

val exists_i : ('a -> bool) -> 'a list -> bool
val exists_r : ('a -> bool) -> 'a list -> bool
val for_all_i : ('a -> bool) -> 'a list -> bool
val for_all_r : ('a -> bool) -> 'a list -> bool

val map_i : ('a -> 'b) -> 'a list -> 'b list
val map_r : ('a -> 'b) -> 'a list -> 'b list
val iter_i : ('a -> unit) -> 'a list -> unit
val iter_r : ('a -> unit) -> 'a list -> unit

val partition_i : ('a -> bool) -> 'a list -> ('a list * 'a list)
val partition_r : ('a -> bool) -> 'a list -> ('a list * 'a list)
val filter_i : ('a -> bool) -> 'a list -> 'a list
val filter_r : ('a -> bool) -> 'a list -> 'a list
val remove_i : ('a -> bool) -> 'a list -> 'a list
val remove_r : ('a -> bool) -> 'a list -> 'a list

val fold_left_i : ('a -> 'b -> 'a) -> 'a -> 'b list -> 'a
val fold_left_r : ('a -> 'b -> 'a) -> 'a -> 'b list -> 'a
val fold_right_i : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b
val fold_right_r : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b

val unfold_right_i : ('a -> ('b * 'a) option) -> 'a -> 'b list
val unfold_left_r : ('a -> ('b * 'a) option) -> 'a -> 'b list

val is_ordered_i : ?cmpfn:('a -> 'a -> bool) -> ('b -> 'a) -> 'b list -> bool
val is_ordered_r : ?cmpfn:('a -> 'a -> bool) -> ('b -> 'a) -> 'b list -> bool

val append_i : 'a list -> 'a list -> 'a list
val append_r : 'a list -> 'a list -> 'a list
val interleave_i    : 'a list -> 'a list -> 'a list
val interleave_r    : 'a list -> 'a list -> 'a list

val map2_i : ('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list
val map2_r : ('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list
val zip_i : 'a list -> 'b list -> ('a * 'b) list
val zip_r : 'a list -> 'b list -> ('a * 'b) list
val unzip2_i : ('a * 'b) list -> 'a list * 'b list
val concat_i : 'a list list -> 'a list
val concat_r : 'a list list -> 'a list


val tabulate_f : (int -> 'a) -> int -> 'a list

val length_f : 'a list -> int
val nth_f : int -> 'a list -> 'a option

val index_find_f : ?ndx:(int) -> ('a -> bool) -> 'a list -> 
    (int option * 'a option)
val findi_f : ('a -> bool) -> 'a list -> int option
val find_f : ('a -> bool) -> 'a list -> 'a option

val min_f : 'a list -> 'a
val max_f : 'a list -> 'a

val rev_f : 'a list -> 'a list
val copy_f : 'a list -> 'a list

val splitn_f : int -> 'a list -> ('a list * 'a list)
val take_f : int -> 'a list -> 'a list
val drop_f : int -> 'a list -> 'a list

val exists_f : ('a -> bool) -> 'a list -> bool
val for_all_f : ('a -> bool) -> 'a list -> bool

val map_f : ('a -> 'b) -> 'a list -> 'b list
val iter_f : ('a -> unit) -> 'a list -> unit

val partition_f : ('a -> bool) -> 'a list -> ('a list * 'a list)
val filter_f : ('a -> bool) -> 'a list -> 'a list
val remove_f : ('a -> bool) -> 'a list -> 'a list

val is_ordered_f : ?cmpfn:('a -> 'a -> bool) -> ('b -> 'a) -> 'b list -> bool

val append_f : 'a list -> 'a list -> 'a list
val interleave_f    : 'a list -> 'a list -> 'a list

val map2_f : ('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list
val zip_f : 'a list -> 'b list -> ('a * 'b) list

val unzip2_f : ('a * 'b) list -> 'a list * 'b list
val concat_f : 'a list list -> 'a list


val tabulate_u : (int -> 'a) -> int -> 'a list

val length_u : 'a list -> int
val nth_u : int -> 'a list -> 'a option

val index_find_u : ?ndx:(int) -> ('a -> bool) -> 'a list -> 
    (int option * 'a option)
val findi_u : ('a -> bool) -> 'a list -> int option
val find_u : ('a -> bool) -> 'a list -> 'a option

val min_u : 'a list -> 'a
val max_u : 'a list -> 'a

val rev_u : 'a list -> 'a list
val copy_u : 'a list -> 'a list

val splitn_u : int -> 'a list -> ('a list * 'a list)
val take_u : int -> 'a list -> 'a list
val drop_u : int -> 'a list -> 'a list

val exists_u : ('a -> bool) -> 'a list -> bool
val for_all_u : ('a -> bool) -> 'a list -> bool

val map_u : ('a -> 'b) -> 'a list -> 'b list
val iter_u : ('a -> unit) -> 'a list -> unit

val partition_u : ('a -> bool) -> 'a list -> ('a list * 'a list)
val filter_u : ('a -> bool) -> 'a list -> 'a list
val remove_u : ('a -> bool) -> 'a list -> 'a list

val is_ordered_u : ?cmpfn:('a -> 'a -> bool) -> ('b -> 'a) -> 'b list -> bool

val append_u : 'a list -> 'a list -> 'a list
val interleave_u    : 'a list -> 'a list -> 'a list

val map2_u : ('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list
val zip_u : 'a list -> 'b list -> ('a * 'b) list

val unzip2_u : ('a * 'b) list -> 'a list * 'b list
val concat_u : 'a list list -> 'a list
