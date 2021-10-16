(*
 *  CS164 Fall 94
 *
 *  Programming Assignment 1
 *    Implementation of a simple stack machine.
 *
 *  Skeleton file
 *)

--linked list
class StackCommand inherits Object {
   next : StackCommand;
   eval(): StackCommand {self};
   getNext(): StackCommand {next};
   setNext(newNext: StackCommand): StackCommand{next <- newNext};
};

class IntCommand inherits StackCommand {
   val: Int;
   getVal(): Int {val};
   setVal(newVal: Int): Int {val <- newVal};
};

class PlusCommand inherits StackCommand {
   eval(): StackCommand{
      let intRes: IntCommand <- (new IntCommand) in{
         case getNext() of 
            int1 : IntCommand =>
               case int1.getNext() of 
                  int2 : IntCommand =>{
                     intRes.setVal(int1.getVal() + int2.getVal());
                     intRes.setNext(int2.getNext());   
                  };
               esac;
         esac;
         intRes;
      }
   };
};

class SwapCommand inherits StackCommand {
   eval(): StackCommand{
      let next1: StackCommand <- getNext(), next2: StackCommand <- next1.getNext() in{
         setNext(next2);
         next1.setNext(next2.getNext());
         next2.setNext(next1);
         next2;
      }
   };
};

class EvalCommand inherits Object{
   evaluate(head: StackCommand): Object{
      head.setNext(head.getNext().eval())
   };
};

class DisplayCommand inherits IO{
   display(head: StackCommand): Object{
      let p: StackCommand <- head.getNext() in{
         while (not isvoid(p)) loop
         {
            case p of
               intCommand: IntCommand => out_int(intCommand.getVal());
               plusCommand: PlusCommand => out_string("+");
               swapCommand: SwapCommand => out_string("s");
            esac;
         } pool;
      }
   };
};

class Main inherits IO {
   out_string("<")
   input: String <- in_string();
   head: StackCommand <- new StackCommand;

   main() : Object {
      while (not (input = "x")) loop
      {
         if (input = "+") then
            head.setNext(new PlusCommand)
         else 
            if (input = "s") then
               head.setNext(new SwapCommand)
            else 
               if (input = "e") then
                  (new EvalCommand).evaluate(head)
               else
                  if (input = "d") then
                     (new DisplayCommand).display(head)
                  else
                     let intCommand: IntCommand <- new IntCommand in{
                        intCommand.setVal((new A2I).a2i(input));
                        head.setNext(intCommand);
                     } 
                  fi
               fi
            fi
         fi;
         input <- in_string();
      }
      pool
   };
};
