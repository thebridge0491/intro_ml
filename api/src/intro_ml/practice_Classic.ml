(*open! Practice*)

let expt_i b n =
    let rec iter prod ct = match ct with
        |   0 -> prod
        |   _ -> iter (prod *. b) (ct - 1)
in iter 1.0 @@ int_of_float n

let rec expt_r b n = match n with
    |   0.0 -> 1.0
    |   _ -> b *. (expt_r b (n -. 1.0))

let square_i n = expt_i n 2.0 (*n * n (* truncate (n ** 2.0) *)*)
let square_r n = expt_r n 2.0 

let fast_expt_i b n =
    let rec iter prod ct = match (ct = 0, 0 = (ct mod 2)) with
        | (true, _) -> prod
        | (_, true) -> iter (prod *. (square_i b)) (ct - 2)
        | (_, _) -> iter (prod *. b) (ct - 1)
in iter 1.0 @@ int_of_float n

let rec fast_expt_r b n = match (n = 0.0, 0. = (mod_float n 2.0)) with
    | (true, _) -> 1.0
    | (_, true) -> square_r (fast_expt_r b (n /. 2.0))
    | (_, _) -> b *. (fast_expt_r b (n -. 1.0))

let numseq_math_i ?(init = 0L) op hi lo = 
    let rec iter start acc = match start < lo with
        | true -> acc
        | _ -> iter (Int64.sub start 1L) (op acc start)
in iter hi init

let rec numseq_math_r ?(init = 0L) op hi lo = match hi < lo with
    | true -> init
    | _ -> op hi (numseq_math_r ~init:init op (Int64.sub hi 1L) lo)

let sum_to_i hi lo = numseq_math_i Int64.add hi lo
let sum_to_r hi lo = numseq_math_r Int64.add hi lo

let fact_i n = 
    Bolt.Logger.log "prac" Bolt.Level.DEBUG "fact_i()";
    numseq_math_i ~init:1L Int64.mul n 1L
let fact_r n = numseq_math_r ~init:1L Int64.mul n 1L

let fib_i n =
    let rec iter sum1 sum0 ct = match ct with
        |   0 -> sum0
        |   _ -> iter (sum1 + sum0) sum1 (ct - 1)
in iter 1 0 n

let rec fib_r n = match (n = 0 || n = 1) with
    |   true -> n
    |   _ -> (fib_r (n - 1)) + (fib_r (n - 2))

let pascaltri_add rows =
    let next_row lst = List.map2 (fun a b -> a + b) (0::lst) (lst @ [0]) in
    let rec triangle lst rows = match rows with
        |   0 -> []
        |   _ -> lst :: (triangle (next_row lst) (rows - 1))
in triangle [1] (rows + 1)

let pascaltri_mult rows =
    let range_a ?(start=0) cnt = 
        Array.to_list @@ Array.init (cnt + 1) (fun e -> e + start) in
    let pascalrow r =
        let rec iter col lst = match (r = col, lst) with
            |   (true, _) -> lst
            |   (_, []) -> raise (Failure "empty list")
            |   (_, x::_) -> iter (col + 1) ((x * (r - col) / col) :: lst)
    in iter 1 [1]
in List.map pascalrow (range_a rows ~start:1)


let quot_rem a b = 
    let q = (a / b) in
    (q, a - (q * b))

let quot_m a b = match (quot_rem a b) with q, _ -> q

let rem_m a b = match (quot_rem a b) with _, r -> r

let div_mod a b =
    let q = (a /. b) in
    (q, a -. float(truncate q) *. b)

let div_m a b = match (div_mod a b) with d, _ -> d

let mod_m a b = match (div_mod a b) with _, m -> m

let euclid_i m n =
    let rec iter a b  = match b with
        |   0 -> a
        |   _ -> iter b (a mod b)
in iter m n

let rec euclid_r m n = match n with
    |   0 -> m
    |   _ -> euclid_r n (m mod n)

let gcd_i lst = match lst with
    |   [] -> 1
    |   x::xs -> 
        let rec iter acc rst = match rst with
            |   [] -> acc
            |   m::ns -> iter (euclid_i acc m) ns
    in iter x xs

let rec gcd_r lst = match lst with
    |   [] -> 1
    |   m::[] -> m
    |   (m::n::rst) -> gcd_r ((euclid_r m n) :: rst)

let lcm_i lst = match lst with
    |   [] -> 1
    |   x::xs ->
        let rec iter acc rst = match rst with
            |   [] -> acc
            |   m::ns -> iter ((acc * m) / (euclid_i acc m)) ns
    in iter x xs

let rec lcm_r lst = match lst with
    |   [] -> 1
    |   m::[] -> m
    |   (m::n::rst) -> lcm_r (((m * n) / (euclid_r m n)) :: rst)

let base_expand_i b n =
    let rec iter q lst = match q with
        |   0 -> lst
        |   _ -> iter (q / b) ((q mod b) :: lst)
in iter n []

let rec base_expand_r b n = match n with
    |   0 -> []
    |   _ -> (base_expand_r b (n / b)) @ [n mod b]

let base_to10_i b lst =
    let rec iter xs sum ct = match xs with
        |   [] -> sum
        |   n::ns -> iter ns (sum + (n * (truncate
                ((float b) ** (float ct))))) (ct + 1)
in iter (List.rev lst) 0 0

let rec base_to10_r b lst = match lst with
    |   [] -> 0
    |   (n::ns) -> (base_to10_r b ns) + (n * (truncate ((float b) ** 
            (float (List.length ns)))))

let range_step_i ?(step = 1) ?(start = 0) stop =
    let cmp_op = if step > 0 then (>) else (<) in
    let rec iter cur acc = match cmp_op cur stop with
        | true -> acc
        | _ -> iter (cur + step) (cur :: acc)
in List.rev (iter start [])

let rec range_step_r ?(step = 1) ?(start = 0) stop =
    let cmp_op = (if step > 0 then (>) else (<)) in
    match cmp_op start stop with
        | true -> []
        | _ -> start :: (range_step_r ~step:step ~start:(start + step) stop)

let range_i start stop = range_step_i ~start:start stop
let range_r start stop = range_step_r ~start:start stop

let compose1 f g = (fun x -> f (g x))


include Practice_Classic_Puzzles
include Practice_Classic_Hiorder
include Practice_Classic_Streams
