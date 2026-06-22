(* test_convert.sml -- HSV/HSL conversions and round-trips *)

structure ConvertTests =
struct
  structure C = Color
  open Support

  fun run () =
    let
      val _ = Harness.section "rgbToHsv anchors"
      val redHsv = C.rgbToHsv (rgb (1.0, 0.0, 0.0))
      val () = checkClose "red hue = 0" (0.0, #h redHsv)
      val () = checkClose "red sat = 1" (1.0, #s redHsv)
      val () = checkClose "red val = 1" (1.0, #v redHsv)
      val greenHsv = C.rgbToHsv (rgb (0.0, 1.0, 0.0))
      val () = checkClose "green hue = 120" (120.0, #h greenHsv)
      val blueHsv = C.rgbToHsv (rgb (0.0, 0.0, 1.0))
      val () = checkClose "blue hue = 240" (240.0, #h blueHsv)
      val grayHsv = C.rgbToHsv (rgb (0.5, 0.5, 0.5))
      val () = checkClose "gray sat = 0" (0.0, #s grayHsv)
      val () = checkClose "gray hue = 0 (canonical)" (0.0, #h grayHsv)

      val _ = Harness.section "hsvToRgb anchors"
      val () = checkRgb "HSV(0,1,1) = red"
                 (rgb (1.0,0.0,0.0), C.hsvToRgb {h=0.0, s=1.0, v=1.0})
      val () = checkRgb "HSV(120,1,1) = green"
                 (rgb (0.0,1.0,0.0), C.hsvToRgb {h=120.0, s=1.0, v=1.0})
      val () = checkRgb "HSV(240,1,1) = blue"
                 (rgb (0.0,0.0,1.0), C.hsvToRgb {h=240.0, s=1.0, v=1.0})

      val _ = Harness.section "HSV round-trip over swatches"
      val () = List.app
        (fn c => checkRgb "rgb->hsv->rgb" (c, C.hsvToRgb (C.rgbToHsv c)))
        swatches

      val _ = Harness.section "rgbToHsl anchors"
      val redHsl = C.rgbToHsl (rgb (1.0, 0.0, 0.0))
      val () = checkClose "red hsl hue = 0" (0.0, #h redHsl)
      val () = checkClose "red hsl sat = 1" (1.0, #s redHsl)
      val () = checkClose "red hsl lum = 0.5" (0.5, #l redHsl)
      val grayHsl = C.rgbToHsl (rgb (0.5, 0.5, 0.5))
      val () = checkClose "gray hsl sat = 0" (0.0, #s grayHsl)
      val () = checkClose "gray hsl lum = 0.5" (0.5, #l grayHsl)
      val () = checkRgb "HSL(0,1,0.5) = red"
                 (rgb (1.0,0.0,0.0), C.hslToRgb {h=0.0, s=1.0, l=0.5})

      val _ = Harness.section "HSL round-trip over swatches"
      val () = List.app
        (fn c => checkRgb "rgb->hsl->rgb" (c, C.hslToRgb (C.rgbToHsl c)))
        swatches

      val _ = Harness.section "hue wraparound"
      (* hue 360 and 0 produce identical rgb *)
      val () = checkRgb "HSV hue 360 = hue 0"
                 (C.hsvToRgb {h=0.0, s=1.0, v=1.0},
                  C.hsvToRgb {h=360.0, s=1.0, v=1.0})
      (* negative hue wraps *)
      val () = checkRgb "HSV hue -120 = hue 240"
                 (C.hsvToRgb {h=240.0, s=1.0, v=1.0},
                  C.hsvToRgb {h= ~120.0, s=1.0, v=1.0})

      val _ = Harness.section "CIELAB reference vectors (D65)"
      (* Published sRGB->Lab values; ~1e-2 tolerance for sRGB rounding. *)
      val labEps = 1E~2
      fun nearLab name ((el, ea, eb), lab : C.lab) =
        Harness.check name
          (Real.abs (el - #l lab) <= labEps
           andalso Real.abs (ea - #a lab) <= labEps
           andalso Real.abs (eb - #b lab) <= labEps)
      val () = nearLab "black -> (0,0,0)"
                 ((0.0, 0.0, 0.0), C.toLab (rgb (0.0, 0.0, 0.0)))
      val () = nearLab "white -> (100,0,0)"
                 ((100.0, 0.0, 0.0), C.toLab (rgb (1.0, 1.0, 1.0)))
      val () = nearLab "red -> (53.24,80.09,67.20)"
                 ((53.24, 80.09, 67.20), C.toLab (rgb (1.0, 0.0, 0.0)))
      val () = nearLab "green -> (87.74,-86.18,83.18)"
                 ((87.74, ~86.18, 83.18), C.toLab (rgb (0.0, 1.0, 0.0)))
      val () = nearLab "blue -> (32.30,79.19,-107.86)"
                 ((32.30, 79.19, ~107.86), C.toLab (rgb (0.0, 0.0, 1.0)))

      val _ = Harness.section "deltaE (CIE76 / CIEDE2000)"
      val () = Harness.check "deltaE76 black/white ~ 100"
                 (Real.abs (C.deltaE (rgb (0.0,0.0,0.0), rgb (1.0,1.0,1.0))
                            - 100.0) <= 1E~2)
      val () = checkClose "deltaE red/red = 0"
                 (0.0, C.deltaE (rgb (1.0,0.0,0.0), rgb (1.0,0.0,0.0)))
      val () = checkClose "deltaE76 lab/itself = 0"
                 (0.0, C.deltaE76 (C.toLab (rgb (0.2,0.4,0.6)),
                                   C.toLab (rgb (0.2,0.4,0.6))))
      (* Sharma et al. CIEDE2000 reference pair (expected dE00 = 2.0425). *)
      val sharma1 = { l = 50.0, a = 2.6772, b = ~79.7751 } : C.lab
      val sharma2 = { l = 50.0, a = 0.0,    b = ~82.7485 } : C.lab
      val () = Harness.check "CIEDE2000 Sharma pair ~ 2.0425"
                 (Real.abs (C.deltaE2000 (sharma1, sharma2) - 2.0425) <= 1E~3)
      val () = Harness.check "CIEDE2000 self = 0"
                 (Real.abs (C.deltaE2000 (sharma1, sharma1)) <= 1E~9)

      val _ = Harness.section "Lab / LCh round-trips over swatches"
      val () = List.app
        (fn c => Harness.check "rgb->lab->rgb"
                   (C.approxRgb 1E~4 (c, C.fromLab (C.toLab c))))
        swatches
      val () = List.app
        (fn c => Harness.check "rgb->lch->rgb"
                   (C.approxRgb 1E~4 (c, C.fromLch (C.toLch c))))
        swatches
    in
      ()
    end
end
