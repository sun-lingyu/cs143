
(*
 *  execute "coolc bad.cl" to see the error messages that the coolc parser
 *  generates
 *
 *  execute "myparser bad.cl" to see the error messages that your parser
 *  generates
 *)

(* no error *)
class A {
    a;(*error in feature*)

    method():Int {
        let a:Int <- 1+3**,b:int,_c:Int,d:Int in 1 (*error in let*)
    };

    method1():Int {
        {
            a<-;(*error in {}*)
            1+1;
            1++;(*should report error near '+'*)
        }
    }
};

(* error:  b is not a type identifier *)
Class b inherits A {
};

(* error:  a is not a type identifier *)
Class C inherits a {
};

(* error:  keyword inherits is misspelled *)
Class D inherts A {
};

(* error:  closing brace is missing *)
Class E inherits A {
;

