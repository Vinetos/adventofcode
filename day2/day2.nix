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
    checkPattern = patternLen: 
      if patternLen == 0 || patternLen >= len
      then false
      else let
        pattern = builtins.substring 0 patternLen s;
        numRepeats = len / patternLen;
        
        # Check if pattern has leading zero
        hasLeadingZero = builtins.substring 0 1 pattern == "0";
        
        # Build expected string by repeating pattern
        repeatPattern = n: if n == 0 then "" else pattern + repeatPattern (n - 1);
        expected = repeatPattern numRepeats;
      in !hasLeadingZero && s == expected && numRepeats >= 2;
    
    # Try all possible pattern lengths from 1 to len/2
    possibleLengths = builtins.genList (i: i + 1) (len / 2);
    
  in if builtins.any checkPattern possibleLengths then n else -1;

  testRange = range: builtins.filter (n: n != -1) (builtins.map testNumber range);

  invalidRanges = lib.lists.flatten (builtins.filter (range: builtins.length range > 0) (builtins.map testRange ranges));

in
 builtins.foldl' (acc: elem: acc + elem) 0 invalidRanges 
