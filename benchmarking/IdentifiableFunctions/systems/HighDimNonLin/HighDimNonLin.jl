# HighDimNonLin
#! format: off
using StructuralIdentifiability

system = @ODEmodel(
	x17'(t) = -p17*x17(t) + x16(t)*p16,
	x11'(t) = x10(t)*p10 - x11(t)*p11,
	x2'(t) = -p2*x2(t) + p1*x1(t),
	x9'(t) = -x9(t)*p9 + p8*x8(t),
	x13'(t) = -x13(t)*p13 + p12*x12(t),
	x18'(t) = -p18*x18(t) + p17*x17(t),
	x8'(t) = p7*x7(t) - p8*x8(t),
	x20'(t) = -p20*x20(t) + x19(t)*p19,
	x5'(t) = -p5*x5(t) + x4(t)*p4,
	x6'(t) = -p6*x6(t) + p5*x5(t),
	x4'(t) = x3(t)*p3 - x4(t)*p4,
	x15'(t) = -p15*x15(t) + p14*x14(t),
	x14'(t) = x13(t)*p13 - p14*x14(t),
	x19'(t) = -x19(t)*p19 + p18*x18(t),
	x10'(t) = x9(t)*p9 - x10(t)*p10,
	x16'(t) = p15*x15(t) - x16(t)*p16,
	x7'(t) = -p7*x7(t) + p6*x6(t),
	x1'(t) = (-p1*km*x1(t) - p1*x1(t)^2 + km*u(t) - x1(t)*vm + x1(t)*u(t))//(km + x1(t)),
	x3'(t) = p2*x2(t) - x3(t)*p3,
	x12'(t) = x11(t)*p11 - p12*x12(t),
	y17(t) = x17(t),
	y10(t) = x10(t),
	y15(t) = x15(t),
	y16(t) = x16(t),
	y9(t) = x9(t),
	y20(t) = x20(t),
	y7(t) = x7(t),
	y13(t) = x13(t),
	y4(t) = x4(t),
	y11(t) = x11(t),
	y3(t) = x3(t),
	y19(t) = x19(t),
	y1(t) = x1(t),
	y18(t) = x18(t),
	y8(t) = x8(t),
	y2(t) = x2(t),
	y5(t) = x5(t),
	y12(t) = x12(t),
	y14(t) = x14(t),
	y6(t) = x6(t)
)