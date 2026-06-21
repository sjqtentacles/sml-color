(* support.sml -- float-aware assertions and shared swatches for color tests. *)

structure Support =
struct
  structure C = Color

  val eps = 1E~6

  fun close (a, b) = Real.abs (a - b) <= eps
  fun checkClose name (exp, act) = Harness.check name (close (exp, act))
  fun checkRgb name (ex, ac) = Harness.check name (C.approxRgb eps (ex, ac))
  fun checkRgba name (ex, ac) = Harness.check name (C.approx eps (ex, ac))

  fun rgb (r,g,b) : C.rgb = { r = r, g = g, b = b }
  fun rgba (r,g,b,a) : C.rgba = { r = r, g = g, b = b, a = a }

  (* A fixed swatch table used for round-trip tests. *)
  val swatches =
    [ rgb (1.0, 0.0, 0.0)
    , rgb (0.0, 1.0, 0.0)
    , rgb (0.0, 0.0, 1.0)
    , rgb (1.0, 1.0, 0.0)
    , rgb (0.0, 1.0, 1.0)
    , rgb (1.0, 0.0, 1.0)
    , rgb (0.5, 0.5, 0.5)
    , rgb (0.2, 0.4, 0.6)
    , rgb (0.9, 0.1, 0.3)
    , rgb (1.0, 1.0, 1.0)
    , rgb (0.0, 0.0, 0.0) ]
end
