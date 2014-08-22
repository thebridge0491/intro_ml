class person nm yr = object
    val mutable name : string = nm
    val mutable age : int = yr
    
    method get_name = name
    method get_age = age
    method set_name nm = name <- nm
    method set_age yr = age <- yr
    method to_string = Printf.sprintf "person{name:%s; age:%d}" name age
end
