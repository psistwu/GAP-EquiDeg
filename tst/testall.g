Print("You should start GAP using `gap -A -x 80 -r -m 100m -o 1g -K 2g'.\n\n");

LoadPackage("equideg");

TestDirectory(DirectoriesPackageLibrary( "equideg", "tst" ),
  rec(exitGAP     := true,
      testOptions := rec(compareFunction := "uptowhitespace") ) );

FORCE_QUIT_GAP(1);
