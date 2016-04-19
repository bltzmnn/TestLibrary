###########################################################################
#                                                                        
#  File Name��LowRatePort.tcl                                                                                              
# 
#  Description��Definition of STC LowRate port class                                             
# 
#  Auther�� David.Wu
#
#  Create time:  2007.5.10
#
#  version��1.0 
# 
#  History�� 
# 
##########################################################################

##########################################
#Definition of Low Rate port class
##########################################  
::itcl::class LowRatePort {
 
    inherit TestPort
    
    constructor { portName chassisName portLocation hProject chassisIp } { TestPort::constructor $portName $chassisName $portLocation $hProject $chassisIp } { 
        lappend ::mainDefine::gObjectNameList $this
    }

    destructor {
    set index [lsearch $::mainDefine::gObjectNameList $this]
    set ::mainDefine::gObjectNameList [lreplace $::mainDefine::gObjectNameList $index $index ]
    }

}    


