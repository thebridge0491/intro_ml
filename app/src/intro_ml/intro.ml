open Printf

let greeting greet_path name = 
    Bolt.Logger.log "prac" Bolt.Level.DEBUG "greeting()";
    let istream = open_in greet_path in
    try let res = input_line istream in
        (* res ^ name ^ "!" *)
        (*String.concat "" [res; name; "!"]*)
        sprintf "%s%s!" res name
    with exc ->
        close_in_noerr istream;
        Printexc.to_string exc
        (*raise exc*)

let rec delay_char_r delay_func =
    begin
        let _ = delay_func () in
        print_string "Type any character when ready.";
        flush stdout;
        let line = read_line () in
            if ("" = line || '\n' = String.get line 0) then
                delay_char_r delay_func
            else
                String.get line 0
    end


let lib_main argv =
    ignore @@ delay_char_r (fun () -> ignore (Unix.select [] [] [] 3.0); 0)


let () =
let (program, re) = (Sys.argv.(0), Str.regexp "lib_main") in
    try let _ = Str.search_forward re program 0 in
        lib_main (Sys.argv)
    with Not_found -> ()
(*
let () =
    if !Sys.interactive then () else lib_main (Sys.argv) ;
*)
