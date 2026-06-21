(* sml-color demo: renders an HSV color wheel, a hex-defined palette strip, and
   hue/saturation/value ramps, then writes assets/wheel.png. Exercises
   Color.hsvToRgb and Color.fromHex. *)

val width = 512
val height = 512

fun toI v =
  let val n = Real.round (v * 255.0)
  in if n < 0 then 0 else if n > 255 then 255 else n end

fun hsv (h, s, v) =
  let val { r, g, b } = Color.hsvToRgb { h = h, s = s, v = v }
  in (toI r, toI g, toI b) end

fun hexI s =
  case Color.fromHex s of
      SOME { r, g, b, a = _ } => (toI r, toI g, toI b)
    | NONE => (0, 0, 0)

val palette =
  Vector.fromList
    (map hexI ["#ef476f", "#f78c6b", "#ffd166", "#06d6a0", "#118ab2", "#7b2cbf"])

val bg = (24, 27, 33)
val buf = Array.array (width * height, bg)
fun setpx (x, y, c) = Array.update (buf, y * width + x, c)

val cx = 256.0
val cy = 222.0
val radius = 140.0
val pi = Math.pi

val () =
  let
    fun loop i =
      if i >= width * height then ()
      else
        let
          val x = i mod width
          val y = i div width
        in
          (if y >= 24 andalso y < 72 then
             let
               val sw = width div 6
               val idx = if x div sw > 5 then 5 else x div sw
             in
               setpx (x, y, Vector.sub (palette, idx))
             end
           else
             let
               val dx = real x - cx
               val dy = real y - cy
               val rad = Math.sqrt (dx * dx + dy * dy)
             in
               if rad <= radius then
                 let
                   val ang = Math.atan2 (dy, dx) * 180.0 / pi
                   val hue = if ang < 0.0 then ang + 360.0 else ang
                 in
                   setpx (x, y, hsv (hue, rad / radius, 1.0))
                 end
               else if y >= 386 andalso y < 420 then
                 setpx (x, y, hsv (real x / real width * 360.0, 1.0, 1.0))
               else if y >= 428 andalso y < 462 then
                 setpx (x, y, hsv (210.0, real x / real width, 1.0))
               else if y >= 470 andalso y < 504 then
                 setpx (x, y, hsv (32.0, 0.85, real x / real width))
               else ()
             end);
          loop (i + 1)
        end
  in
    loop 0
  end

val data = Word8Vector.tabulate (4 * width * height, fn i =>
  let
    val px = i div 4
    val ch = i mod 4
    val (r, g, b) = Array.sub (buf, px)
  in
    case ch of
        0 => Word8.fromInt r
      | 1 => Word8.fromInt g
      | 2 => Word8.fromInt b
      | _ => 0w255
  end)

val img : Image.image = { width = width, height = height, data = data }

val () =
  let
    val os = BinIO.openOut "assets/wheel.png"
  in
    BinIO.output (os, Image.encodePng img);
    BinIO.closeOut os;
    print "wrote assets/wheel.png\n"
  end
