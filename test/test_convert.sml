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
    in
      ()
    end
end
