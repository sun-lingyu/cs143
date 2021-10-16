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
      {
         p: StackCommand <- head.getNext();
         while not isvoid(p) loop(p)
         {
            case p of
               intCommand: IntCommand => out_int(intCommand.GetVal());
               plusCommand: PlusCommand => out_string("+");
               swapCommand: SwapCommand => out_string("s");
            esac;
         } pool;
      }
   };
};

class Main inherits IO {

   main() : Object {
      --out_string("Nothing implemented\n")
      (*input: String <- self.in_string();
      head: StackCommand <- new StackCommand;
      while not (input = "x") loop
      {
         if input = "+" then
            head.SetNext(new PlusCommand);
         else 
            if input = "s" then
               head.SetNext(new SwapCommand);
            else 
               if input = "e" then
                  (new EvalCommand).Evaluate(head);
               else
                  if input = "d" then
                     (new DisplayCommand).Display(head);
                  else
                     intCommand: IntCommand <- new IntCommand;
                     intCommand.SetVal((new A2I).atoi(input));
                     head.SetNext(intCommand);
                  fi
               fi
            fi
         fi
         input <- self.in_string()
      } pool*)
      0
   };
};
