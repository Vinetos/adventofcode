let
  inherit (builtins) elemAt length filter stringLength substring genList concatStringsSep;

  smartFilter = input: splitter: filter (elm: elm != [] && elm != "") (builtins.split splitter input);

  # Load the grid
  initialLines = let 
    inputFile = builtins.readFile ./input.txt;
  in smartFilter inputFile "\n";

  height = length initialLines;
  width = stringLength (elemAt initialLines 0);

  # Get a char a the given location on the grid 
  charAt = lines: y: x:
    if y < 0 || y >= height || x < 0 || x >= width
    then null
    else substring x 1 (elemAt lines y);

  directions = [
    { dy = -1; dx = -1; }
    { dy = -1; dx = 0; }
    { dy = -1; dx = 1; }
    { dy = 0; dx = -1; }
    { dy = 0; dx = 1; } 
    { dy = 1; dx = -1; }
    { dy = 1; dx = 0; }
    { dy = 1; dx = 1; }
  ];

  # Count the number of @ rolls around x,y in a given grid
  countAdjacentPaper = lines: y: x:
    let
      adjacentChars = map (dir: charAt lines (y + dir.dy) (x + dir.dx)) directions;
      paperRolls = filter (c: c == "@") adjacentChars;
    in
      length paperRolls;

  # Test if the case is accessible in a given grid - with less than < 4 rolls around
  isAccessible = lines: y: x:
    let
      char = charAt lines y x;
      adjacentCount = countAdjacentPaper lines y x;
    in
      (char == "@") && adjacentCount < 4;

  # Find all accesssible positions on the grid
  findAccessible = lines:
    let
      allPositions = genList (y:
        genList (x: { inherit y x; }) width
      ) height;
      flatPositions = builtins.concatLists allPositions;
      accessible = filter (pos: isAccessible lines pos.y pos.x) flatPositions;
    in
      accessible;

  # Replace a char at a given position on a line
  replaceCharAt = line: x: newChar:
    let
      before = substring 0 x line;
      after = substring (x + 1) (width - x - 1) line;
    in
      before + newChar + after;

  # Replace a @ by a X
  removeSinglePos = lines: pos:
    let
      newLine = replaceCharAt (elemAt lines pos.y) pos.x "x";
      newLines = genList (y:
        if y == pos.y then newLine else elemAt lines y
      ) height;
    in
      newLines;

  # Remove all accessible position at this part
  removeAccessible = lines: positions:
    if positions == [] then lines
    else
      let
        newLines = removeSinglePos lines (elemAt positions 0);
      in
        removeAccessible newLines (builtins.tail positions);

  # Part 1
  accessiblePositions = findAccessible initialLines;

  # Utility for debbuing the grid
  markedGrid = genList (y:
    let
      chars = genList (x:
        let char = charAt initialLines y x;
        in if isAccessible initialLines y x then "x" else char
      ) width;
    in
      concatStringsSep "" chars
  ) height;

  # Part 2
  iterate = lines: totalRemoved:
    let
      accessible = findAccessible lines;
      count = length accessible;
    in
      if count == 0 then
        { inherit lines totalRemoved; }
      else
        let
          newLines = removeAccessible lines accessible;
        in
          iterate newLines (totalRemoved + count);
  
  iterationResult = iterate initialLines 0;

  result = {
    part1 = length accessiblePositions;
    part2 = iterationResult.totalRemoved;
    grid = concatStringsSep "\n" markedGrid;
    finalGrid = concatStringsSep "\n" iterationResult.lines;
  };

in
  result
