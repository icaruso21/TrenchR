# TODO: Add comment
# 
# Author: ofir
###############################################################################


alpha_L = 0.965 # thermal absoptivity, Bartlett & Gates 1967
h_L=10.45 #convective heat transfetr ceofficient (W m-2 K-1) (Fei et al. 2012, J Ther Biol, 37: 56-64, Porter et al. 1973?)
epsilon_lizard=0.95 # emissivity of lizard's skin
K_lizard = 0.5 #thermal conductivity (W K-1 m-1)
lambda = 0.02 # lizard mean thikness in meters (diameter)
c_lizard = 3762 #specific heat capacity (J kg-1)
dt =  120 #in seconds
		
####load data
mass = 10.5# lizard mass (grams) 
mass_kg=mass/1000. #in kg
A_L= 0.0314*3.14159*mass_kg^(2./3.) #surface area m2
To = Ta  #initial body temperature in kelvin, assume Ta
#solar radiation
A_p = 0.4*A_L #projected lizard area for direct and scattered solar radiation


calculate_To <- function(TAH, Tsurface, Tair, SWDOWN, GLW, time_step, shade){
	dt =  120 #in seconds
	shade_level = min(round(shade/0.2),5)
	TaV = TAH[time_step]
	Ts = Tsurface[time_step,shade_level] #ground temperature TODO: search in lizard file
	Ta = Tair[time_step,shade_level,1] #air temperature at lizards height 
	Solar = SWDOWN[time_step] # solar radiation 
	lw = GLW[time_step] # solar radiation
	####end of load data			
			
	dQ_solar = shade*alpha_L*A_p*Solar
	
	
	#set projcted lizard area for radiation from the ground
	A_downs=0.0*A_L # zero becuase the lizard in lying on the ground, would be 0.4*A_L if standing
	
	#set projcted lizard area that contacts the ground
	A_contacts = 0.35*A_L # for standing posture, use A_contacts = 0.05*A_L
	
	#net longwave radiation
	A_up = 0.6*A_L # #area of the skin facing toward the sky
	epsilon_ac= 9.2*10^-6*(Ta)^2 # (10.11) clear sky emissivity
	for (i in 10) {
		dQ_IR = epsilon_lizard*A_down*sigma*(Ts^4. - To^4.) + epsilon_lizard*A_up*((1-shade)*lw + shade*sigma*Ta^4.) - epsilon_lizard*A_up*sigma*To^4.
		
		#conduction
		dQ_cond = A_contact*K_lizard*(Ts - To)/(lambda/2)
		
		#convection, assuming no wind
		Aair = 0.9*A_L # skin area that is exposed to air
		dQ_conv=h_L*Aair*(Ta-To)
		
		#Metabolism
		ew = exp(-10.0+0.51*log(mass)+0.115*(To-273)) *3 #Buckley 2008
		dQ_meta = ew/3600. #metabolic rate (j/s)
		
		dQe = (dQ_solar + dQ_IR + dQ_meta + dQ_cond + dQ_conv)
		
		dTe = dQe/((mass_kg)*c_lizard)
		To = To + dTe*dt 
	
	}
	
	To = To - 273
	To
}