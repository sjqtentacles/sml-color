(* test_pack.sml -- Word32 packing and hex parse/print *)

structure PackTests =
struct
  structure C = Color
  open Support

  fun run () =
    let
      val _ = Harness.section "pack/unpack"
      val () = Harness.check "pack opaque red = 0xFF0000FF"
                 (C.pack (rgba (1.0,0.0,0.0,1.0)) = 0wxFF0000FF)
      val () = Harness.check "pack opaque green = 0x00FF00FF"
                 (C.pack (rgba (0.0,1.0,0.0,1.0)) = 0wx00FF00FF)
      val () = Harness.check "pack opaque blue = 0x0000FFFF"
                 (C.pack (rgba (0.0,0.0,1.0,1.0)) = 0wx0000FFFF)
      val () = Harness.check "pack transparent black = 0x00000000"
                 (C.pack (rgba (0.0,0.0,0.0,0.0)) = 0wx00000000)
      val () = Harness.check "pack white opaque = 0xFFFFFFFF"
                 (C.pack (rgba (1.0,1.0,1.0,1.0)) = 0wxFFFFFFFF)
      val () = checkRgba "unpack 0xFF0000FF = red"
                 (rgba (1.0,0.0,0.0,1.0), C.unpack 0wxFF0000FF)
      (* round-trip on a set of packed words *)
      val () = List.app
        (fn w => Harness.check "pack (unpack w) = w" (C.pack (C.unpack w) = w))
        [0wx00000000, 0wxFFFFFFFF, 0wx12345678, 0wxDEADBEEF, 0wx80402010]

      val _ = Harness.section "channel order (RRGGBBAA)"
      (* r in top byte: 0x80000000 -> r ~ 128/255 *)
      val redOnly = C.unpack 0wx80000000
      val () = checkClose "top byte is red" (128.0/255.0, #r redOnly)
      val () = checkClose "red-only: green 0" (0.0, #g redOnly)
      val () = checkClose "red-only: alpha 0" (0.0, #a redOnly)

      val _ = Harness.section "hex parse"
      val () = checkRgba "#ff0000 = opaque red"
                 (rgba (1.0,0.0,0.0,1.0), valOf (C.fromHex "#ff0000"))
      val () = checkRgba "ff0000 (no hash) = opaque red"
                 (rgba (1.0,0.0,0.0,1.0), valOf (C.fromHex "ff0000"))
      val () = checkRgba "#FF0000 (uppercase) = opaque red"
                 (rgba (1.0,0.0,0.0,1.0), valOf (C.fromHex "#FF0000"))
      val () = checkRgba "#ff0000ff = opaque red"
                 (rgba (1.0,0.0,0.0,1.0), valOf (C.fromHex "#ff0000ff"))
      (* 3-digit shorthand: #f00 = #ff0000 *)
      val () = checkRgba "#f00 = opaque red"
                 (rgba (1.0,0.0,0.0,1.0), valOf (C.fromHex "#f00"))
      (* 4-digit shorthand with alpha *)
      val () = checkRgba "#f008 expands"
                 (valOf (C.fromHex "#ff000088"), valOf (C.fromHex "#f008"))

      val _ = Harness.section "hex print"
      val () = Harness.checkString "toHex red = #ff0000ff"
                 ("#ff0000ff", C.toHex (rgba (1.0,0.0,0.0,1.0)))
      val () = Harness.checkString "toHexRgb red = #ff0000"
                 ("#ff0000", C.toHexRgb (rgb (1.0,0.0,0.0)))
      (* toHex lowercases *)
      val () = Harness.checkString "toHex is lowercase"
                 ("#aabbccdd", C.toHex (valOf (C.fromHex "#AABBCCDD")))
      (* hex print/parse round-trip *)
      val () = checkRgba "fromHex (toHex c) = c"
                 (rgba (0.2,0.4,0.6,0.8),
                  valOf (C.fromHex (C.toHex (rgba (0.2,0.4,0.6,0.8)))))

      val _ = Harness.section "malformed hex"
      val () = Harness.check "empty = NONE" (not (Option.isSome (C.fromHex "")))
      val () = Harness.check "bad chars = NONE"
                 (not (Option.isSome (C.fromHex "#gg0000")))
      val () = Harness.check "wrong length (5) = NONE"
                 (not (Option.isSome (C.fromHex "#12345")))
      val () = Harness.check "wrong length (7) = NONE"
                 (not (Option.isSome (C.fromHex "#1234567")))
    in
      ()
    end
end
