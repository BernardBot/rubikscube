% Rubiks cube solver using beginners five step method.
% 1. Daisy on bottom
% 2. Corners on bottom
% 3. Middle match
% 4. Daisy on top
% 5. Corners on top

% A human would use a seven step method.
% 1. daisy
% 2. align corner R U R' U'
% 3.1. F U F U F U' F' U' F'
% 3.2 R' U' R' U' R' U R U R
% 4. F R U R' U' F' (Daisy geel boven)
% 5. R U R' U R U'2 R' (Midden Match)
% 6. U R U' L' U R' U' L (Corner Match) (L’ is van je af, dus de R)  
% 7. U R' U' R + (F)

global beginneralgorithm;
global maxdepth = 10;
global plt;
global basicmoves;
global rot;
global qube;

% Example usage of functions in this file.
function example()
  c = scramble();
  t = time ();
  s = solve(c);
  t = time () - t
  animatecube2d(c,s);
end

% face layout
%   1          U
% 2 3 4 5    L F R B
%   6          D
%
% indices of stickers
%           1  4  7
%           2  5  8
%           3  6  9
% 10 13 16  19 22 25  28 31 34  37 40 43
% 11 14 17  20 23 26  29 32 35  38 41 44
% 12 15 18  21 24 27  30 33 36  39 42 45
%           46 49 52
%           47 50 53
%           48 51 54

% A 'move' is a string or cell array of string. For example:
%
% "U" "U' R R' U" "L U L"
% {"U" "R" "R'" "U'"} {"L U L" "L U L"}
%
% Note that multiple moves can be interpreted as one single move.
% Their representation can overlap, but multiple moves can be array of
% arrays while moves can be strings. They have a shared representation, but also a
% not shared one. This overlapping view is very useful for describing algorithms.
%
% "U"     a move
% {"U"}   a move or multiple moves
% {{"U"}}           multiple moves
%
% A 'cube' is a column vector of the elements 1 to 6 repeated 9 times for each face.
%
% Permutattions of a 'cube' are column vectors of the elements 1 to 54. See the
% indexing scheme above. For example:
%
% U Ui R(Ri)(U) L(U)(L)
%
% We can view the rotation of the cube thus in two forms: strings and column vectors.
% The following function converts from the first representation to the second.
function perm = move2perm(move)
  global rot;

  perm = (1:54)';

  if iscell(move)
    move = strjoin(move, " ");
  end

  if isempty(move)
    return;
  end

  for m = strsplit(strtrim(strrep(move, "'", "i")), " ")
    perm = perm(rot.(m{1}));
  end
end

function perms = moves2perms(moves)
  perms = cell2mat(cellfun(@move2perm, moves, "UniformOutput", false));
end

% Depth first search with iterative deapening on cube.
%
% We narrow the search space by only looking if some 'stickers' are in place and
% if we can reach such a 'cube' using a set of certain 'perms'. Our branching factor
% is equal to the number of perms.
%
% Iterative deepening is search for an increasing depth. This seems like you would
% repeat a lot of move sequences in your search and it is. However, since the bottom
% layer of your search tree contains more nodes than all layers above it for a
% constant branching; this does not cause much slow-down.
function res = search(cube, stickers, perms)
  global maxdepth qube;

  qubestickers = qube(stickers);

  function [found res] = _search(cube, depth, res)
    if cube(stickers) == qubestickers % check if stickers are in place
      found = 1;
      return;
    end

    found = 0;

    if depth <= 0
      return;
    end

    for perm = perms % traverse search space
      [found _res] = _search(cube(perm), depth - 1, [res perm]);
      if found
	res = _res;
	return;
      end
    end
  end

  % iterative deepening
  for depth = 0:maxdepth
    [found res] = _search(cube, depth, []);
    if found
      return;
    end
  end
end

function i = findcolumn(v, vs)
  i = find(all(v == vs), 1);
end

% Our solve algorithm takes a 'cube' and an algorithm object.
%
% An 'algorithm' object is a sequence of subalgorithms, which have
% 'steps' and 'perms'. A 'step' is a list of stickers that should be solved
% at the end of that step. The 'perms' determine the search space for each
% subalgorithm. Steps have share perms in this implementation.
%
% This function returns both the sequence of moves 'ms' and permutations 'ps'.
%
% We incrementally search subspaces and concatenate the solutions to get
% our final result.
function [ms ps] = solve(cube, algorithm)
  global beginneralgorithm;

  if nargin < 2
    algorithm = beginneralgorithm;
  end

  ms = {};
  ps = [];

  for alg = algorithm
    alg.name % print subalgorithm name
    perms = moves2perms(alg.moves); % generate permutations for search

    for step = alg.steps
      res = search(cube, step{1}, perms); % search for solution of step
      ps = [ps res];

      for perm = res
	cube = cube(perm);
	i = findcolumn(perm, perms);
	ms = [ms alg.moves(i)];
      end
    end
  end
end

% Scramble a 'cube' picking form a set of 'moves' 'n' times and
% and applying them in turn.
%
% Returns both the resulting 'cube' and randomly selected sequence of
% 'n' 'moves'.
function [cube moves] = scramble(cube, moves, n)
  global basicmoves qube;

  if nargin < 1
    cube = qube;
  end

  if nargin < 2
    moves = basicmoves;
  end

  if nargin < 3
    n = 40;
  end

  moves = moves(randi(numel(moves),1,n));
  for move = moves
    cube = cube(move2perm(move));
  end
end

% Plot a 'cube' on a two-dimensional grid.
function plotcube2d(cube)
  global plt;

  clf;
  axis off;
  colormap(plt.cmap);

  patch("Vertices", plt.verts, "Faces", plt.faces,...
	"FaceVertexCData", cube, "FaceColor", "flat");
end

% For each 'move' in 'moves' plot a 'cube' in two dimensions.
function animatecube2d(cube, moves, wait)
  if nargin < 3
    wait = 0;
  end

  for move = moves
    plotcube2d(cube);
    title(move, "FontSize", 20);
    pause(0.05);

    if wait
      input("press to continue ");
    end	  

    cube = cube(move2perm(move));
  end
  plotcube2d(cube);
end

rect = [0 0; 0 1; 1 1; 1 0];
v = [];
for i=1:3
  for j=3:-1:1
    v = [v; rect + [i j]];
  end
end

x = [3 0]; y = [0 3];
plt.verts = [v+y; v-x; v; v+x; v+2*x; v-y];
plt.faces = reshape(1:216,4,54)';
plt.cmap = [1 1 0; 0.8 0 0; 0 0.8 0; 1 0.65 0; 0.3 0.3 0.8; 1 1 1];

clear rect x y v;

% Enter a cube with the left mouse button to cycle colors.
% Press any other key to quit and return entered cube.
% http://matlab.izmiran.ru/help/techdoc/creating_plots/specia32.html#interactive_plotting
function cube = entercube()
  global qube plt;

  cube = qube;
  but = 1;
  while but == 1
    plotcube2d(cube);
    [x y but] = ginput(1);

    if but == 1
      i = findcolumn([ceil(x) floor(y)]', plt.verts') / 4;
      if isindex(i, 54)
	cube(i) = mod(cube(i), 6) + 1;
      end
    end
  end
end

% solved cube
qube = [1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 3 4 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 6 6 6 6 6 6 6 6 6]';

% identity permutation
I = (1:54)';

% 6 basis permutation vectors
U = [3 6 9 2 5 8 1 4 7 19 11 12 22 14 15 25 17 18 28 20 21 31 23 24 34 26 27 37 29 30 40 32 33 43 35 36 10 38 39 13 41 42 16 44 45 46 47 48 49 50 51 52 53 54]';
F = [1 2 18 4 5 17 7 8 16 10 11 12 13 14 15 46 49 52 21 24 27 20 23 26 19 22 25 3 6 9 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 30 47 48 29 50 51 28 53 54]';
L = [45 44 43 4 5 6 7 8 9 12 15 18 11 14 17 10 13 16 1 2 3 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 48 47 46 19 20 21 49 50 51 52 53 54]';
R = [1 2 3 4 5 6 25 26 27 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 52 53 54 30 33 36 29 32 35 28 31 34 9 8 7 40 41 42 43 44 45 46 47 48 49 50 51 39 38 37]';
B = [34 2 3 35 5 6 36 8 9 7 4 1 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 54 51 48 39 42 45 38 41 44 37 40 43 46 47 10 49 50 11 52 53 12]';
D = [1 2 3 4 5 6 7 8 9 10 11 39 13 14 42 16 17 45 19 20 12 22 23 15 25 26 18 28 29 21 31 32 24 34 35 27 37 38 30 40 41 33 43 44 36 48 51 54 47 50 53 46 49 52]';

% 3 orientation vectors
X = [19 20 21 22 23 24 25 26 27 16 13 10 17 14 11 18 15 12 46 47 48 49 50 51 52 53 54 30 33 36 29 32 35 28 31 34 9 8 7 6 5 4 3 2 1 45 44 43 42 41 40 39 38 37]';
Y = [3 6 9 2 5 8 1 4 7 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 10 11 12 13 14 15 16 17 18 52 49 46 53 50 47 54 51 48]';
Z = [12 15 18 11 14 17 10 13 16 48 51 54 47 50 53 46 49 52 21 24 27 20 23 26 19 22 25 3 6 9 2 5 8 1 4 7 37 38 39 40 41 42 43 44 45 30 33 36 29 32 35 28 31 34]';

U2 = U(U); Ui = U(U)(U);
F2 = F(F); Fi = F(F)(F);
L2 = L(L); Li = L(L)(L);
R2 = R(R); Ri = R(R)(R);
B2 = B(B); Bi = B(B)(B);
D2 = D(D); Di = D(D)(D);

X2 = X(X); Xi = X(X)(X);
Y2 = Y(Y); Yi = Y(Y)(Y);
Z2 = Z(Z); Zi = Z(Z)(Z);

rot.U = U; rot.U2 = U2; rot.Ui = Ui; 
rot.F = F; rot.F2 = F2; rot.Fi = Fi;
rot.L = L; rot.L2 = L2; rot.Li = Li;
rot.R = R; rot.R2 = R2; rot.Ri = Ri;
rot.B = B; rot.B2 = B2; rot.Bi = Bi;
rot.D = D; rot.D2 = D2; rot.Di = Di;

rot.X = X; rot.X2 = X2; rot.Xi = Xi;
rot.Y = Y; rot.Y2 = Y2; rot.Yi = Yi;
rot.Z = Z; rot.Z2 = Z2; rot.Zi = Zi;

basicmoves =...
{
 "L"  "R"  "U"  "D"  "F"  "B"...
 "L2" "R2" "U2" "D2" "F2" "B2"...
 "L'" "R'" "U'" "D'" "F'" "B'"
};

% could improve here, often slowest part...
m1 = basicmoves;

% 5 sub algorithms
m2 =...
{
 "U" "U2" "U'"...
 "R U R' U'"...
 "R U R' U' R U R' U'"...
 "R U R' U' R U R' U' R U R' U'"...
 "R U R' U' R U R' U' R U R' U' R U R' U'"...
 "R U R' U' R U R' U' R U R' U' R U R' U' R U R' U'"...
 "L U L' U'"...
 "L U L' U' L U L' U'"...
 "L U L' U' L U L' U' L U L' U'"...
 "L U L' U' L U L' U' L U L' U' L U L' U'"...
 "L U L' U' L U L' U' L U L' U' L U L' U' L U L' U'"...
 "F U F' U'"...
 "F U F' U' F U F' U'"...
 "F U F' U' F U F' U' F U F' U'"...
 "F U F' U' F U F' U' F U F' U' F U F' U'"...
 "F U F' U' F U F' U' F U F' U' F U F' U' F U F' U'"...
 "B U B' U'"...
 "B U B' U' B U B' U'"...
 "B U B' U' B U B' U' B U B' U'"...
 "B U B' U' B U B' U' B U B' U' B U B' U'"...
 "B U B' U' B U B' U' B U B' U' B U B' U' B U B' U'"
};

m3 =...
{
 "U" "U2" "U'"...
 "F U F U F U' F' U' F'" "F' U' F' U' F' U F U F"...
 "R U R U R U' R' U' R'" "R' U' R' U' R' U R U R"...
 "L U L U L U' L' U' L'" "L' U' L' U' L' U L U L"...
 "B U B U B U' B' U' B'" "B' U' B' U' B' U B U B"...
};

m4 =...
{
 "U" "U2" "U'"...
 "F R U R' U' F'"...
 "R U R' U R U2 R'"
};

m5 =...
{
 "U" "U2" "U'"...
 "U R U' L' U R' U' L"...
 "U F U' B' U F' U' B"...
 "U L U' R' U L' U' R"...
 "U B U' L' U B' U' L"...
 "U R' U' R"
};

% Cubies are named by their three faces.
% We orient the cube such that the edge or corner is in the top layer
% to the middle or right respecively.
%
% 12 edge cubies
ul = [2  13]'; uf = [6  22]'; ur = [8  31]'; ub = [4  40]';
fr = [26 29]'; rb = [35 38]'; bl = [44 11]'; lf = [17 20]';
dl = [47 15]'; df = [49 24]'; dr = [53 33]'; db = [51 42]';

% 8 corner cubies
ubl = [1  43 10]'; ulf = [3  16 19]'; ufr = [9  25 28]'; ulb = [7  34 37]';
dbr = [54 39 36]'; drf = [52 30 27]'; dfl = [46 21 18]'; dlb = [48 12 45]';

% 5 incremental steps
s11 =       dl;   s12 = [s11; df];  s13 = [s12; dr];  s14 = [s13; db];
s21 = [s14; dbr]; s22 = [s21; drf]; s23 = [s22; dfl]; s24 = [s23; dlb];
s31 = [s24; fr];  s32 = [s31; rb];  s33 = [s32; bl];  s34 = [s33; lf];
s4  = [s34; ul;               uf;               ur;               ub];
s51 = [s4;  ubl]; s52 = [s51; ulf]; s53 = [s52; ufr]; s54 = [s53; ulb];

% 1 algorithm
a1.name = "daisybot";  a1.steps = {s11 s12 s13 s14}; a1.moves = m1;
a2.name = "cornerbot"; a2.steps = {s21 s22 s23 s24}; a2.moves = m2;
a3.name = "middle";    a3.steps = {s31 s32 s33 s34}; a3.moves = m3;
a4.name = "daisytop";  a4.steps = {s4};              a4.moves = m4;
a5.name = "cornertop"; a5.steps = {s51 s52 s53 s54}; a5.moves = m5;

beginneralgorithm = [a1 a2 a3 a4 a5];
