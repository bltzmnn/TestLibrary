###########################################################################
#                                                                        
#  File Name��AtmPort.tcl                                                                                              
# 
#  Description��Definition of ATM port class                                             
# 
#  Author�� David.Wu
#
#  Create time:  2007.5.10
#
#  version��1.0 
# 
#  History�� 
# 
##########################################################################

##########################################
#Definition of Atm port class
##########################################  
::itcl::class ATMPort {

   inherit TestPort
    
    constructor {portName chassisName portLocation hProject chassisIp } { TestPort::constructor $portName $chassisName $portLocation $hProject $chassisIp } { 

    }

    destructor {}
}    
