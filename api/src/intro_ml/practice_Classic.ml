(*open! Practice*)

let expt_i b n =
    let rec iter prod ct = match ct with
        |   0 -> prod
        |   _ -> iter (prod *. b) (ct - 1)
in iter 1.0 @@ int_of_float n

let rec expt_r b n = match n with
    |   0.0 -> 1.0
    |   _ -> b *. (expt_r b (n -. 1.0))

let fact_i n = 
    Bolt.Logger.log "prac" Bolt.Level.DEBUG "fact_i()";
    let rec iter prod ct = match ct with
        |   0L -> prod
        |   _ -> iter (Int64.mul prod ct) (Int64.sub ct 1L)
in iter 1L n

let rec fact_r n = match n with
    |   0L -> 1L
    |   _ -> Int64.mul n (fact_r (Int64.sub n 1L))
