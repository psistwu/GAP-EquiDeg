#############################################################################
##
#W  Utils.gi		GAP package `EquiDeg'			    Haopin Wu
##
#Y  Copyright (C) 2017-2018, Haopin Wu
#Y  Department of Mathematics, National Tsing Hua University, Taiwan
##
##  This file contains implementations of utilities.
##

#############################################################################
##
#O  ViewString( <obj> )
##
# InstallMethod( ViewString,
#   "delegates to attribute Abbrv",
#   [ IsObject and HasAbbrv ],
#   100,
#   obj -> Abbrv( obj )
# );

#############################################################################
##
#O  DisplayString( <obj> )
##
# InstallMethod( DisplayString,
#   "delegates to attribute Detail",
#   [ IsObject and HasDetail ],
#   100,
#   obj -> Detail( obj )
# );

#############################################################################
##
#O  LaTeXTypesetting( <obj> )
##
  InstallMethod( LaTeXTypesetting,
    "return LaTeX typesetting of an object",
    [ IsObject and HasLaTeXString ],
    function( obj )
      return LaTeXString( obj );
    end
  );

#############################################################################
##
#F  ListA( <list1>, <list2>, ..., <listn>, f )
##
  InstallGlobalFunction( ListA,
    function( args... )
      local f,
            m,
            i,
            argf;

      f := Remove( args );
      m := Length( args[ 1 ] );

      if ForAny( args, list -> not ( Length( list ) = m ) ) then
        Error( "<list1>, <list2>, ..., <listn> should have the same length." );
      fi;

      for i in [ 1 .. m ] do
        argf := List( args, x -> x[ i ] );
        CallFuncListWrap( f, argf );
      od;
    end
  );

#############################################################################
##
#O  \[\]( <obj>, <list> )
##
  InstallOtherMethod( \[\],
    "for multi-component indices",
    [ IsObject, IsList ],
    function( obj, list )
      return CallFuncList( \[\,\], Flat( [ obj, list ] ) );
    end
  );

#############################################################################
##
#O  Divides( <m>, <n> )
##
  InstallMethod( Divides,
    "test if <m> divides <n>",
    [ IsInt, IsInt ],
    function( m, n )
      if IsZero( m ) then
        return IsZero( n );
      else
        return ( n mod m = 0 );
      fi;
    end
  );

#############################################################################
##
#E  Utils.gi . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here
