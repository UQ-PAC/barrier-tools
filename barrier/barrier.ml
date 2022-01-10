open Core_kernel
open Bap_core_theory
open Bap.Std
open Bap_primus.Std
open Monads
open Bap_knowledge.Knowledge
open KB.Syntax
include Self()

module Lambda = Primus.Lisp
module Sigma = Lambda.Semantics

let remove_leading_colon s =
  String.strip ~drop:(Char.(=) ':') s

let barrier_option_map = [
    "1111", "sy";
    "1110", "st";
    "1101", "ld";
    "1011", "ish";
    "1010", "ishst";
    "1001", "ishld";
    "0111", "nsh";
    "0110", "nshst";
    "0101", "nshld";
    "0011", "osh";
    "0010", "oshst";
    "0001", "oshld"
  ] 
  |> Core_kernel.List.map ~f:(fun (bin, name) -> int_of_string ("0b" ^ bin), name)
  |> Map.of_alist_exn (module Int)

let option_as_string n =
  match Map.find barrier_option_map n with
  | Some option -> option
  | None -> "blank"

let provide_barrier_primitive () =
  let types = Lambda.Type.Spec.(tuple [sym; int] @-> any) in
  let docs = "(barrier) produces a barrier effect" in
  Sigma.declare ~types ~package:"aarch64" ~docs "barrier"
    ~body:(fun target ->
        let+ (module CT) = Theory.(instance>=>require) () in
        let package = KB.Name.unqualified@@Theory.Target.name target in

        let make_barrier barrier_type option =
          let* type_str = barrier_type.?[Sigma.symbol] >>| remove_leading_colon in
          let* option_int = option.?[Sigma.static] >>| Bitvec.to_int in
          let function_name = 
            Printf.sprintf "__arm_barrier_%s_%s" type_str (option_as_string option_int) in
          let* dst = Theory.Label.for_name ~package function_name in
          CT.blk Theory.Label.null
            (CT.perform Theory.Effect.Sort.barr)
            (CT.goto dst) in

        fun _lbl args ->
          match args with
          | [barrier_type; option] -> make_barrier barrier_type option
          | _ -> Sigma.failp "expected two arguments"
        )

let () = 
  let open Bap.Std in
  Config.when_ready @@ fun _ ->
    provide_barrier_primitive () 
