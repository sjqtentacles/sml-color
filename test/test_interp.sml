(* test_interp.sml -- lerp / mix and clamping *)

structure InterpTests =
struct
  structure C = Color
  open Support

  fun run () =
    let
      val _ = Harness.section "lerp / mix"
      val a = rgba (0.0, 0.0, 0.0, 0.0)
      val b = rgba (1.0, 1.0, 1.0, 1.0)
      val () = checkRgba "lerp t=0 = a" (a, C.lerp (a, b, 0.0))
      val () = checkRgba "lerp t=1 = b" (b, C.lerp (a, b, 1.0))
      val () = checkRgba "lerp t=0.5 = midpoint"
                 (rgba (0.5,0.5,0.5,0.5), C.lerp (a, b, 0.5))
      val () = checkRgba "mix t=0 = a" (a, C.mix (a, b, 0.0))
      val () = checkRgba "mix t=1 = b" (b, C.mix (a, b, 1.0))
      val () = checkRgba "mix t=0.25"
                 (rgba (0.25,0.25,0.25,0.25), C.mix (a, b, 0.25))

      val _ = Harness.section "mix clamps t, lerp does not"
      (* mix clamps t<0 to 0 -> a; t>1 to 1 -> b *)
      val () = checkRgba "mix t<0 clamps to a" (a, C.mix (a, b, ~0.5))
      val () = checkRgba "mix t>1 clamps to b" (b, C.mix (a, b, 1.5))
      (* lerp extrapolates *)
      val () = checkRgba "lerp t=2 extrapolates"
                 (rgba (2.0,2.0,2.0,2.0), C.lerp (a, b, 2.0))

      val _ = Harness.section "channel clamp helpers"
      val () = checkRgb "clampRgb clamps out-of-range"
                 (rgb (1.0, 0.0, 0.5), C.clampRgb (rgb (1.5, ~0.2, 0.5)))
      val () = checkRgba "clampRgba clamps alpha"
                 (rgba (0.0,1.0,0.5,1.0), C.clampRgba (rgba (~1.0,2.0,0.5,3.0)))
    in
      ()
    end
end
