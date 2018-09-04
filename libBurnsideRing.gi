# # GAP: Burnside Ring Library
#
# Implementation file of libBurnsideRing.g
#
# Author:
#   Hao-pin Wu <hxw132130@utdallas.edu>
#


# ## Part 1: Burnside ring element
# ### attribute(s)
  InstallMethod( Length,
    "length of the summand in a Burnside ring element",
    [ IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep ],
    e -> Length( e!.CCSIndices )
  );

# ***
  InstallMethod( ToSparseList,
    "convert a Burnside ring element to a sparse list",
    [ IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep ],
    e -> List( [ 1 .. Length( e ) ], k -> [ e!.CCSIndices[ k ], e!.coefficients[ k ] ] )
  );

# ***
  InstallMethod( ToDenseList,
    "convert a Burnside ring element to a dense list",
    [ IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep ],
    function( e )
      local list,   # the return list
            fam,    # the family of the Burnside ring element
            dim;    # dimension of the Burnside module (ring)

      fam := FamilyObj( e );
      dim := fam!.DIMENSION;
      list := ZeroOp( [ 1 .. dim ] );
      list{ e!.CCSIndices } := e!.coefficients;

      return list;
    end
  );


# ### operation(s)
# ***
  InstallMethod( String,
    "string of a Burnside ring element",
    [ IsBurnsideRingElement ],
    function( e )
      local i,        # index
            coeff,    # coefficient
            ccsind,   # index of CCS
            str;      # name string

      str := "<";
      for i in [ 1 .. Length( e ) ] do
        coeff := e!.coefficients[ i ];
        ccsind := e!.CCSIndices[ i ];
        if ( i > 1 ) and ( coeff > 0 ) then
          Append( str, "+" );
        fi;
        Append( str, String( coeff ) );
        Append( str, "(" );
        Append( str, String( ccsind ) );
        Append( str, ")" );
      od;
      Append( str, ">" );

      return str;
    end
  );

# ***
  InstallMethod( ViewString,
    "view string of a Burnside ring element",
    [ IsBurnsideRingElement ],
    function( e )
      local fam,      # the family of Burnside ring elements
            ring;     # the Burnside ring

      fam := FamilyObj( e );
      ring := fam!.BurnsideRing;

      return Concatenation( String( e ), " in ", ViewString( ring ) );
    end
  );

# ***
  InstallMethod( PrintString,
    "print string of a Burnside ring element",
    [ IsBurnsideRingElement ],
    function( e )
      local fam,      # the family of Burnside ring elements
            ring;     # the Burnside ring

      fam := FamilyObj( e );
      ring := fam!.BurnsideRing;

      return Concatenation( String( e ), " in ", PrintString( ring ) );
    end
  );

# ***
  InstallMethod( \=,
    "identical relation in a Burnside ring",
    IsIdenticalObj,
    [ IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep,
      IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep ],
    function( a, b )
      return ( a!.CCSIndices = b!.CCSIndices ) and ( a!.coefficients = b!.coefficients );
    end
  );

# ***
  InstallMethod( ZeroOp,
    "additive identity of a Burnside ring",
    [ IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep ],
    function( a )
      local fam;

      fam := FamilyObj( a );

      return Objectify(
        NewType( fam, IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep ),
        rec( CCSIndices := [ ],
             coefficients := [ ] )
      );
    end
  );

# ***
  InstallMethod( OneOp,
    "multiplicative identity of a Burnside ring",
    [ IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep ],
    function( a )
      local fam,
            dim;

      fam := FamilyObj( a );
      dim := fam!.DIMENSION;

      return Objectify(
        NewType( fam, IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep ),
        rec( CCSIndices := [ dim ], coefficients := [ 1 ] )
      );
    end
  );

# ***
  InstallMethod( AdditiveInverseOp,
    "additive inverse in a Burnside ring",
    [ IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep ],
    function( a )
      local fam;

      fam := FamilyObj( a );

      return Objectify(
        NewType( fam, IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep ),
        rec( CCSIndices := a!.CCSIndices,
             coefficients := -a!.coefficients )
      );
    end
  );

# ***
  InstallMethod( \+,
    "addition in a Burnside ring",
    IsIdenticalObj,
    [ IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep,
      IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep ],
    function( a, b )
      local sum_dense_list,
            fam,
            sum_ccs_index_list,
            sum_coefficient_list;

      fam := FamilyObj( a );

      sum_dense_list := ToDenseList( a ) + ToDenseList( b );
      sum_ccs_index_list := PositionsProperty( sum_dense_list, x -> not IsZero( x ) );
      sum_coefficient_list := sum_dense_list{ sum_ccs_index_list };

      return Objectify(
        NewType( fam, IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep ),
        rec( CCSIndices := sum_ccs_index_list,
             coefficients := sum_coefficient_list )
      );
    end
  );

# ***
  InstallMethod( \*,
    "scalar multiplication in a Burnside ring",
    [ IsInt, IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep ],
    function( r, a )
      local fam;

      fam := FamilyObj( a );

      return Objectify(
        NewType( fam, IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep ),
        rec( CCSIndices := a!.CCSIndices, coefficients := r*a!.coefficients )
      );
    end
  );

# ***
  InstallMethod( \*,
    "multiplication in a Burnside ring",
    IsIdenticalObj,
    [ IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep, IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep ],
    function( a, b )
      local fam,                    # family of Burnside ring elements
            grp,                    # group
            ccs_list,               # CCSs
            ring,                   # Burnside ring
            basis,                  # basis of Burnside ring
            indCa,                  # index of CCS a (when a is in the basis )
            indCb,                  # index of CCS b (when b is in the basis )
            Ca,                     # CCS a (when a is in the basis)
            Cb,                     # CCS b (when b is in the basis)
            len,                    # length of the product
            prod,                   # product
            prod_index_list,        # indices of the product
            prod_coefficient_list,  # coefficients of the product
            coeff,                  # a coefficient in the product
            i, j,                   # indices
            Ci, Cj;                 # i-th and j-th CCSs

      fam := FamilyObj( a );
      grp := fam!.GROUP;
      ring := fam!.BurnsideRing;
      basis := Basis( ring );
      ccs_list := fam!.CCSs;

      if ( a in basis ) and ( b in basis ) then
        indCa := a!.CCSIndices[ 1 ];
        indCb := b!.CCSIndices[ 1 ];
        Ca := ccs_list[ indCa ];
        Cb := ccs_list[ indCb ];
        len := 0;
        prod_index_list := [ ];
        prod_coefficient_list := [ ];

        for i in Reversed( [ 1 .. Minimum( indCa, indCb ) ] ) do
          Ci := ccs_list[ i ];
          if not ( ( Ci <= Ca ) and ( Ci <= Cb ) ) then
            continue;
          fi;
          coeff := nLHnumber( Ci, Ca ) * OrderOfWeylGroup( Ca ) * nLHnumber( Ci, Cb ) * OrderOfWeylGroup( Cb );
          for j in [ 1 .. len ] do
            Cj := ccs_list[ prod_index_list[ j ] ];
            coeff := coeff - nLHnumber( Ci, Cj )*prod_coefficient_list[ j ];
          od;
          if not IsZero( coeff ) then
            Add( prod_index_list, i, 1 );
            Add( prod_coefficient_list, coeff, 1 );
            len := len+1;
          fi;
        od;

        return Sum( List( [ 1 .. len ], i -> ( prod_coefficient_list[ i ]/OrderOfWeylGroup( ccs_list[ prod_index_list[ i ] ] ) * basis[ prod_index_list[ i ] ] ) ) );
      else
        prod := Zero( ring );
        for i in [ 1 .. Length( a ) ] do
          for j in [ 1 .. Length( b ) ] do
            prod := prod +
                a!.coefficients[ i ]*
                b!.coefficients[ j ]*
                ( basis[ a!.CCSIndices[ i ] ]*
                basis[ b!.CCSIndices[ j ] ] );
          od;
        od;

        return prod;
      fi;
    end
  );


# ### function(s)
# %%%
# InstallGlobalFunction( TwoListsToIndex,
#   function( ind_max, ind_list, coefficient_list )
#     local n, ind_list_repeated, enumint, ind, ind_min, ind_count, count, i, j, k;

#     enumint := Enumerator( Integers );
#     ind_list_repeated := [ ];
#     for i in [ 1 .. Length( ind_list ) ] do
#       ind := ind_list[ i ];
#       count := Position( enumint, coefficient_list[ i ] ) - 1;
#       for j in [ 1 .. count ] do
#         Add( ind_list_repeated, ind );
#       od;
#     od;
#     ind_min := 1;
#     ind_count := Length( ind_list_repeated );

#     n := Binomial( ind_max+ind_count-1, ind_count-1 );
#     for ind in ind_list_repeated do
#       ind_count := ind_count-1;
#       for i in [ ind_min .. ind-1 ] do
#         n := n + Binomial( ind_max-i+ind_count, ind_count );
#       od;
#       ind_min := ind;
#     od;
#     return n+1;
#   end
# );

# %%%
# InstallGlobalFunction( IndexToTwoLists,
#   function( ind_max, n )
#     local ind_list, coefficient_list, sgn, count, enumint, ind_count, ind, ind_min;

#     ind_list := [ ];
#     coefficient_list := [ ];
#     enumint := Enumerator( Integers );
#     sgn := 1;

#     ind_count := -1;
#     while ( n > 0 ) do
#       ind_count := ind_count+1;
#       n := n - Binomial( ind_max-1+ind_count, ind_count );
#     od;

#     while ( ind_count > 0 ) do
#       ind_count := ind_count-1;
#       if ( sgn = 1 ) then
#         ind := ind_max+1;
#         while ( n <= 0 ) do
#           ind := ind-1;
#           n := n + Binomial( ind_max-ind+ind_count, ind_count );
#         od;
#       elif ( sgn = -1 ) then
#         ind := ind_min-1;
#         while ( n > 0 ) do
#           ind := ind+1;
#           n := n - Binomial( ind_max-ind+ind_count, ind_count );
#         od;
#       fi;

#       if not IsBound( ind_min ) then
#         ind_min := ind;
#         count := 1;
#       elif ( ind = ind_min ) then
#         count := count+1;
#       elif ( ind > ind_min ) then
#         Add( ind_list, ind_min );
#         Add( coefficient_list, enumint[ count+1 ] );
#         ind_min := ind;
#         count := 1;
#       fi;

#       sgn := -sgn;
#     od;

#     if IsBound( ind_min ) then
#       Add( ind_list, ind_min );
#       Add( coefficient_list, enumint[ count+1 ] );
#     fi;

#     return rec( ind_list := ind_list, coefficient_list := coefficient_list );
#   end
# );


# ## Part 2: Burnside ring
# ### constructor(s)
  InstallMethod( NewBurnsideRing,
    "create a Burnside ring induced by a small group",
    [ IsBurnsideRing and IsBurnsideRingBySmallGroupRep, IsGroup ],
    function( filter, grp )
      local elemfam,     # family of the Burnside ring elements
            elemfil,     # filter of the Burnside ring elements
            gid,         # group id
            ring,        # the Burnside ring
            enumerator,  # enumerator of the Burnside ring
            ccs_list,    # conjugacy classes of subgroups
            d,           # dimension of the module (ring)
            basis,       # basis of the module (ring)
            i, j;        # indices

      # extract info of grp
      ccs_list := ConjugacyClassesSubgroups( grp );
      d := Size( ccs_list );

      # create the family with corresponding data
      elemfil := IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep;
      elemfam := NewFamily( Concatenation( "BurnsideRing(", ViewString( grp ), ")Family" ), elemfil );
      elemfam!.GROUP := grp;
      elemfam!.CCSs := ccs_list;
      elemfam!.DIMENSION := d;

      # use basis to generate the Burnside ring
      ring := Objectify( NewType( CollectionsFamily( elemfam ), filter ), rec( ) );
      elemfam!.BurnsideRing := ring;
      SetDimension( ring, d );
#     enumring := Enumerator( ring );
#     basis := enumring{ [ 2 .. d+1 ] };
      basis := [ ];
      for i in [ 1 .. d ] do
        Add( basis, Objectify(
          NewType( elemfam, elemfil ),
          rec( CCSIndices := [ i ], coefficients := [ 1 ] ) )
        );
      od;

      # attributes related to its ring structure
      SetGeneratorsOfRing( ring, basis );
      SetIsWholeFamily( ring, true );
      SetZeroImmutable( ring, Objectify(
        NewType( elemfam, elemfil ),
        rec( CCSIndices := [ ], coefficients := [ ] ) )
      );
      SetOneImmutable( ring, basis[ d ] );

      # attributes related to its module structure
      SetBasis( ring, basis );
      SetLeftActingDomain( ring, Integers );
      SetIsFiniteDimensional( ring, true );

      # attributes related to its Burnside ring sturcture
      SetUnderlyingGroup( ring, grp );

      return ring;
    end
  );


# ### attribute(s)
# ***
  InstallMethod( BurnsideRing,
    "return the Burnside ring induced by a group",
    [ IsGroup ],
    grp -> NewBurnsideRing( IsBurnsideRing and IsBurnsideRingBySmallGroupRep, grp )
  );

# %%%
# InstallMethod( Enumerator,
#   "enumerator of a Burnside ring by a small group",
#   [ IsBurnsideRing and IsBurnsideRingBySmallGroupRep ],
#   ring -> EnumeratorByFunctions( ring,
#     rec(
#       ElementNumber := function( e, n )
#         local fam, two_lists;
#         fam := ElementsFamily( FamilyObj( ring ) );
#         two_lists := IndexToTwoLists( Dimension( ring ), n );
#         return Objectify( NewType( fam, IsBurnsideRingElement and IsBurnsideRingBySmallGroupElementRep ), rec( ccs_list := two_lists.ind_list, coefficient_list := two_lists.coefficient_list ) );
#       end,

#       NumberElement := function( e, x )
#         return TwoListsToIndex( Dimension( ring ), x!.ccs_list, x!.coefficient_list );
#       end,

#       Length := e -> infinity
#     )
#   )
# );


# ## operation(s)
# ***
  InstallMethod( ViewString,
    "view string of a Burnside ring",
    [ IsBurnsideRing ],
    ring -> Concatenation("BurnsideRing( ", ViewString( UnderlyingGroup( ring ) ), " )" )
  );

# ***
  InstallMethod( ViewObj,
    "view a Burnside ring",
    [ IsBurnsideRing ],
    function( ring )
      Print( ViewString( ring ) );
    end
  );

# ***
  InstallMethod( PrintString,
    "print string of a Burnside ring",
    [ IsBurnsideRing ],
    ring -> Concatenation("BurnsideRing( ", PrintString( UnderlyingGroup( ring ) ), " )" )
  );

# ***
  InstallMethod( PrintObj,
    "print a Burnside ring",
    [ IsBurnsideRing ],
    function( ring )
      Print( PrintString( ring ) );
    end
  );


# ## Part 3: Other Aspects
# ### attribute(s)
  InstallMethod( BasicDegree,
    "return the Basic Degree of the representation",
    [ IsCharacter ],
    function( chi )
      local grp,                    # group
            ccs_list,               # CCSs
            ring,                   # Burnside ring
            basis,                  # basis of Burnside ring
            lat,                    # lattice of orbit types
            orbittype_index_list,   # Indices of orbit types
            fixeddim_list,          # dimension of fixed point space
            coeff,                  # coefficent
            i, j,                   # indices
            n,                      # number of orbit types
            len,                    # length of basic degree
            Oi, Oj,                 # orbit types
            bdeg_index_list,        # indices of basic degree
            bdeg_coefficient_list;  # coefficient of basic degree

      grp := UnderlyingGroup( chi );
      ccs_list := ConjugacyClassesSubgroups( grp );
      ring := BurnsideRing( grp );
      basis := Basis( ring );
      lat := LatticeOrbitTypes( chi );
      orbittype_index_list := OrbitTypes( chi );
      fixeddim_list := lat!.ranks;
      bdeg_index_list := [ ];
      bdeg_coefficient_list := [ ];
      len := 0;

      n := Size( orbittype_index_list );
      for i in Reversed( [ 1 .. n ] ) do
        Oi := ccs_list[ orbittype_index_list[ i ] ];
        coeff := (-1)^fixeddim_list[ i ];
        for j in [ 1 .. len ] do
          Oj := ccs_list[ bdeg_index_list[ j ] ];
          coeff := coeff - bdeg_coefficient_list[ j ]*nLHnumber( Oi, Oj );
        od;
        if not IsZero( coeff ) then
          Add( bdeg_index_list, orbittype_index_list[ i ], 1 );
          Add( bdeg_coefficient_list, coeff, 1 );
          len := len+1;
        fi;
      od;

      return Sum( List( [ 1 .. len ], i -> ( bdeg_coefficient_list[ i ]/OrderOfWeylGroup( ccs_list[ bdeg_index_list[ i ] ] ) ) * basis[ bdeg_index_list[ i ] ] ) );
    end
  );

