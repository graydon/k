require "modules/unification.k"
require "modules/substitution.k"

module LAMBDA
  imports UNIFICATION
  imports SUBSTITUTION

  syntax Exp ::= Int | Bool | Id
               | "(" Exp ")"                      [bracket]
               | Exp Exp                          [strict, left]
               > Exp "*" Exp                      [strict, left]
               | Exp "/" Exp                      [strict]
               > Exp "+" Exp                      [strict, left]
               > Exp "<=" Exp                     [strict]
               > "lambda" Id "." Exp
               | "if" Exp "then" Exp "else" Exp   [strict]
               | "let" Id "=" Exp "in" Exp        [strict(2)]
               | "letrec" Id Id "=" Exp "in" Exp
               | "mu" Id "." Exp

  syntax Type ::= "int" | "bool"
                | Type "->" Type
                | "(" Type ")"                    [bracket]

  syntax Exp ::= Type
  syntax KResult ::= Type

  configuration <k color="green"> $PGM:Exp </k>
                <tenv color="red"> .Map </tenv>
                <mgu color="blue"> .Mgu </mgu>

  rule I:Int => int
  rule B:Bool => bool
  rule <k> X:Id => T ...</k>  <tenv>... X |-> T:Type ...</tenv>
  rule T1:Type  * T2:Type => T1 = int ~> T2 = int ~> int
  rule T1:Type  / T2:Type => T1 = int ~> T2 = int ~> int
  rule T1:Type  + T2:Type => T1 = int ~> T2 = int ~> int
  rule T1:Type <= T2:Type => T1 = int ~> T2 = int ~> bool
  syntax Exp ::= Exp "->" Exp  [strict]
  rule <k> lambda X:Id . E:Exp => T -> E ~> tenv(TEnv) ...</k>
       <tenv> TEnv => TEnv[T/X] </tenv>  when fresh(T:Type)
  rule T1:Type T2:Type => T1 = (T2 -> T) ~> T  when fresh(T:Type)
  rule if T:Type then T1:Type else T2:Type => T = bool ~> T1 = T2 ~> T1

  syntax TypeSchema ::= "(" "forall" Set ")" Type  [binder]
  rule <k> let X = T:Type in E => E ~> tenv(TEnv) ...</k>
       <mgu> Theta:Mgu </mgu>
       <tenv> TEnv
        => TEnv[(forall freeVariables(applyMgu(Theta, T)) -Set
                        freeVariables(applyMgu(Theta, values TEnv))
                ) applyMgu(Theta, T) / X]
       </tenv>
  rule <k> X:Id => freshVariables(Tvs,T) ...</k>
       <tenv>... X |-> (forall Tvs) T ...</tenv>

  rule letrec F X = E in E' => let F = mu F . lambda X . E in E'        [macro]
  rule <k> mu X:Id . E:Exp => (T -> T) E ~> tenv(TEnv) ...</k>
       <tenv> TEnv => TEnv[T/X] </tenv>  when fresh(T:Type)

  syntax K ::= Type "=" Type
  rule <k> T = T' => . ...</k>  <mgu> Theta:Mgu => updateMgu(Theta,T,T') </mgu>
  rule <k> T:Type => applyMgu(Theta,T) </k>  <mgu> Theta:Mgu => . </mgu>

  syntax K ::= tenv(Map)
  rule <k> T:Type ~> (tenv(TEnv) => .) ...</k>  <tenv> _ => TEnv </tenv>
endmodule
