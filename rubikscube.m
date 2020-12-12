% Rubiks cube solver using beginners method

% TODO
% input method for cubes
% Name stuff better, e.g., move movestrs movs alg algorithm...??
% Support for other moves (middle, etc.)

global maxdepth = 10;
global plt;
global basicmoves;
global rot;

function cube = domovestr(movestr, cube)
  global rot;

  if nargin < 2
    cube = (1:54)';
  end

  if iscell(movestr)
    movestr = strjoin(movestr, " ");
  end

  if isempty(movestr)
    return
  end

  for move = strsplit(strtrim(strrep(movestr, "'", "i")), " ")
    cube = cube(rot.(move{1}));
  end
end

function moves = buildmoves(ms)
  moves = [];
  for m = ms
    moves = [moves domovestr(m)];
  end
end

% depth first search on cube
function alg = search(cube, stickers, moves)
  global maxdepth;

  function [found alg] = _search(cube, depth, alg)

    if cube(stickers) == stickers
      found = 1;
      return;
    end

    found = 0;

    if depth <= 0
      return;
    end

    for move = moves
      [found _alg] = _search(cube(move), depth - 1, [alg move]);
      if found
	alg = _alg;
	return;
      end
    end

  end

  % iterative deepening
  for depth = 0:maxdepth
    [found alg] = _search(cube, depth, []);
    if found
      return;
    end
  end
  
end

function [solution movs] = solve(cube, algorithm)
  solution = {};
  movs = [];

  for alg = algorithm
    alg.name
    moves = buildmoves(alg.moves);

    for step = alg.steps
      mov = search(cube, step{1}, moves);
      movs = [movs mov];

      for m = mov
	cube = cube(m);
	i = find(all(m == moves));
	solution = [solution alg.moves(i)];
      end
    end
  end
end

% scramble cube
function [cube alg] = scramble(cube, moves, n)
  global basicmoves;

  if nargin < 2
    moves = basicmoves;
  end

  if nargin < 3
    n = 40;
  end

  alg = {};
  for move = moves(randi(numel(moves),1,n))
    cube = domovestr(move, cube);
    alg = [alg move];
  end
end

% plotting and animation
function plotcube2d(cube)
  global plt;

  for i = 1:54
    plt.str(i) = num2str(cube(i));
    plt.col(i) = idivide(cube(i)-1,9)+1;
  end

  cla;
  axis off;
  colormap(plt.cmap);

  patch("Vertices", plt.verts, "Faces", plt.faces,...
	"FaceVertexCData", plt.col, "FaceColor", "flat");
  text(plt.cents(:,1), plt.cents(:,2), plt.str,...
       "FontSize", 14, "HorizontalAlignment", "center");
end

function animatecube2d(moves, cube)
  for move = moves
    title(move, "FontSize", 20);
    plotcube2d(cube);
%    input("press to continue ");
    pause(0.1);
    cube = domovestr(move, cube);
  end
end

rect = [0 0; 0 1; 1 1; 1 0]; x = [3 0]; y = [0 3];
v = u = [];
for i=1:3
  for j=3:-1:1
    t = rect + [i j];
    v = [v; t];
    u = [u; mean(t)];
  end
end

plt.verts = [v+y; v-x; v; v+x; v+2*x; v-y];
plt.cents = [u+y; u-x; u; u+x; u+2*x; u-y];
plt.faces = reshape(1:216,4,54)';
plt.str = cell(54,1);
plt.col = zeros(54,1);
plt.cmap = [1 1 0; 0.8 0 0; 0 0.8 0; 1 0.65 0; 0.3 0.3 0.8; 1 1 1];

clear rect x y v u;

% cube data
I = (1:54)';

U = [3 6 9 2 5 8 1 4 7 19 11 12 22 14 15 25 17 18 28 20 21 31 23 24 34 26 27 37 29 30 40 32 33 43 35 36 10 38 39 13 41 42 16 44 45 46 47 48 49 50 51 52 53 54]';
F = [1 2 18 4 5 17 7 8 16 10 11 12 13 14 15 46 49 52 21 24 27 20 23 26 19 22 25 3 6 9 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 30 47 48 29 50 51 28 53 54]';
L = [45 44 43 4 5 6 7 8 9 12 15 18 11 14 17 10 13 16 1 2 3 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 48 47 46 19 20 21 49 50 51 52 53 54]';
R = [1 2 3 4 5 6 25 26 27 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 52 53 54 30 33 36 29 32 35 28 31 34 9 8 7 40 41 42 43 44 45 46 47 48 49 50 51 39 38 37]';
B = [34 2 3 35 5 6 36 8 9 7 4 1 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 54 51 48 39 42 45 38 41 44 37 40 43 46 47 10 49 50 11 52 53 12]';
D = [1 2 3 4 5 6 7 8 9 10 11 39 13 14 42 16 17 45 19 20 12 22 23 15 25 26 18 28 29 21 31 32 24 34 35 27 37 38 30 40 41 33 43 44 36 48 51 54 47 50 53 46 49 52]';

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

% 5 incremental steps
s11 = 47;        s12 = [s11; 49]; s13 = [s12; 51]; s14 = [s13; 53];
s21 = [s14; 46]; s22 = [s21; 48]; s23 = [s22; 52]; s24 = [s23; 54];
s31 = [s24; 11]; s32 = [s31; 20]; s33 = [s32; 29]; s34 = [s33; 38];
s4  = [s34; 2; 4; 6; 8];
s51 = [s4; 1];   s52 = [s51; 3];  s53 = [s52; 7];  s54 = [s53; 9];

% 1 algorithm
a1.name = "daisybot";  a1.steps = {s11 s12 s13 s14}; a1.moves = m1;
a2.name = "cornerbot"; a2.steps = {s21 s22 s23 s24}; a2.moves = m2;
a3.name = "middle";    a3.steps = {s31 s32 s33 s34}; a3.moves = m3;
a4.name = "daisytop";  a4.steps = {s4};              a4.moves = m4;
a5.name = "cornertop"; a5.steps = {s51 s52 s53 s54}; a5.moves = m5;

A = [a1 a2 a3 a4 a5];

% 1 test cube
[C P] = scramble(I);

