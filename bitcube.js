/*
  01
  32
03322110
74455667
  45
  76

   |0  |1  |2  |3  |4  |5  |6  |7
---+---+---+---+---+---+---+---+---
U  |111|111|111|111|   |   |   |
D  |   |   |   |   |111|111|111|111 
F  |   |   |111|111|111|111|   |
B  |111|111|   |   |   |   |111|111
L  |111|   |   |111|111|   |   |111
R  |   |111|111|   |   |111|111|

00|01|02|03|04|05 06|07|08|09|10|11 12|13|14|15|16|17 18|19|20|21|22|23
*/

m0 = 0b111;
m1 = m0 << 3;
m2 = m0 << 6;
m3 = m0 << 9;
m4 = m0 << 12;
m5 = m0 << 15;
m6 = m0 << 18;
m7 = m0 << 21;

al = m0 | m1 | m2 | m3 | m4 | m5 | m6 | m7;

Um = Dw = m0 | m1 | m2 | m3;
Fm = Bw = m2 | m3 | m4 | m5;
Lm = Rw = m0 | m3 | m4 | m7;

Uw = Dm = ~Um & al;
Fw = Bm = ~Fm & al;
Lw = Rm = ~Lm & al;

// use two integers for position + rotation (3 * 8 = 24 bits for both)
sp = 0b111110101100011010001000;
sr = 0b001001001001001001001001;

p = sp;
r = sr;

cubies = [
	"UBL",
	"URB",
	"UFR",
	"ULF",
	"DFL",
	"DRF",
	"DBR",
	"DLB",
];
colors = {
	U : "white",
	D : "yellow",
	R : "green",
	L : "orange",
	F : "blue",
	B : "red",
};
cube_position = [
              [2,0], [3,0],
              [2,1], [3,1],
[0,2], [1,2], [2,2], [3,2], [4,2], [5,2], [6,2], [7,2],
[0,3], [1,3], [2,3], [3,3], [4,3], [5,3], [6,3], [7,3],
              [2,4], [3,4],
              [2,5], [3,5],
];
positions = [
	[[2,0], [7,2], [0,2]],
	[[3,0], [5,2], [6,2]],
	[[3,1], [3,2], [4,2]],
	[[2,1], [1,2], [2,2]],
	[[2,4], [2,3], [1,3]],
	[[3,4], [4,3], [3,3]],
	[[3,5], [6,3], [5,3]],
	[[2,5], [0,3], [7,3]],
];

canvas = document.getElementById("canvas");
ctx = canvas.getContext("2d");
size = 50;
canvas.width = size * 8;
canvas.height = size * 6;

function draw() {
	var cp, cr;

	for (let i = 0; i < cubies.length; i++) {
		cp = (p >> (i * 3)) & m0;
		cr = (r >> (i * 3)) & m0;
		for (let pos of positions[cp]) {
			ctx.fillStyle = colors[cubies[cp][cr >> 1]];
			ctx.fillRect  (pos[0] * size, pos[1] * size, size, size);
			ctx.strokeRect(pos[0] * size, pos[1] * size, size, size);
			cr = ((cr & 3) << 1) | (cr >> 2);
		}
	}
}

// cycles through cubie rotation
// assumes correct rotation: 1, 2, 4
// 1 -> 2 -> 4 -> 1 -> ...
function rot4l(b) { return ((b & 3) << 1) | (b >> 2); }
// 1 -> 4 -> 2 -> 1 -> ...
function rot4r(b) { return ((b & 1) << 2) | (b >> 1); }

// TODO: implement moves
// what to return?
// just use global vars?
function L() {
}

