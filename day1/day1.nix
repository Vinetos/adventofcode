let

  abs = x: if x < 0 then 0 - x else x;
  mod =
    a: b:
    if b < 0 then
      0 - mod (0 - a) (0 - b)
    else if a < 0 then
      mod (b - mod (0 - a) b) b
    else
      a - b * (builtins.div a b);
in

let
  # 'L' -> negative, 'R' positive
  parse = line:
    let
      firstChar = builtins.substring 0 1 line;
      numStr = builtins.substring 1 (builtins.stringLength line) line;
      num = builtins.fromJSON numStr;
    in
      if firstChar == "L" then -num else num;

  rot = n: m: 
    mod (n + m) 100;

  atZero = n: m:
    if m > 0
    then builtins.div (n + m) 100
    else builtins.div (n + m) (-100) - builtins.div n (-100);

  # scanl en Nix : accumule les résultats intermédiaires
  scanl = f: acc: list:
    if list == []
    then [acc]
    else [acc] ++ scanl f (f acc (builtins.head list)) (builtins.tail list);

  # Part 1 : compte combien de fois la position est exactement 0
  part1 = lst:
    let
      positions = scanl rot 50 lst;
      isZero = n: if n == 0 then 1 else 0;
    in
      builtins.foldl' builtins.add 0 (map isZero positions);

  # mapAccumL en Nix
  mapAccumL = f: acc: list:
    if list == []
    then { fst = acc; snd = []; }
    else
      let
        result = f acc (builtins.head list);
        rest = mapAccumL f result.fst (builtins.tail list);
      in
        { fst = rest.fst; snd = [result.snd] ++ rest.snd; };

  # Part 2 : somme des passages par zéro
  part2 = lst:
    let
      step = n: m: { fst = rot n m; snd = atZero n m; };
      result = mapAccumL step 50 lst;
    in
      builtins.foldl' builtins.add 0 result.snd;

  # Lecture et traitement du fichier
  inputFile = builtins.readFile ./input.txt;
  lines = builtins.filter (x: x != "") (builtins.split "\n" inputFile);
  input = map parse lines;

in
{
  part1Result = part1 input;
  part2Result = part2 input;
  
  # Pour afficher les résultats
  results = ''
    Part 1: ${(part1 input)}
    Part 2: ${(part2 input)}
  '';
}
