(** Example test cases
*)

open OUnit

let set_up_class _ = Printf.printf "SetUpClass ...\n"
let tear_down_class _ = Printf.printf "... TearDownClass\n"

let set_up _ = Printf.printf "SetUp ...\n"
let tear_down _ = Printf.printf "... TearDown\n"

let test_method _ = assert_equal (2 * 2) 4
(* let test_dblMethod _ = assert_equal ~cmp:(cmp_float ~epsilon:0.0001) 4.0 4.0 *)
let test_dblMethod _ = assert_equal ~cmp:(Util.in_epsilon ~tolerance:0.0001) 4.0 4.0
let test_strMethod _ = assert_equal "Hello" "Hello"
let test_badMethod _ = assert_bool "Bad" (4 > 5)
let test_failMethod _ = assert_failure "Fail"
let test_ignoredMethod _ = skip_if true "Ignored"
let test_todoMethod _ = todo "ToDo"
let test_exceptionMethod _ = assert_raises Division_by_zero (fun _ -> 1 / 0)


(** Suite of test cases
*)
let tcases = "Tc_new" >::: (List.map (fun (f, nm) -> 
        (nm >:: (bracket set_up f tear_down)))
    [(test_method, "test_method"); (test_dblMethod, "test_dblMethod")
    ; (test_strMethod, "test_strMethod"); (test_badMethod, "test_badMethod")
    ; (test_failMethod, "test_failMethod")
    ; (test_ignoredMethod, "test_ignoredMethod")
    ; (test_todoMethod, "test_todoMethod")
    ; (test_exceptionMethod, "test_exceptionMethod")   
    ])
