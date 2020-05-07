TITLE Simplified model of Potassium Chloride Co-transporter 2

COMMENT
-----------------------------------------------------------------------------	
	This file models the KCC2 channel mechanism as a distributed process to
	extrude intracellular chloride to baseline levels and increase chloride 
	concentration in the presence of chloride currents.

	A tonic GABA component is included to maintain chloride levels and is
	equal but opposite to the initial extrusion rate of chloride ions.

	The internal chloride ion concentration should be explicitly set in hoc 
	after inserting KCC2 but before running using
	"cli0_KCC2 = x"
	else the default of 5 mM is used.

	With special thanks to Blake Richards and lab 

	Authors: Christopher Brian Currin, Joseph Valentino Raimondo

	References:
	- 
-----------------------------------------------------------------------------
ENDCOMMENT

NEURON {
	THREADSAFE
	SUFFIX KCC2
	USEION cl READ icl, clo, ecl WRITE cli VALENCE -1
	USEION k READ ki, ko VALENCE 1
	RANGE cli0, diff
	RANGE efflux, Pa
	RANGE itonic, gtonic
	GLOBAL celsius
}

UNITS {
	(mV) = (millivolt)
	(um) = (micron)
	(mA) = (milliamp)
	(M)	 = (1/liter)
	(mM) = (milliM)
	F    = (faraday) (coulombs)
	R    = (k-mole) (joule/degC)
	PI   = (pi) (1)				:dimensionless constant
}

PARAMETER {
 	Pa 		= 1.9297e-5		(mA/mM2/cm2)	
 	cli0 	= 5				(mM)		< 0, 20 > 	: initial chloride internal concentration
 	diff	= 2				(um2/ms)	< 0, 5 > 	: chloride diffusion constant
}

ASSIGNED {
	v       	(mV)    	: postsynaptic voltage
	diam		(um)		: compartment diameter
	L 			(um)		: compartment length
	icl 		(mA/cm2)	: chloride current
	ecl 		(mV)		: chloride reversal
	clo     	(mM)    	: external chloride concentration
	ki  		(mM) 		: internal potassium concentration
	ko      	(mM) 	    : external potassium concentration
	efflux		(mA/cm2)	: chloride efflux from KCC2
	itonic  	(mA/cm2) 	: tonic GABA current
	gtonic 		(S/cm2)		: tonic conductance
	celsius   	(degC)   	: temperature
}

STATE { 
	cli 		(mM)		: internal chloride concentration
}

INITIAL {
	cli = cli0

	: initial value of efflux
	flux(cli,clo,ki,ko)

	itonic = efflux
	gtonic = itonic/(v - ecl)
}

BREAKPOINT {
	SOLVE scheme METHOD sparse
}

KINETIC scheme {
	: these statements need to be in the KINETIC block to be calculated at different points of the section
	:tonicgaba(v,ecl)
	flux(cli,clo,ki,ko)
	
	COMPARTMENT 				PI*diam*diam/4 { cli }
	LONGITUDINAL_DIFFUSION diff*PI*diam*diam/4 { cli }		: cross-sectional area of section

	: synaptic chloride current (circumference) - KCC2 efflux (circumference) + tonic GABA current (circumference)
	~ cli << ((1e4)*icl*diam*PI/F - (1e4)*efflux*diam*PI/F)
}  

PROCEDURE flux(Clint (mM), Clout (mM), Kint (mM), Kout (mM)) {
	efflux = Pa*(Kint*Clint-Kout*Clout)
}

PROCEDURE tonicgaba(Vm (mV), Em (mV)) {
  	itonic = gtonic * (Vm - Em)
}
