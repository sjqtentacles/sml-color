(* test_gamma.sml -- sRGB transfer functions *)

structure GammaTests =
struct
  structure C = Color
  open Support

  fun run () =
    let
      val _ = Harness.section "sRGB gamma"
      val () = checkClose "srgbToLinear 0 = 0" (0.0, C.srgbToLinear 0.0)
      val () = checkClose "srgbToLinear 1 = 1" (1.0, C.srgbToLinear 1.0)
      val () = checkClose "linearToSrgb 0 = 0" (0.0, C.linearToSrgb 0.0)
      val () = checkClose "linearToSrgb 1 = 1" (1.0, C.linearToSrgb 1.0)
      (* the linear segment near zero: srgbToLinear u = u/12.92 *)
      val () = checkClose "srgbToLinear 0.04045 = 0.0031308"
                 (0.0031308, C.srgbToLinear 0.04045)
      (* mid-gray 0.5 sRGB -> ~0.214 linear (well-known value) *)
      val () = Harness.check "srgbToLinear 0.5 ~ 0.214"
                 (Real.abs (C.srgbToLinear 0.5 - 0.21404) < 1E~4)

      val _ = Harness.section "gamma round-trip"
      val samples = [0.0, 0.01, 0.04045, 0.1, 0.25, 0.5, 0.75, 0.9, 1.0]
      val () = List.app
        (fn u => checkClose "srgb->linear->srgb"
                   (u, C.linearToSrgb (C.srgbToLinear u)))
        samples
      val () = List.app
        (fn u => checkClose "linear->srgb->linear"
                   (u, C.srgbToLinear (C.linearToSrgb u)))
        samples

      val _ = Harness.section "rgb gamma wrappers"
      val c = rgb (0.5, 0.25, 0.75)
      val () = checkRgb "rgbToSrgb (rgbToLinear c) = c"
                 (c, C.rgbToSrgb (C.rgbToLinear c))
    in
      ()
    end
end
