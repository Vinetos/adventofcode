let
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;

  # Split input into lines and remove empty lines for processing
  lines = lib.splitString "\n" (builtins.readFile ./input.txt);
  
  # Find the index of the blank line separating ranges from IDs
  blankLineIndex = 
    let
      findBlank = idx: line:
        if line == "" then idx else null;
      indices = pkgs.lib.imap0 findBlank lines;
    in
      pkgs.lib.findFirst (x: x != null) null indices;
  
  # Parse a range string like "3-5" into {start = 3; end = 5;}
  parseRange = rangeStr:
    let
      parts = pkgs.lib.splitString "-" rangeStr;
      start = pkgs.lib.toInt (builtins.elemAt parts 0);
      end = pkgs.lib.toInt (builtins.elemAt parts 1);
    in
      { inherit start end; };
  
  # Get range lines (before blank line)
  rangeLines = pkgs.lib.take blankLineIndex lines;
  ranges = map parseRange (builtins.filter (x: x != "") rangeLines);
  
  # Get ingredient ID lines (after blank line)
  idLines = pkgs.lib.drop (blankLineIndex + 1) lines;
  ingredientIds = map pkgs.lib.toInt (builtins.filter (x: x != "") idLines);
  
  # Check if an ID falls within a range
  inRange = id: range:
    id >= range.start && id <= range.end;
  
  # Check if an ID is fresh (falls in any range)
  isFresh = id:
    builtins.any (range: inRange id range) ranges;
  
  # Count fresh ingredients
  freshIngredients = builtins.filter isFresh ingredientIds;
  part1Count = builtins.length freshIngredients;

  # Part 2
  # Sort ranges by start position
  sortedRanges = builtins.sort (a: b: a.start < b.start) ranges;
  
  # Merge overlapping ranges
  mergeRanges = ranges:
    let
      merge = acc: range:
        if acc == [] then [range]
        else
          let
            last = builtins.head acc;
            rest = builtins.tail acc;
          in
            # If current range overlaps or is adjacent to last, merge them
            if range.start <= last.end + 1
            then [{ start = last.start; end = lib.max last.end range.end; }] ++ rest
            else [range] ++ acc;
      merged = builtins.foldl' merge [] sortedRanges;
    in
      # Reverse since we built the list backwards
      pkgs.lib.reverseList merged;
  
  mergedRanges = mergeRanges sortedRanges;
  
  # Count IDs in merged ranges (no overlap, so just sum)
  part2Count = builtins.foldl' (acc: range: acc + (range.end - range.start + 1)) 0 mergedRanges;

in
  { 
    inherit part1Count part2Count;
  }
