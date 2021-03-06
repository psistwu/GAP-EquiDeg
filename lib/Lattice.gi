#############################################################################
##
#W  Lattice.gi		GAP Package `EquiDeg'			    Haopin Wu
##
#Y  Copyright (C) 2017-2018, Haopin Wu
#Y  Department of Mathematics, National Tsing Hua University, Taiwan
##
##  This file contains implementations of procedures related to lattice.
##

##  Part 1: Poset

#############################################################################
##
#O  IsPSortedList( <list>, <func> )
##
  InstallOtherMethod( IsPSortedList,
    "check whether <list> is sorted with respect to partial order <func>",
    [ IsHomogeneousList, IsFunction ],
    function( list, func )
      local i, j;

      for i in [ 1 .. Size( list ) ] do
        if ForAny( [ i+1 .. Size( list ) ],
            j -> func( list[ j ], list[ i ] ) ) then
          return false;
        fi;
      od;
      return true;
    end
  );

#############################################################################
##
#O  IsPSortedList( <list> )
##
  InstallMethod( IsPSortedList,
    "checks whether <list> is sorted with respect to \\<",
    [ IsHomogeneousList ],
    list -> IsPSortedList( list, \< )
  );

#############################################################################
##
#O  IsPoset( <list>, <func> )
##
  InstallOtherMethod( IsPoset,
    "checks whether <list> is a poset with respect to partial order <func>",
    [ IsHomogeneousList, IsFunction ],
    { list, func } -> IsPSortedList( list, func ) and IsDuplicateFree( list )
  );

#############################################################################
##
#O  IsPoset( <list> )
##
  InstallMethod( IsPoset,
    "checks whether <list> is a poset with respect to \\<",
    [ IsHomogeneousList ],
    list -> IsPoset( list, \< )
  );

#############################################################################
##
#O  PSort( <list>, <func> )
##
  InstallOtherMethod( PSort,
    "sorts <list> with respect to partial order <func>",
    [ IsHomogeneousList and IsMutable, IsFunction ],
    function( list, lt )
      local E,
            S,
            v, vv,
            i,
            slist;

      # find all (directed) edges
      E := [ ];
      for v in list do
        for vv in list do
          if not IsIdenticalObj( v, vv ) and lt( v, vv ) then
            Add( E, [ v, vv ] );
          fi;
        od;
      od;

      # find all start nodes
      S := [ ];
      for v in list do
        if ForAll( E, e -> not IsIdenticalObj( v, e[ 2 ] ) ) then
          Add( S, v );
        fi;
      od;

      slist := [ ];
      while not IsEmpty( S ) do
        v := Remove( S );
        Add( slist, v );

        i := PositionProperty( E, e -> IsIdenticalObj( e[ 1 ], v ) );
        while ( i <> fail ) do
          vv := Remove( E, i )[ 2 ];
          if ForAll( E, e -> not IsIdenticalObj( e[ 2 ], vv ) ) then
            Add( S, vv );
          fi;

          i := PositionProperty( E, e -> IsIdenticalObj( e[ 1 ], v ) );
        od;
      od;

      if IsEmpty( E ) then
        list{ [ 1 .. Size( list ) ] } := slist;
      else
        Info( InfoEquiDeg, INFO_LEVEL_EquiDeg,
            "( <list>, <lt> ) do not form a poset." );
        return fail;
      fi;
    end
  );

#############################################################################
##
#O  PSort( <list> )
##
  InstallMethod( PSort,
    "sorts <list> with respect to \\<",
    [ IsHomogeneousList and IsMutable ],
    function( list )
      PSort( list, \< );
    end
  );

#############################################################################
##
#O  PSortedList( <list>, <func> )
##
  InstallOtherMethod( PSortedList,
    "returns a shallow copy of <list> sorted with respect to partial order <func>",
    [ IsHomogeneousList, IsFunction ],
    function( list, func )
      local tmp;

      tmp := ShallowCopy( list );
      PSort( tmp, func );

      return tmp;
    end
  );

#############################################################################
##
#O  PSortedList( <list> )
##
  InstallMethod( PSortedList,
    "returns a shallow copy of <list> sorted with respect to partial order \\<",
    [ IsHomogeneousList ],
    list -> PSortedList( list, \< )
  );

#############################################################################
##
#O  MaximalElements( <list>, <func> )
##
  InstallOtherMethod( MaximalElements,
    "returns the list of maximal elements in <list> with respect to partial order <func>",
    [ IsList, IsFunction ],
    function( list, func )
      local flag,
            i, j,
            list2,
            a, b;

      # duplicate <list>
      list2 := ShallowCopy( list );

      i := 1;
      while ( i <= Length( list2 ) ) do
        a := list2[ i ];
        # assume <a> is a maximal element
        flag := true;

        j := 1;
        # compare to other elements in <list2>
        while ( j <= Length( list2 ) ) do
          b := list2[ j ];
          if ( a = b ) then
            j := j + 1;
            continue;
          elif func( a, b ) then
            # remove <a> from <list2> if <a> is less than <b>
            Remove( list2, i );
            flag := false;
            break;
          elif func( b, a ) then
            # remove <b> from <list2> if <b> is less then <a>
            Remove( list2, j );
          else
            # keep both <a> and <b> if they are not comparable
            j := j + 1;
          fi;
        od;

        if flag then
          i := i + 1;
        fi;
      od;

      return list2;
    end
  );

#############################################################################
##
#O  MaximalElements( <list> )
##
  InstallOtherMethod( MaximalElements,
    "returns the list of maximal elements in <list> with respect to \\<",
    [ IsList ],
    list -> MaximalElements( list, \< )
  );


##  Part 2: Lattice

#############################################################################
##
#F  NewLattice( <filter>, <r> )
##
  InstallGlobalFunction( NewLattice,
    function( filter, r )
      local n;		# size of the poset

      # check input arguments
      if not IsFilter( filter ) then
        Error( "The first argument should be a filter." );
      elif not IsRecord( r ) then
        Error( "The second argument should be a record." );
      fi;

      # check the components in <r>
      if not IsPoset( r.poset ) then
        Error( "<r.poset> must be a poset." );
      fi;

      n := Size( r.poset );

      if not IsHomogeneousList( r.node_labels ) then
        Error( "<r.node_labels> must be a list." );
      elif not ( Size( r.node_labels ) = n ) then
        Error( "<r.node_labels> and <r.poset> must be of the same size." );
      fi;

      if not IsHomogeneousList( r.node_shapes ) then
        Error( "<r.node_shapes> must be a list." );
      elif not ( Size( r.node_shapes ) = n ) then
        Error( "<r.node_shapes> and <r.poset> must be of the same size." );
      fi;

      if not IsString( r.rank_label ) then
        Error( "<r.rank_label> must be a string." );
      fi;

      if not ( IsHomogeneousList( r.ranks ) and
          Size( r.ranks ) = n ) then
        Error( "<r.ranks> must be a list having the same size as <r.poset>." );
      fi;

      if not IsBool( r.is_rank_reversed ) then
        Error( "<r.is_rank_reversed> must be true or false." );
      fi;

      # generate the lattice object
      return Objectify( NewType( FamilyObj( r.poset ), filter ), r );
    end
  );

#############################################################################
##
#A  String( <lat> )
##
  InstallMethod( String,
    "string of lattice",
    [ IsLatticeRep ],
    lat -> "<lattice>"
  );

#############################################################################
##
#A  UnderlyingPoset( <lat> )
##
  InstallImmediateMethod( UnderlyingPoset,
    "returns underlying poset of a lattice",
    IsLatticeRep,
    0,
    lat -> lat!.poset
  );

#############################################################################
##
#A  MaximalSubElementsLattice( <lat> )
##
  InstallMethod( MaximalSubElementsLattice,
    "return list of indices of maximal sub-elements",
    [ IsCollection and IsLatticeRep ],
    function( lat )
      local i, j,		# indices
            poset,		# poset
            subs,		# sub-elements
            maxsub_list;	# return value

      # extract the sorted list
      poset := UnderlyingPoset( lat );

      # initialize maxsub_list;
      maxsub_list := [ ];

      # find sub-elements of each element
      for i in Reversed( [ 1 .. Size( poset ) ] ) do
        Add( maxsub_list, [ ], 1 );
        for j in [ 1 .. i-1 ] do
          if ( poset[ j ] < poset[ i ] ) then
            Add( maxsub_list[ 1 ], j );
          fi;
        od;
      od;

      # remove indices of non-maximal sub-elements of each element
      for subs in Reversed( maxsub_list ) do
        j := 0;
        while ( j < Size( subs )-1 ) do
          SubtractSet( subs, maxsub_list[ subs[ Size( subs )-j ] ] );
          j := j+1;
        od;
      od;

      return maxsub_list;
    end
  );

#############################################################################
##
#O  DotFileLattice( <lat>, <filename> )
##
  InstallMethod( DotFileLattice,
    "generate the dot file of <lat>",
    [ IsCollection and IsLatticeRep, IsString ],
    function( lat, file )
      local maxsub_list,
            outstream,
            legend_list,
            rank,
            node_label,
            node_shape,
            node_link,
            i, j;

      # extract information form the lattice
      maxsub_list := MaximalSubElementsLattice( lat );
      outstream := OutputTextFile( file, false );

      # put the header of the dot file
      AppendTo( outstream, "digraph lattice {\n" );
      AppendTo( outstream, "size = \"6,6\";\n" );

      # put the legend of ranks on the left-hand side
      if lat!.is_rank_reversed then
        legend_list := Reversed( Set( lat!.ranks ) );
      else
        legend_list := Set( lat!.ranks );
      fi;
      AppendTo( outstream,
          "\"rt\" [label=\"", lat!.rank_label, "\", color=white];\n");
      AppendTo( outstream, "\"rt\" -> ");
      for i in [ 1 .. Size( legend_list ) ] do
        rank := String( legend_list[ i ] );
        AppendTo( outstream,
            "\"s", rank, "\" [color=white, arrowhead=none];\n" );
        AppendTo( outstream,
            "\"s", rank, "\" [label=\"", rank, "\", color=white];\n" );
        if ( i < Size( legend_list ) ) then
          AppendTo( outstream, "\"s", rank, "\" -> ");
        fi;
      od;

      # put nodes of elements
      for i in [ 1 .. Size( UnderlyingPoset( lat ) ) ] do
        node_label := lat!.node_labels[ i ];
        node_shape := lat!.node_shapes[ i ];
        AppendTo( outstream,
            "\"", i, "\" [label=\"", node_label, "\", shape=",
            node_shape, "];\n" );
        AppendTo( outstream,
            "{ rank=same; \"s", lat!.ranks[ i ],
            "\" \"", i, "\"; }\n" );
      od;

      # put links between nodes
      for i in [ 1 .. Size( maxsub_list ) ] do
        for j in [ 1 .. Size( maxsub_list[ i ] ) ] do
          node_link := maxsub_list[ i ][ j ];
          AppendTo( outstream,
              "\"", i, "\" -> \"", node_link, "\" [arrowhead=none];\n" );
        od;
      od;

      AppendTo( outstream, "}" );
      CloseStream( outstream );
    end
  );


#############################################################################
##
#E  Lattice.gi . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here
