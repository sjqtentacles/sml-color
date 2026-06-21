(* entry.sml -- runs every suite and exits with a status code. *)

fun runAllSuites () =
  ( Harness.reset ()
  ; ConvertTests.run ()
  ; GammaTests.run ()
  ; PackTests.run ()
  ; InterpTests.run ()
  ; Harness.run () )

fun main () =
  OS.Process.exit
    (if runAllSuites () then OS.Process.success else OS.Process.failure)
