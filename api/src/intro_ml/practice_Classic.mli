val square_i  : float -> float
val square_r  : float -> float
val expt_i  : float -> float -> float
val expt_r  : float -> float -> float
val fast_expt_i : float -> float -> float
val fast_expt_r : float -> float -> float

val sum_to_i    : int64 -> int64 -> int64
val sum_to_r    : int64 -> int64 -> int64
val fact_i  : int64 -> int64
val fact_r  : int64 -> int64

val fib_i   : int -> int
val fib_r   : int -> int

val pascaltri_add   : int -> int list list
val pascaltri_mult  : int -> int list list

val quot_m  : int -> int -> int
val rem_m  : int -> int -> int
val div_m  : float -> float -> float
val mod_m  : float -> float -> float

val gcd_i   : int list -> int
val gcd_r   : int list -> int
val lcm_i   : int list -> int
val lcm_r   : int list -> int

val base_expand_i   : int -> int -> int list
val base_expand_r   : int -> int -> int list

val base_to10_i : int -> int list -> int
val base_to10_r : int -> int list -> int

val range_step_i  : ?step:(int) -> ?start:(int) -> int -> int list
val range_step_r  : ?step:(int) -> ?start:(int) -> int -> int list
val range_i : int -> int -> int list
val range_r : int -> int -> int list

val compose1    : ('a -> 'b) -> ('c -> 'a) -> ('c -> 'b)


val square_f  : float -> float
val expt_f  : float -> float -> float

val sum_to_f    : int64 -> int64 -> int64
val fact_f  : int64 -> int64

val fib_f   : int -> int
val pascaltri_f   : int -> int list list

val gcd_f   : int list -> int
val lcm_f   : int list -> int

val base_expand_f : int -> int -> int list
val base_to10_f : int -> int list -> int

val range_step_f  : ?step:(int) -> ?start:(int) -> int -> int list
val range_f : int -> int -> int list


val square_u  : float -> float
val expt_u  : float -> float -> float

val sum_to_u    : int64 -> int64 -> int64
val fact_u  : int64 -> int64

val fib_u   : int -> int
val pascaltri_u   : int -> int list list

val gcd_u   : int list -> int
val lcm_u   : int list -> int

val base_expand_u : int -> int -> int list
val base_to10_u : int -> int list -> int

val range_step_u  : ?step:(int) -> ?start:(int) -> int -> int list
val range_u : int -> int -> int list


val hanoi   : (int * int * int) -> int -> (int * int) list
val hanoi_moves : (int * int * int) -> int -> ((int * int) list * string list
    * (string * int list list) list)

val nqueens : int -> (int * int) list list
val nqueens_grid : int -> (int * int) list -> string list list


val squares_strm : unit -> float Stream.t
val expts_strm : float -> float Stream.t

val sums_strm : int64 -> int64 Stream.t
val facts_strm : unit -> int64 Stream.t

val fibs_strm : unit -> int Stream.t

val pascalrows_strm : unit -> int list Stream.t


val squares_u : unit -> float BatLazyList.t
val expts_u : float -> float BatLazyList.t

val sums_u : int64 -> int64 BatLazyList.t
val facts_u : unit -> int64 BatLazyList.t

val fibs_u : unit -> int BatLazyList.t

val pascalrows_u : unit -> int list BatLazyList.t
