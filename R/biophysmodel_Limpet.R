#' Predicts body temperature (operative environmental temperature) of a limpet in °C.
#' @details Predicts body temperature of a limpet in °C.
#' @description Predicts body temperature of a limpet in °C. Based on Denny and Harley 2006. Hot limpets: predicting body temperature in a conductance-mediated thermal system
#' @param T_a air temperature (°C)
#' @param T_r rock temperature (°C)
#' @param L limpet length (anterior/posterior axis) (m)
#' @param H limpet height (dorsal/ventral axis) (m)
#' @param I solar irradiance (W m^-2)
#' @param u wind speed (m/s)
#' @param psi solar zenith angle (degrees): can be calculated from zenith_angle function
#' @param c fraction of the sky covered by cloud 
#' @param position the direction of the limpet that is facing upwind. Options are "anterior", "posterior" and "broadside".
#' @return predicted body temperature (°C)
#' @keywords body temperature, biophysical model
#' @family biophysical models
#' @export
#' @examples
#' \dontrun{
#' Tb_limpet(T_a = 25, T_r = 30, L = 0.0176, H = 0.0122, I = 1300, u = 1, psi = 30, c = 1, position = "anterior")
#' }

Tb_limpet = function(T_a, T_r, L, H, I, u, psi, c, position = "anterior"){
  
  #! add stop if not
  
  psi = psi * pi / 180 # covert to radians
  T_a = T_a + 273.15   # convert to kelvin
  T_r = T_r + 273.15   # convert to kelvin
  r = L / 2            # radius
  
  #______________________________________________________________
  # Short wave heat transfer
  
  # Area of the limpet’s shell (m^2) projected in the direction at which sunlight strikes the organism (Pennell and Deignan 1989)
  Ap = pi * r^2 * cos(psi)
  if (tan(psi) < r / H) {
    Ap = Ap + H * r * sin(psi) - pi * r^2 / 2 * cos(psi)
  }
  
  alpha_sw = 0.68  # Short-wave absorptivity of the shell
  q1 = Ap * alpha_sw * I
  
  
  #_______________________________________________________________
  # Long-wave energy transfer
  
  # View factor. (Campbell and Norman 1998) simulating limpets as a cone.
  Vs = cos(psi) * r / sqrt(r^2 + H^2)
    
  Al = pi * r * sqrt(H^2 + r^2) # lateral area of a limpet shell (m^2)
  eps_ws = 0.97  #  long-wave emissivity of the shell
  sigma = 5.66 * 10^-8   # stefan-boltzmann constant (W m^-2 K^-4)

  eps_ac = 9.2 * 10^-6 * T_a^2 # clear sky emissivity (Campbell and Norman 1998, 10.11)
  eps_wa = (1 - 0.84 * c) * eps_ac + 0.84 * c  # emissivity of air with clouds (same as above, 10.12)

  q2 = Vs * Al * eps_ws * sigma * T_a^4 * (eps_wa - 1)
  q3 = 4 * Vs * Al* eps_ws * sigma * T_a^3
  
  
  #____________________________________________________________
  # Convective heat transfer
  
  Ka = 0.00501 + 7.2 * 10^-5 * T_a       # conductivity of air (W m^-1 K^-1) Denny and Harley. 2006, Hot limpets: predicting body temperature in a conductance-mediated thermal system 
  v = -1.25 * 10^-5 + 9.2 * 10^-8 * T_a  # kinematic viscosity of air (m^2 s^-1)
  
  #! make easier to interpret and match up with papers by estimating Reynold's number first?
  # Heat transfer coefficient (W m^-2 K^-1)
  if (position == "anterior") {
    hc = 1.955 * Ka / L * (u * L / v)^0.371  # anterior upwind
  } else if (position == "posterior") {
    hc = 1.881 * Ka / L * (u * L / v)^0.376  # posterior upwind
  } else {
    hc = 1.304 * Ka / L * (u * L / v)^0.404  # shells broadside to the wind
  }
  A_cv = Al  # area of the shell in convective contact with the air (m^2)
  q4 = hc * A_cv
  
  #______________________________________________________________
  # Conductive heat transfer
  # Original equation uses a finite-difference approach where they divide the rock into series of chunks,
  # and calculate the temperature at each node to derive the conductive heat.
  # For simplification, here it takes the rock temperature as a parameter, and conductive heat is calculated by
  # the product of the area, thermal conductivity of rock and the difference in temperatures of the rock and the body.
  
  A_cd = pi * r^2  # area of conductive contact between the limpet’s foot and the rock (m^2)
  Kr = 3.06        # thermal conductivity of rock (W m^-1 K^-1)
  q5 = A_cd * Kr
  
  # Calculating for body temperature using the coefficients q1 ~ q5.
  T_b = (q1 + q2 + (q3 + q4)* T_a + q5 * T_r) / (q3 + q4 + q5)
  
  return (T_b - 273.15)
}

Tb_limpet(T_a = 25, T_r = 30, L = 0.0176, H = 0.0122, I = 800, u = 1, psi = 30, c = 1, position = "anterior")