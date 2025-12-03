let
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;

  inputFile = builtins.readFile ./input.txt;

  # Parse a str and return {star; end}
  parseRange = str: let
    parts = builtins.split "-" str;
    start = builtins.fromJSON (builtins.elemAt parts 0);
    end = builtins.fromJSON (builtins.elemAt parts 2);
  in { inherit start end; };

  # Create a range from parsed range ID
  range = e: lib.lists.range e.start e.end;

  rawRanges = builtins.filter (str: (builtins.toString str) != "") (builtins.split "," inputFile); # list of str
  ranges = map range (map (str: parseRange (builtins.toString str)) rawRanges); # [ { end = 9; start = 1; } ] -> [ [1 .. 9] ]

  # Must return the number if the input is a pattern, else return -1
  testNumber = n: let
    s = builtins.toString n;
    len = builtins.stringLength s;

    # Check if string can be split into two equal halves
    checkHalf = s: len: 
      if len == 0
      then false
      else let
        half = builtins.floor (builtins.div len 2);
        first = builtins.substring 0 half s;
        second = builtins.substring half (-1) s;
      in first == second && first != "";
    
  in if checkHalf s len then n else -1;

  testRange = range: builtins.filter (n: n != -1) (builtins.map testNumber range);

  invalidRanges = lib.lists.flatten (builtins.filter (range: builtins.length range > 0) (builtins.map testRange ranges));

in
 builtins.foldl' (acc: elem: acc + elem) 0 invalidRanges 
