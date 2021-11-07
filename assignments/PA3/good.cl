class A {
    a:Int <- not isvoid while 1 loop isvoid {~1;} pool;

    ana(): Int {
        (let x:Int <- 1 in 1 + 2 * 5)+3
    };

    para(b: Bool, c:String) : SELF_TYPE{
        true
    };
};

Class BB__ inherits A {
    tmp(): Object{ 
        {
        self@A.ana();
        para(new Bool, "tmp");
        ana();
        }
    };
};

Class C {

};
