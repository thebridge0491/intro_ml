(* multi-line comment
    -- run w/out compile --
    BOLT_CONFIG=bolt.conf [sh | [ocaml | utop] -I `ocamlfind query bolt`] main.sh arg1 argN

    -- run REPL, load script, & run --
    BOLT_CONFIG=bolt.conf [ocaml | utop] -I `ocamlfind query bolt` -init main.sh
    # Main.main ([|Sys.argv.(2); arg1; argN|])
    
    -- help/info tools in REPL --
    #list, #quit, #show, #trace, #untrace[_all]
    
    -- show module version 4.01  (version 4.02 and above)
    module Malias = List ;;       (#show List ;;)      -- for modules
    module Falias = Set.Make ;;   (#show Set.Make ;;)  -- for functors
*)

open Printf
open Practice

module Opts_record = struct
    type t = {user:string; num:int; isExpt2:bool}
end

module User = struct
    type t = {mutable name:string; mutable num:int; mutable time_in:float}
end

let run_intro (rsrc_path, opts_rec) =
    let time_in = Unix.gettimeofday() in
    let greet_path = rsrc_path ^ "/greet.txt" in
    let (ch, delay_secs, dt1) = (ref '\000', 2.5, Unix.localtime time_in) in
    let user1 = ({User.name = opts_rec.Opts_record.user; 
		num = opts_rec.Opts_record.num; time_in = time_in} : User.t) in
    let person1 = new Person.person "I. M. Computer" 32 in
    let (rexp, lst) = (Str.regexp_case_fold "^quit$", [2; 1; 0; 4; 3]) in
    let _ = Random.init (int_of_float time_in) in
    let (num_val, num_arr) = (ref 0, [|0b1011; 0o13; 0xb; 11|]) in
    begin
        num_val := Array.fold_right (+) num_arr 0
        ; assert ((!num_val) = (Array.length num_arr) * (Array.get num_arr 0))
        
        (* ; (fun () -> Unix.sleep (int_of_float delay_secs))*)
        ; ch := Intro.delay_char_r (fun () -> ignore (Unix.select [] [] []
            delay_secs); 0)
        
        ; user1.User.num <- (if (0 = user1.User.num) then
            (Random.int 18) + 2 else user1.User.num)
        
        ; printf "%s %s to %s\n" 
            (if (Str.string_match rexp user1.User.name 0) then
                "Good match: "
            else "Does not match: ") opts_rec.Opts_record.user "\"^quit$\""
        ; print_endline (Util.dateToString dt1)
        (* ; print_endline (Intro.greeting greet_path user1.User.name)*)
        (* ; fprintf stdout "%s\n" (Intro.greeting greet_path
            user1.User.name)*)
        ; printf "%s\n" (Intro.greeting greet_path user1.User.name)
        ; printf "(program %s) Took %.2f seconds.\n" Sys.argv.(0)
            ((Unix.gettimeofday()) -. user1.User.time_in)
        ; print_endline (String.make 40 '#')
        
        ; if opts_rec.Opts_record.isExpt2 then
            (printf "Classic.expt_i 2 %d: %s\n" user1.User.num
                (string_of_float (Classic.expt_i 2.0 @@ float_of_int user1.User.num))
            ; printf "Sequenceops.rev_i %s: %s\n" 
                (Util.mkString string_of_int lst)
                (Util.mkString string_of_int (Sequenceops.rev_i lst))
            ; printf "List.sort <lambda> %s %s: %s\n" 
                (Util.mkString string_of_int [9;9;9;9]) 
                (Util.mkString string_of_int lst) 
                (Util.mkString string_of_int @@
                List.sort compare @@ [9;9;9;9] @ lst)
            )
            else
                (printf "Classic.fact_i %d: %Ld\n" user1.User.num @@
                    Classic.fact_i (Int64.of_int user1.User.num)
                ; printf "Sequenceops.findi_i <lambda> %s: %s\n" 
                    (Util.mkString string_of_int lst)
                    (match (Util.option_get (-1) @@ 
                        Sequenceops.findi_i (fun e -> e = 3) lst) with
                    |   (-1) -> "None"
                    |   idx -> sprintf "Some(%d)" idx)
                ; printf "List.@ %s %s: %s\n" 
                    (Util.mkString string_of_int [9;9;9;9]) 
                    (Util.mkString string_of_int lst) @@ 
                    (Util.mkString string_of_int @@ [9;9;9;9] @ lst)
                )
        
        ; print_endline (String.make 40 '#')
        ; printf "person1#get_age: %d\n" person1#get_age
        ; person1#set_age 33
        ; printf "person1#set_age 33: \n"
        ; printf "person1#to_string: %s\n" person1#to_string
        ; print_endline (String.make 40 '#')
    end

let usage_msg = sprintf "Usage: %s [-help][-u USER][-n NUM][-2]" 
    Sys.argv.(0)
let (user, num, isExpt2) = (ref "World", ref 0, ref false)

let speclist = [
    ("-u", Arg.Set_string user, ": User name")
    ; ("-n", Arg.Set_int num, ": Number n")
    ; ("-2", Arg.Set isExpt2, ": Expt 2 n (vice default Fact n)")
    ]

let parse_cmdopts args =
    Bolt.Logger.log "root" Bolt.Level.INFO "parse_cmdopts()"
    ; try
    begin
        Arg.parse_argv args speclist (fun x -> raise (Arg.Bad ("Bad argument: " 
            ^ x))) usage_msg
        ; {Opts_record.user = !user; num = !num; isExpt2 = !isExpt2}
    end
    with Arg.Help msg -> (printf "%s" msg ; exit 1)
        | Arg.Bad msg -> (printf "%s" msg ; exit 1)

let main argv = 
    let rsrc_path = try Sys.getenv "RSRC_PATH"
    with exc -> "resources" in
    let (ini_path, json_path) = (rsrc_path ^ "/prac.conf",
        rsrc_path ^ "/prac.json") in
    let opts_rec = parse_cmdopts argv in
    let ini_cfg = new Inifiles.inifile ini_path in
    let jsonobj = Yojson.Safe.from_file json_path in
    let user1Lst = Yojson.Safe.Util.member "user1" jsonobj in
    let jsonobj1 = Ezjsonm.from_channel (open_in json_path) in
    let user1Lst1 = Ezjsonm.find jsonobj1 ["user1"] in
    let tup_lst = [(Util.inicfg_tostring ini_cfg
        , ini_cfg#getval "default" "domain"
        , ini_cfg#getval "user1" "name")
        (* ; (Yojson.Safe.pretty_to_string jsonobj
        , Yojson.Safe.to_string @@ Yojson.Safe.Util.member "domain" jsonobj
        , Yojson.Safe.to_string @@ Yojson.Safe.Util.member "name" user1Lst) *)
        (* ; (Ezjsonm.to_string jsonobj1
        , Ezjsonm.get_string @@ Ezjsonm.find jsonobj1 ["domain"]
        , Ezjsonm.get_string @@ Ezjsonm.find user1Lst1 ["name"]) *)
        ] in
    List.iter (fun (t0, t1, t2) -> 
        printf "config: {\%s}\n" t0
        ; printf "domain: %s\n" t1
        ; printf "user1Name: %s\n\n" t2 ; ()) tup_lst
    ; run_intro (rsrc_path, opts_rec)

(*
let () =
let (program, re) = (Sys.argv.(0), Str.regexp "main") in
    try let _ = Str.search_forward re program 0 in
        main (Sys.argv)
    with Not_found -> ()
*)
let () = 
    if !Sys.interactive then () else main (Sys.argv) ;
