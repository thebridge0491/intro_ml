(*open! Practice*)

let index_find_i ?(ndx = 0) pred xss =
    let rec iter idx rst = match rst with
        | [] -> (None, None)
        | x::xs -> match pred x with
            | true -> (Some idx, Some x)
            | _ -> iter (idx + 1) xs
in iter ndx xss

let rec index_find_r ?(ndx = 0) pred xss = match xss with
    | [] -> (None, None)
    | x::xs -> match pred x with
        | true -> (Some ndx, Some x)
        | _ -> index_find_r ~ndx:(ndx + 1) pred xs

let findi_i pred xss = fst @@ index_find_i pred xss
let findi_r pred xss = fst @@ index_find_r pred xss

let rev_i xss = 
    Bolt.Logger.log "prac" Bolt.Level.DEBUG "rev_i()";
    let rec iter rst acc = match rst with
        |   [] -> acc
        |   x::xs -> iter xs (x:: acc)
in iter xss []

let rec rev_r xss = match xss with
    |   [] -> []
    |   x::xs -> (rev_r xs) @ [x]
