
val option_get  : 'a -> 'a option -> 'a

val dateToString : Unix.tm -> string
val inicfg_tostring : Inifiles.inifile -> string
val mkString_init : (string * string * string) -> ('a -> string) -> 'a list ->
    string
val mkString : ('a -> string) -> 'a list -> string
val mkString_nested : (string * string * string) -> ('a -> string) -> 
    'a list list -> string

val range_cnt : ?start:int -> int -> int list

val queue_ofList : 'a list -> 'a Queue.t
val queue_toList : 'a Queue.t -> 'a list

val in_epsilon : ?tolerance:float -> float -> float -> bool
val cartesian_prod : 'a list -> 'b list -> ('a * 'b) list

module IntOrd : sig
    type t = int
    val compare : 'a -> 'a -> int
end

module CharOrd : sig
    type t = char
    val compare : 'a -> 'a -> int
end

module StringOrd : sig
    type t = string
    val compare : 'a -> 'a -> int
end

module FloatOrd : sig
    type t = float
    val compare : 'a -> 'a -> int
end

module IntHash : sig
    type t = int
    val equal : 'a -> 'a -> bool
    val hash : 'a -> int
end

module CharHash : sig
    type t = char
    val equal : 'a -> 'a -> bool
    val hash : 'a -> int
end

module StringHash : sig
    type t = string
    val equal : 'a -> 'a -> bool
    val hash : 'a -> int
end

module FloatHash : sig
    type t = float
    val equal : 'a -> 'a -> bool
    val hash : 'a -> int
end

val lib_main : string array -> unit
