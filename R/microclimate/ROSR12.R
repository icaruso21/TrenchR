# TODO: Add comment
# 
# Author: ofir
###############################################################################


#copied from Noah-MP model in module_sf_noahmplsm.F from the wrf (v. 3.4) model

#' ROSR12
#'
#' 
#' @details 
#' @param 
#' 
#' @return 
#' @keywords 
#' @export
#' @author Ofir Levy
#' @examples
#' 
ROSR12  = function(P,A,B,C,D,DELTA) {
# ----------------------------------------------------------------------
		# SUBROUTINE ROSR12
# ----------------------------------------------------------------------
# INVERT (SOLVE) THE TRI-DIAGONAL MATRIX PROBLEM SHOWN BELOW:
# ###                                            ### ###  ###   ###  ###
# #B(1), C(1),  0  ,  0  ,  0  ,   . . .  ,    0   # #      #   #      #
# #A(2), B(2), C(2),  0  ,  0  ,   . . .  ,    0   # #      #   #      #
# # 0  , A(3), B(3), C(3),  0  ,   . . .  ,    0   # #      #   # D(3) #
# # 0  ,  0  , A(4), B(4), C(4),   . . .  ,    0   # # P(4) #   # D(4) #
# # 0  ,  0  ,  0  , A(5), B(5),   . . .  ,    0   # # P(5) #   # D(5) #
# # .                                          .   # #  .   # = #   .  #
# # .                                          .   # #  .   #   #   .  #
# # .                                          .   # #  .   #   #   .  #
# # 0  , . . . , 0 , A(M-2), B(M-2), C(M-2),   0   # #P(M-2)#   #D(M-2)#
# # 0  , . . . , 0 ,   0   , A(M-1), B(M-1), C(M-1)# #P(M-1)#   #D(M-1)#
# # 0  , . . . , 0 ,   0   ,   0   ,  A(M) ,  B(M) # # P(M) #   # D(M) #
# ###                                            ### ###  ###   ###  ###
# ----------------------------------------------------------------------

NTOP = 1
# NSOIL,NSNOW
# K, KK

# A, B, D
# C,P,DELTA

# ----------------------------------------------------------------------
		# INITIALIZE EQN COEF C FOR THE LOWEST SOIL LAYER
# ----------------------------------------------------------------------
	C [NSOIL] = 0.0
	P [NTOP] = - C [NTOP] / B [NTOP]
# ----------------------------------------------------------------------
		# SOLVE THE COEFS FOR THE 1ST SOIL LAYER
# ----------------------------------------------------------------------
	DELTA[NTOP] = D[NTOP] / B[NTOP]
# ----------------------------------------------------------------------
		# SOLVE THE COEFS FOR SOIL LAYERS 2 THRU NSOIL
# ----------------------------------------------------------------------
	for (K in (NTOP+1):NSOIL){
		P [K] = - C [K] * ( 1.0 / (B [K] + A [K] * P [K-1]) )
		DELTA [K] = (D [K] - A [K]* DELTA [K-1])* (1.0/ (B [K] + A [K]	* P [K-1]))
	}
# ----------------------------------------------------------------------
		# SET P TO DELTA FOR LOWEST SOIL LAYER
# ----------------------------------------------------------------------
	P [NSOIL] = DELTA [NSOIL]
# ----------------------------------------------------------------------
		# ADJUST P FOR SOIL LAYERS 2 THRU NSOIL
# ----------------------------------------------------------------------
	for (K in (NTOP+1):NSOIL){
		KK = NSOIL - K + (NTOP-1) + 1
		P [KK] = P [KK] * P [KK +1] + DELTA [KK]
	}
	return(P)
}		
