let
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;

  smartFilter = input: splitter: builtins.filter (elm: elm != [] && elm != "") (builtins.split splitter input);
  toInt = builtins.fromJSON;
  sum = lib.lists.foldl (a: b: a + b) 0;

  findCombo = bankStr : digitsLength: let
    list = builtins.map toInt (smartFilter bankStr ""); # [ 9 8 1 5 5 1 1 1 ]
    len = builtins.length list;

    indexed = builtins.genList (i: { 
        value = builtins.elemAt list i; 
        index = i; 
    }) len; #  [ { value=9, index=0} {value=9, index=1} ... ]

    # Sort by value then by index 
    # If the same number is the biggest but present multiples time,
    # I wanr the first in index to be at the start
    sorted = builtins.sort (a: b: 
      if a.value != b.value
      then a.value > b.value 
      else a.index < b.index
    ) indexed;

    # Special function that get the n-th biggest number in the last "digitsLength" digits of the bank
    topN = previousElm: n: 
      builtins.elemAt (
        builtins.filter (x: 
             # The n-th best element must be AFTER the (n-1)-th best element
             x.index > previousElm.index && x.index < (len - digitsLength + n)
          ) sorted
      ) 0;

    # generate a the list of all n-th best digit in the bank
    genList = n: 
      if n <= 1 
      # Special case for the first number
      then [ (topN { value=0; index=-1; } 1) ]
      else 
        let 
          # Compute the X first elements before us in order to compute the n-th
          prev = genList (n - 1);
        in prev ++ [ (topN (lib.lists.last prev) n) ];

    # Restore the digits by their index to build the final value
    inOrder = builtins.sort (a: b: a.index < b.index) (genList digitsLength);
    digits = builtins.map (x: x.value) inOrder;
  in
    # Build the final number
    lib.lists.foldl (acc: digit: acc * 10 + digit) 0 digits;

  # Load the file into a list of numbers
  banks = let 
    inputFile = builtins.readFile ./input.txt;
  in smartFilter inputFile "\n";
in
  sum (builtins.map (bank: findCombo bank 12) banks)

