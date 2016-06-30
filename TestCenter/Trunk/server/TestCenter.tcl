#***************************************************************************
#  Copyright (C), 2012-1, SHENZHEN GONGJIN ELECTRONICS. Co., Ltd.
#  ģ�����ƣ�TestCenter
#  ģ�鹦�ܣ��ṩTestCenter�Ļ����ӿڡ��������TestCenter,����������ԣ��շ�����ͳ�ƽ���Ȳ���
#  ����: ATT��Ŀ������
#  �汾: V1.0
#  ����: 2013.02.27
#  �޸ļ�¼��
#      lana   2013-02-27  created
#      lana   2013-09-27   ���STC����Ĵ�ӡ

#***************************************************************************

package require LOG
package provide TestCenter  1.0


namespace eval ::TestCenter {

    set currentFileName TestCenter.tcl

    # ����������Թ����н����Ķ���
    set chassisObject ""
    array set object {}

    set ExpectSuccess 0            ;#��ʾ�ɹ�
    set FunctionExecuteError -1    ;#��ʾ���ú���ʧ��

}


#*******************************************************************************
#Function:   ::TestCenter::ConnectChassis {chassisAddr}
#Description:  ʹ�ø�����chassisAddr����TestCenter
#Calls:  ��
#Data Accessed:   ��
#Data Updated:
#     TestCenter::chassisObject
#Input:
#      chassisAddr     ��ʾ�����ַ����������TestCenter��IP��ַ
#
#Output:   ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg   ��ʾ���ú���ʧ��
#    ����ֵ                                       ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::ConnectChassis {chassisAddr } {

	set log [LOG::init TestCenter_ConnectChassis]
	set errMsg ""

	foreach once {once} {

		# ������chassisAddr�Ƿ�Ϊ�գ����Ϊ�գ����޷�����TestCenter������ʧ��
		if {$chassisAddr == ""} {
			set errMsg "chassisAddrΪ�գ��޷�����TestCenter."
			break
		}

		# ���chassis1�����Ƿ��Ѿ������ˣ�������ڣ�ֱ�ӷ��سɹ�
		if {[string match $::TestCenter::chassisObject "chassis1"] == 1} {
			set errMsg "�Ѿ�������$chassisAddr �ϵ�TestCenter������������."
			return [list $TestCenter::ExpectSuccess $errMsg]
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: TestDevice chassis1 $chassisAddr"

		# ���ô���Ļ����ַ�����ӻ��򣬲�����chassis1����,��������쳣������ʧ��
		if {[catch {set ::TestCenter::chassisObject [TestDevice chassis1 $chassisAddr]} err] == 1} {
			set errMsg "����TestCenter�����쳣��������ϢΪ: $err ."
			break
		}
		# �ж����ɻ������ķ���ֵ�Ƿ���ȷ���������ȷ������ʧ��
		if {[string match $::TestCenter::chassisObject "chassis1"] != 1} {
			set errMsg "���ɻ������ʧ�ܣ�����ֵΪ:$::TestCenter::chassisObject ."
			break
		}

		set errMsg "����$chassisAddr �ϵ�TestCenter�ɹ�."
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:   ::TestCenter::ReservePort {portLocation portName {portType "Ethernet"}}
#Description:  ԤԼ�˿ڣ���ԤԼ�˿�ʱ����Ҫָ���˿ڵ�λ�ã��˿ڵ����ֺͶ˿ڵ�����
#             �����ö˿�������·��Ҫʹ�õ�Э�����ͣ���ȡֵ��ΧΪ��Ethernet,Wan,Atm,LowRate
#Calls:  ��
#Data Accessed:   ��
#Data Updated:
#     TestCenter::object
#Input:
#      portLocation     ��ʾ�˿ڵ�λ�ã��ɰ忨����˿ں���ɣ���'/'���ӡ�����ԤԼ1�Ű忨��1�Ŷ˿ڣ����� "1/1"
#      portName         ָ��ԤԼ�˿ڵı��������ں���Ըö˿ڵ�����������
#      portType         ָ��ԤԼ�Ķ˿����͡�Ĭ��Ϊ"Ethernet"
#
#Output:   ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg   ��ʾ���ú���ʧ��
#    ����ֵ                                       ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::ReservePort {portLocation portName {portType "Ethernet"}} {

	set log [LOG::init TestCenter_ReservePort]
	set errMsg ""

	foreach once {once} {
		# �������portLocation��portNameΪ�գ�����ʧ��
		if {$portLocation == "" || $portName == ""} {
			set errMsg "�˿�λ�úͶ˿�������Ϊ��."
			break
		}

		# �ж��Ƿ��Ѿ��������˻���
		if {$::TestCenter::chassisObject == ""} {
			set errMsg "��δ����TestCenter���򣬲���ԤԼ�˿�."
			break
		}

		# ���˿ڶ������Ƿ��ѱ�ʹ�ù�
		set tmpInfo [array get TestCenter::object $portName]
		if {$tmpInfo != ""} {
			set errMsg "$portName �Ѿ���ʹ�ù���ԤԼ�˿��������ظ�!"
			break
		}

		# �齨���ԤԼ�˿�
		set cmd "$::TestCenter::chassisObject CreateTestPort -PortLocation $portLocation -PortName $portName -PortType $portType"
		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $cmd"
		if {[catch {set res [eval $cmd]} err] == 1} {
			set errMsg "ԤԼ$portLocation �˿ڷ����쳣��������ϢΪ:$err ."
			break
		}
		if {$res == 0} {
			set TestCenter::object($portName) $portName
		} else {
			set errMsg "ԤԼ$portLocation �˿�ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "ԤԼ $portLocation �˿ڳɹ�."
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:   ::TestCenter::ConfigPort {portName args}
#Description:  ����Ethernet�˿ڵ�����
#Calls:  ��
#Data Accessed:   ��
#Data Updated:  ��
#Input:
#      portName     ��ʾҪ���õĶ˿ڵ����֣�����Ķ˿�����ԤԼ�˿�ʱָ��������
#      args         ��ʾҪ���õĶ˿ڵ����Ե��б���{�����ֵ�������ֵ...}���{-options value}��
#        -mediaType   ��ʾ�˿ڽ������ͣ�ȡֵ��ΧΪCOPPER��FIBER��Ĭ��ΪCOPPER
#        -linkSpeed   ��ʾ�˿����ʣ�ȡֵ��ΧΪ10M,100M,1G,10G,AUTO��Ĭ��ΪAUTO
#        -duplexMode  ��ʾ�˿ڵ�˫��ģʽ��ȡֵ��ΧΪFULL��HALF��Ĭ��ΪFULL
#        -autoNeg     ��ʾ�˿ڵ�Э��ģʽ��ȡֵ��ΧΪEnable��Disable��Ĭ��ΪEnable
#        -flowControl ��ʾ�Ƿ����˿ڵ����ع��ܣ�ȡֵ��ΧΪON��OFF��Ĭ��ΪOFF
#        -mtuSize     ��ʾ�˿ڵ�MTU��Ĭ��Ϊ1500
#        -autoNegotiationMasterSlave ��ʾ��Э��ģʽ��ȡֵ��ΧΪMASTER,SLAVE��Ĭ��ΪMASTER
#        -portMode    �����10G,ȡֵ��ΧΪLAN��WAN��Ĭ��ΪLAN
#
#Output:   ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg   ��ʾ���ú���ʧ��
#    ����ֵ                                       ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::ConfigPort {portName args} {

	set log [LOG::init TestCenter_ConfigPort]
	set errMsg ""

	foreach once {once} {
		# ������portNameָ���Ķ˿ڶ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $portName]
		if {$tmpInfo == ""} {
			set errMsg "$portName�����ڣ��޷����ö˿�."
			break
		}

		# ���ö˿ڵ�����
		set tmpCmd "$portName ConfigPort"
		if {$args != ""} {
			for {set i 0} {$i<10} {incr i} {
				if {[llength $args] == 1} {
					set args [lindex $args 0]
				} else {
					break
				}
			}

			foreach {option value} $args {
				lappend tmpCmd $option $value
			}
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "���ö˿�$portName �����쳣��������ϢΪ:$err ."
			break
		}

		if {$res != 0} {
			set errMsg "���ö˿�$portName ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "���ö˿�$portName �ɹ�"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:   ::TestCenter::GetPortState {portName portStates}
#Description:  ��ȡEthernet�˿ڵ�״̬��Ϣ�������˿ڵ�����״̬����·״̬����·���ʣ���·˫��״̬
#Calls:  ��
#Data Accessed:   ��
#Data Updated:  ��
#Input:
#      portName     ��ʾҪ��ȡ״̬�Ķ˿ڵ����֣�����Ķ˿�����ԤԼ�˿�ʱָ��������
#
#Output:
#      portStates    ��ʾ�˿ڵ�״̬�б���ʽΪ{{-option value} {-option value} ...}
#Return:
#    list $TestCenter::ExpectSuccess  $msg              ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg        ��ʾ���ú���ʧ��
#    ����ֵ                                            ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::GetPortState {portName portStates} {

	set log [LOG::init TestCenter_GetPortState]
	upvar 1 $portStates tmpPortStates
	set tmpPortStates ""
	set errMsg ""

	foreach once {once} {
		# ������portNameָ���Ķ˿ڶ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $portName]
		if {$tmpInfo == ""} {
			set errMsg "$portName�����ڣ��޷���ȡ�˿���Ϣ."
			break
		}

		# ��ȡ�˿ڵ�����
		set tmpCmd "$portName GetPortState"
		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "��ȡ�˿�$portName ���Է����쳣��������ϢΪ:$err ."
			break
		}

		for {set i 0} {$i < [llength $res]} {incr i} {
			lappend tmpPortStates [lindex $res $i]
		}

		set errMsg "��ȡ�˿�$portName ���Գɹ�"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::SetupVlan {portName vlanName args}
#Description:   ��ָ���˿ڴ���vlan��������vlan������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName   ��ʾ��Ҫ����vlan�ӽӿڵĶ˿���
#    vlanName   ��ʾ��Ҫ������vlan�ӽӿڵ�����
#    args       ��ʾ��Ҫ������vlan�ӽӿڵ������б����ʽΪ{-option value}.vlan�������У�
#       -VlanType     ָ��Vlan���ͣ�Ĭ��Ϊ��0x8100����ʾ��̫��
#       -VlanId       ָ�� VlanId ֵ��Ĭ��Ϊ100
#       -VlanPriority ָ���ӽӿڵ����ȼ�ȡֵ��Ĭ��Ϊ0
#       -QinQList     ָ�� QinQ ģʽ�£����� Vlan�� VlanId �Լ� Priority ֵ��QinQList�е�Ԫ����һ����tpid vlanid priority����Ԫ����ɡ�
#    ע�⣬ǰ�������������һ�����Բ���ͬʱʹ��
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::SetupVlan {portName vlanName args} {

	set log [LOG::init TestCenter_SetupVlan]
	set errMsg ""

	foreach once {once} {
		# ������portNameָ���Ķ˿ڶ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $portName]
		if {$tmpInfo == ""} {
			set errMsg "$portName�����ڣ��޷�����Vlan�ӽӿ�."
			break
		}

		# ������vlanName�Ƿ�Ϊ��
		if {$vlanName == ""} {
			set errMsg "vlanNameΪ�գ��޷�����Vlan�ӽӿ�."
			break
		}

		# ����vlan�ӽӿ�
		set tmpCmd "$portName CreateSubInt -SubIntName $vlanName"
		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "����$vlanName �ӽӿڷ����쳣, ������ϢΪ:$err ."
			break
		}
		# ��������ɹ��������ӽӿھ��
		if {$res == 0} {
			set TestCenter::object($vlanName) $vlanName
		} else {
			set errMsg "����$vlanName �ӽӿ�ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		# ����Vlan�ӽӿڵ�����
		set tmpCmd "$vlanName ConfigPort"
		if {$args != ""} {
			for {set i 0} {$i<10} {incr i} {
				if {[llength $args] == 1} {
					set args [lindex $args 0]
				} else {
					break
				}
			}
			foreach {option value} $args {
				lappend tmpCmd $option $value
			}
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "����$vlanName �ӽӿ����Է����쳣, ������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "����$vlanName �ӽӿ�����ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "��$portName �˿ڴ���$vlanName �ӽӿڲ������������Գɹ�"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::SetupHost {portName hostName args}
#Description:   ��ָ���˿ڴ���Host��������host������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName   ��ʾ��Ҫ����host�Ķ˿������ӽӿ���
#    hostName   ��ʾ��Ҫ������host�����֡����������ں���Ը�host����������
#    args       ��ʾ��Ҫ������host�������б����ʽΪ{-option value}.host�������У�
#       -IpVersion       ָ��IP�İ汾,������ipv4/ipv6��Ĭ��Ϊipv4
#       -HostType        ָ�����������ͣ�������normal/IgmpHost/MldHost��Ĭ��Ϊnormal
#       -Ipv4Addr        ָ������ipv4��ַ��Ĭ��Ϊ192.168.1.2
#       -Ipv4AddrGateway ָ������ipv4���أ�Ĭ��Ϊ192.168.1.1
#       -Ipv4StepMask    ָ������ipv4�����룬Ĭ��Ϊ0.0.0.255
#       -Ipv4Mask        ��ʾHost IPv4��ַPrefix����
#       -Ipv6Addr        ָ������ipv6��ַ��Ĭ��Ϊ 2000:201::1:2
#       -Ipv6StepMask    ָ������ipv6�����룬Ĭ��Ϊ0000::FFFF:FFFF:FFFF:FFFF
#       -Ipv6LinkLocalAddr ��ʾHost��ʼIPv6 Link Local��ַ��Ĭ��Ϊfe80::
#       -Ipv6AddrGateway  ָ������ipv6���أ�Ĭ��Ϊ2000:201::1:1
#       -Ipv6Mask         ָ������ipv6���أ�Ĭ��Ϊ64
#       -MacAddr          ָ��Host��ʼMAC��ַ��Ĭ���ڲ��Զ����ɣ����ε���00:20:94:SlotId:PortId:seq
#       -MacStepMask      ָ��Host��ʼMAC�������ַ��Ĭ��Ϊ00:00:FF:FF:FF:FF
#       -MacCount         ָ��Mac��ַ�仯��������Ĭ��Ϊ1
#       -MacIncrease      ָ��Mac��ַ�����Ĳ�����Ĭ��Ϊ1
#       -Count            ָ��Host IP��ַ������Ĭ��Ϊ1
#       -Increase         ָ��IP��ַ������Ĭ��Ϊ1, ȡֵ��ΧΪ2����
#       -FlagPing         ָ���Ƿ�֧��Ping���ܣ�enable/disable��Ĭ��Ϊenable
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::SetupHost {portName hostName args} {

	set log [LOG::init TestCenter_SetupHost]
	set errMsg ""

	foreach once {once} {
		# ������portNameָ���Ķ˿ڶ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $portName]
		if {$tmpInfo == ""} {
			set errMsg "$portName�����ڣ��޷�����Host����."
			break
		}

		# ������hostName�Ƿ�Ϊ��
		if {$hostName == ""} {
			set errMsg "hostNameΪ�գ��޷�����Host����."
			break
		}

		# ����Host���󣬲�������������
		set tmpCmd "$portName CreateHost -HostName $hostName"

		if {$args != ""} {
			for {set i 0} {$i<10} {incr i} {
				if {[llength $args] == 1} {
					set args [lindex $args 0]
				} else {
					break
				}
			}
			foreach {option value} $args {
				lappend tmpCmd $option $value
			}
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "����$hostName �����쳣, ������ϢΪ:$err ."
			break
		}
		if {$res == 0} {
			set TestCenter::object($hostName) $hostName
		} else {
			set errMsg "����$hostName ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "�ڶ˿�$portName ����$hostName �ɹ�"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::SetupDHCPServer {routerName args}
#Description:   ����DHCP Server
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName     ��ʾҪ���õ�DHCP Server��������
#    args          ��ʾDHCP Server�������б�,��ʽΪ{-option value}.���������������£�
#    DHCPServer:
#       -PoolName     �������ڴ���������Ŀ�ĵ�ַ��Դ��ַ���Ǳ����������Ӧ�ĵ�ַ�仯��������湦�ܶ�Ӧ�ĸ���εķ�װ��
#                     ע�⣺PoolName��routerName��Ҫ��ͬ��Ĭ��Ϊ�ա�
#       -LocalMac     ��ʾserver�ӿ�MAC��Ĭ��Ϊ00:00:00:11:01:01
#       -TesterIpAddr ��ʾserver�ӿ�IP��Ĭ��Ϊ192.0.0.2
#       -PoolStart    ��ʾ��ַ�ؿ�ʼ��IP��ַ��Ĭ��Ϊ192.0.0.1
#       -PoolNum      ��ʾ��ַ�ص�������Ĭ��Ϊ254
#       -PoolModifier ��ʾ��ַ���б仯�Ĳ�����������IP��ַ�����һλ�������ӣ�Ĭ��Ϊ1
#       -FlagGateway  ��ʾ�Ƿ���������IP��ַ��Ĭ��ΪFALSE
#       -Ipv4Gateway  ��ʾ����IP��ַ��Ĭ��Ϊ192.0.0.1
#       -Active       ��ʾDHCP server�Ự�Ƿ񼤻Ĭ��ΪTRUE
#       -LeaseTime    ��ʾ��Լʱ�䣬��λΪ�롣Ĭ��Ϊ3600
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::SetupDHCPServer {routerName args} {

	set log [LOG::init TestCenter_SetupDHCPServer]
	set errMsg ""

	foreach once {once} {
		# ������routerNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $routerName]
		if {$tmpInfo == ""} {
			set errMsg "$routerName�����ڣ��޷�����DHCP Server."
			break
		}

		# �齨����
		if {$args != ""} {
			set tmpCmd  "$routerName SetSession"
			for {set i 0} {$i<10} {incr i} {
				if {[llength $args] == 1} {
					set args [lindex $args 0]
				} else {
					break
				}
			}
			foreach {option value} $args {
				lappend tmpCmd $option $value
			}

			LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
			# ִ������
			if {[catch {set res [eval $tmpCmd]} err] == 1} {
				set errMsg "����DHCP Server�����쳣��������ϢΪ:$err ."
				break
			}
			if {$res != 0} {
				set errMsg "����DHCP Serverʧ�ܣ�����ֵΪ:$res ."
				break
			}
		} else {
			set errMsg "δ����DHCP Server���κ����ԣ��޷�����DHCP Server"
			break
		}

		set errMsg "����DHCP Server�ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::EnableDHCPServer {routerName}
#Description:   ����DHCP Server����ʼЭ�����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName   ��ʾҪ��ʼЭ������DHCP Server����
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::EnableDHCPServer {routerName } {

    set log [LOG::init EnableDHCPServer]
	set errMsg ""

    foreach once {once} {
		# ������routerNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $routerName]
		if {$tmpInfo == ""} {
			set errMsg "$routerName�����ڣ��޷���ʼЭ�����."
			break
		}

		# �齨����
		set tmpCmd  "$routerName Enable"

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		# ִ������
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "$routerName ����DHCP ServerЭ����淢���쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "$routerName ����DHCP ServerЭ����淢���쳣������ֵΪ:$res ."
			break
		}

		set errMsg "����DHCP ServerЭ�����ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
}


#*******************************************************************************
#Function:    ::TestCenter::DisableDHCPServer {routerName}
#Description:   �ر�DHCP Server��ֹͣЭ�����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName   ��ʾҪֹͣЭ������DHCP Server����
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#******************************************************************************
proc ::TestCenter::DisableDHCPServer {routerName } {

    set log [LOG::init DisableDHCPServer]
	set errMsg ""

    foreach once {once} {
		# ������routerNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $routerName]
		if {$tmpInfo == ""} {
			set errMsg "$routerName�����ڣ��޷��ر�Э�����."
			break
		}

		# �齨����
		set tmpCmd  "$routerName Disable"

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		# ִ������
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "$routerName �ر�DHCP ServerЭ����淢���쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "$routerName �ر�DHCP ServerЭ����淢���쳣������ֵΪ:$res ."
			break
		}

		set errMsg "�ر�DHCP ServerЭ�����ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
}


#*******************************************************************************
#Function:    ::TestCenter::SetupDHCPClient {routerName args}
#Description:   ����DHCP Client
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName     ��ʾҪ���õ�DHCP Client��������
#    args           ��ʾDHCP Client�������б�,��ʽΪ{-option value}.���������������£�
#    DHCPClient:
#       -PoolName        �������ڴ���������Ŀ�ĵ�ַ��Դ��ַ���Ǳ����������Ӧ�ĵ�ַ�仯��������湦�ܶ�Ӧ�ĸ���εķ�װ��
#                        ע�⣺PoolName��routerName��Ҫ��ͬ��Ĭ��Ϊ�ա�
#       -LocalMac        ��ʾClient�ӿ�MAC��Ĭ��Ϊ00:00:00:11:01:01
#       -Count           ��ʾģ�������������Ĭ��Ϊ1
#       -AutoRetryNum    ��ʾ����Խ������ӵĴ�����Ĭ��Ϊ1
#       -FlagGateway     ��ʾ�Ƿ���������IP��ַ��Ĭ��ΪFALSE
#       -Ipv4Gateway     ��ʾ����IP��ַ��Ĭ��Ϊ��
#       -Active          ��ʾDHCP server�Ự�Ƿ񼤻Ĭ��ΪTRUE
#       -FlagBroadcast   ��ʾ�㲥��ʶλ���㲥ΪTRUE������ΪFALSE��Ĭ��ΪTRUE
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::SetupDHCPClient {routerName args} {

    set log [LOG::init TestCenter_SetupDHCPClient]
	set errMsg ""

    foreach once {once} {
        # ������routerNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $routerName]
		if {$tmpInfo == ""} {
			set errMsg "$routerName�����ڣ��޷���ʼЭ�����."
			break
		}

        # �齨����
		if {$args != ""} {
			set tmpCmd  "$routerName SetSession"
			for {set i 0} {$i<10} {incr i} {
				if {[llength $args] == 1} {
					set args [lindex $args 0]
				} else {
					break
				}
			}
			foreach {option value} $args {
				lappend tmpCmd $option $value
			}

            LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
			# ִ������
			if {[catch {set res [eval $tmpCmd]} err] == 1} {
				set errMsg "����DHCP Client�����쳣��������ϢΪ:$err ."
				break
			}
			if {$res != 0} {
				set errMsg "����DHCP Clientʧ�ܣ�����ֵΪ:$res ."
				break
			}
		} else {
			set errMsg "δ����DHCP Client���κ����ԣ��޷�����DHCP Client"
			break
		}

        set errMsg "����DHCP Client�ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
    }
    LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::EnableDHCPClient {routerName}
#Description:   ʹ��DHCP Client
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName   ��ʾҪʹ�ܵ�DHCP Client����
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::EnableDHCPClient {routerName } {

    set log [LOG::init EnableDHCPClient]
	set errMsg ""

    foreach once {once} {
		# ������routerNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $routerName]
		if {$tmpInfo == ""} {
			set errMsg "$routerName�����ڣ��޷���ʼЭ�����."
			break
		}

		# �齨����
		set tmpCmd  "$routerName Enable"

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		# ִ������
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "$routerName ����DHCP ClientЭ����淢���쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "$routerName ����DHCP ClientЭ����淢���쳣������ֵΪ:$res ."
			break
		}

		set errMsg "����DHCP ClientЭ�����ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
}


#*******************************************************************************
#Function:    ::TestCenter::DisableDHCPClient {routerName}
#Description:   ֹͣDHCP Client
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName   ��ʾҪֹͣ��DHCP Client����
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#******************************************************************************
proc ::TestCenter::DisableDHCPClient {routerName } {

    set log [LOG::init DisableDHCPClient]
	set errMsg ""

    foreach once {once} {
		# ������routerNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $routerName]
		if {$tmpInfo == ""} {
			set errMsg "$routerName�����ڣ��޷��ر�Э�����."
			break
		}

		# �齨����
		set tmpCmd  "$routerName Disable"

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		# ִ������
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "$routerName �ر�DHCP ClientЭ����淢���쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "$routerName �ر�DHCP ClientЭ����淢���쳣������ֵΪ:$res ."
			break
		}

		set errMsg "�ر�DHCP ClientЭ�����ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
}


#*******************************************************************************
#Function:    ::TestCenter::MethodDHCPClient {routerName method}
#Description:   DHCP ClientЭ�����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName   ��ʾ������DHCP client������
#    method:      ��ʾDHCP client����ķ�����
#        Bind:       ����DHCP �󶨹���
#        Release:    �ͷŰ󶨹���
#        Renew:      ��������DHCP �󶨹���
#        Abort:      ֹͣ����active Session��dhcp router����ʹ��״̬����idle
#        Reboot:     ��ʹdhcp router����reboot�������һ�������Ĺ��̣����¿�ʼ�µ�һ��ѭ����
#                    RebootӦ�÷���������ǰ�����IP��ַ��
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::MethodDHCPClient {routerName method} {

    set log [LOG::init MethodDHCPClient]
	set errMsg ""

    foreach once {once} {
		# ������routerNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $routerName]
		if {$tmpInfo == ""} {
			set errMsg "$routerName�����ڣ��޷�����Э�����."
			break
		}
        # ������method����Ķ����Ƿ���ȷ���������ȷ������ʧ��
        set method_list [list Bind Release Renew Abort Reboot]
        set index [lsearch -nocase $method_list $method]
        if {$index == -1} {
            set errMsg "$method ��������������."
            break
        }

		# �齨����
		set tmpCmd  "$routerName $method"

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		# ִ������
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "$routerName ����DHCP ClientЭ����淢���쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "$routerName ����DHCP ClientЭ����淢���쳣������ֵΪ:$res ."
			break
		}

		set errMsg "DHCP Client $mehtod Э�����ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
}



#*******************************************************************************
#Function:    ::TestCenter::SetupIGMPHost {hostName args}
#Description:   ����IGMP Host����MLD Host
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    hostName      ��ʾҪ���õ�IGMP������
#    args          ��ʾIGMP/MLD host�������б�,��ʽΪ{-option value}.���������������£�
#    IGMPHost:
#       -SrcMac             ��ʾԴMAC���������hostʱ��Ĭ��ֵ������1��Ĭ��Ϊ00:10:94:00:00:02
#       -SrcMacStep         ��ʾԴMAC�ı仯������������MAC��ַ�����һλ�������ӣ�Ĭ��Ϊ1
#       -Ipv4Addr           ��ʾHost��ʼIPv4��ַ��Ĭ��Ϊ192.85.1.3
#       -Ipv4AddrGateway    ��ʾGateWay��IPv4��ַ��Ĭ��Ϊ192.85.1.1
#       -Ipv4AddrPrefixLen  ��ʾHost IPv4��ַPrefix���ȣ�Ĭ��Ϊ24
#       -Count              ��ʾHost IP��MAC��ַ������Ĭ��Ϊ1
#       -Increase           ��ʾIP��ַ������Ĭ��Ϊ1
#       -ProtocolType       ��ʾProtocol�����͡��Ϸ�ֵ��IGMPv1/IGMPv2/IGMPv3��Ĭ��ΪIGMPv2
#       -SendGroupRate      ָ��Igmp Host�����鲥Э�鱨��ʱ�����ͱ��ĵ����ʣ���λfpsĬ��Ϊ����
#       -Active             ��ʾIGMP Host�Ự�Ƿ񼤻Ĭ��ΪTRUE
#       -V1RouterPresentTimeout ָ��Igmp Host�յ�query�뷢��report���ĵ�ʱ������Ĭ��Ϊ400
#       -ForceRobustJoin        ָ������һ��Igmpv1/v2 host����groupʱ���Ƿ���������2����Ĭ��ΪFALSE
#       -ForceLeave             ָ���������һ��֮���Igmpv2 Host��group���뿪ʱ���Ƿ���leave���ģ�Ĭ��ΪFALSE
#       -UnsolicitedReportInterval ָ��Igmp host����unsolicited report��ʱ������Ĭ��Ϊ10
#       -InsertCheckSumErrors      ָ���Ƿ���Igmp Host���͵ı����в���Checksum error��Ĭ��ΪFALSE
#       -InsertLengthErrors        ָ���Ƿ���Igmp Host���͵ı����в���Length error��Ĭ��ΪFALSE
#       -Ipv4DontFragment          ָ�������ĳ��ȴ���MTU���Ƿ���Ҫ��Ƭ��Ĭ��ΪFALSE
#   MLDHost
#       -SrcMac             ��ʾԴMAC���������hostʱ��Ĭ��ֵ������1��Ĭ��Ϊ00:10:94:00:00:02
#       -SrcMacStep         ��ʾԴMAC�ı仯������������MAC��ַ�����һλ�������ӣ�Ĭ��Ϊ1
#       -Ipv6Addr           ��ʾHost��ʼIPv6��ַ��Ĭ��Ϊ2000::2
#       -Ipv6AddrGateway    ��ʾGateWay��IPv6��ַ
#       -Ipv6AddrPrefixLen  ��ʾHost IPv6��ַPrefix���ȣ�Ĭ��Ϊ64
#       -Count              ��ʾHost IP��MAC��ַ������Ĭ��Ϊ1
#       -Increase           ��ʾIP��ַ������Ĭ��Ϊ1
#       -ProtocolType       ��ʾProtocol�����͡��Ϸ�ֵ��MLDv1/MLDv2��Ĭ��ΪMLDv1
#       -SendGroupRate      ָ��MLD Host�����鲥Э�鱨��ʱ�����ͱ��ĵ����ʣ���λfps��Ĭ��Ϊ0
#       -Active             ��ʾMLD Host�Ự�Ƿ񼤻�,ȡֵ��Χ��TRUE/FALSE��Ĭ��ΪTRUE
#       -ForceLeave         ָ���������һ��֮���MLD Host��group���뿪ʱ���Ƿ���leave����,ȡֵ��Χ��TRUE/FALSE��Ĭ��ΪFALSE
#       -ForceRobustJoin    ָ������һ��MLD host����groupʱ���Ƿ��������ͣ�ȡֵ��Χ��TRUE/FALSE��Ĭ��ΪFALSE
#       -UnsolicitedReportInterval  ָ��MLD host����unsolicited report��ʱ������Ĭ��Ϊ10
#       -InsertCheckSumErrors       ָ���Ƿ���MLD Host���͵ı����в���Checksum error��ȡֵ��Χ��TRUE/FALSE��Ĭ��ΪFALSE
#       -InsertLengthErrors         ָ���Ƿ���Mld Host���͵ı����в���Length error��ȡֵ��Χ��TRUE/FALSE��Ĭ��ΪFALSE
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::SetupIGMPHost {hostName args} {

	set log [LOG::init TestCenter_SetupIGMPHost]
	set errMsg ""

	foreach once {once} {
		# ������hostNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $hostName]
		if {$tmpInfo == ""} {
			set errMsg "$hostName�����ڣ��޷�����IGMP/MLD host."
			break
		}

		# �齨����
		if {$args != ""} {
			set tmpCmd  "$hostName SetSession"
			for {set i 0} {$i<10} {incr i} {
				if {[llength $args] == 1} {
					set args [lindex $args 0]
				} else {
					break
				}
			}
			foreach {option value} $args {
				lappend tmpCmd $option $value
			}

			LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
			# ִ������
			if {[catch {set res [eval $tmpCmd]} err] == 1} {
				set errMsg "����IGMP/MLD host�����쳣��������ϢΪ:$err ."
				break
			}
			if {$res != 0} {
				set errMsg "����IGMP/MLD hostʧ�ܣ�����ֵΪ:$res ."
				break
			}
		} else {
			set errMsg "δ����IGMP/MLD host���κ����ԣ��޷�����IGMP host"
			break
		}

		set errMsg "����IGMP/MLD host�ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::SetupIGMPGroupPool {hostName groupPoolName startIP args}
#Description:   ����������IGMP/MLD GroupPool
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    hostName      ��ʾҪ����������IGMP/MLD GroupPool��������
#    groupPoolName ��ʾIGMP/MLD Group�����Ʊ�ʶ��Ҫ���ڵ�ǰ IGMP/MLD Host Ψһ
#    startIP       ��ʾGroup ��ʼ IP ��ַ��ȡֵԼ����String��IPv4�ĵ�ֵַ(IGMP),��IPV6�ĵ�ֵַ��MLD��
#    args          ��ʾIGMP Group pool�������б�,��ʽΪ{-option value}.���������������£�
#      IGMP GroupPool:
#       -PrefixLen       ��ʾIP ��ַǰ׺���ȣ�ȡֵ��Χ��5��32��Ĭ��Ϊ24
#       -GroupCnt        ��ʾGroup ������ȡֵԼ����32λ��������Ĭ��Ϊ1
#       -GroupIncrement  ��ʾGroup IP ��ַ��������ȡֵ��Χ��32Ϊ��������Ĭ��Ϊ1
#       -FilterMode       Specific Source Filter Mode(IGMPv3), ȡֵ��ΧΪInclude Exclude��Ĭ��ΪExclude
#       -SrcStartIP       ��ʾ��ʼ���� IP ��ַ��IGMPv3����ȡֵԼ����String��Ĭ��Ϊ192.168.1.2
#       -SrcCnt           ��ʾ������ַ������IGMPv3����ȡֵ��Χ��32λ������Ĭ��Ϊ1
#       -SrcIncrement     ��ʾ���� IP ��ַ������IGMPv3����ȡֵ��Χ��32λ������Ĭ��Ϊ1
#       -SrcPrefixLen     ��ʾ���� IP ��ַǰ׺���ȣ�IGMPv3����ȡֵ��Χ��1��32��Ĭ��Ϊ24
#
#      MLD GroupPool
#       -PrefixLen       ��ʾIP ��ַǰ׺���ȣ�ȡֵ��Χ��9��128��Ĭ��Ϊ64
#       -GroupCnt        ��ʾGroup ������ȡֵԼ����32λ��������Ĭ��Ϊ1
#       -GroupIncrement  ��ʾGroup IP ��ַ��������ȡֵ��Χ��32Ϊ��������Ĭ��Ϊ1
#       -FilterMode       Specific Source Filter Mode(IGMPv3), ȡֵ��ΧΪInclude Exclude��Ĭ��ΪExclude
#       -SrcStartIP       ��ʼ����IP��ַ��MLDv2����ȡֵ��Χ��String ipv6��ʽ��ֵַ��Ĭ��Ϊ2000::3
#       -SrcCnt           ��ʾ������ַ������MLDv2����ȡֵ��Χ��32λ������Ĭ��Ϊ1
#       -SrcIncrement     ��ʾ���� IP ��ַ������MLDv2����ȡֵ��Χ��32λ������Ĭ��Ϊ1
#       -SrcPrefixLen     ��ʾ���� IP ��ַǰ׺���ȣ�MLDv2����ȡֵ��Χ��1��128��Ĭ��Ϊ64
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::SetupIGMPGroupPool {hostName groupPoolName startIP args} {

	set log [LOG::init TestCenter_SetupIGMPHost]
	set errMsg ""

	foreach once {once} {
		# ������hostNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $hostName]
		if {$tmpInfo == ""} {
			set errMsg "$hostName�����ڣ��޷�����IGMP/MLD host."
			break
		}

		# �齨����
		# ���groupPoolName�Ƿ��Ѿ����ڣ��������������������ã������½�
		set tmpInfo [array get TestCenter::object $groupPoolName]
		if {$tmpInfo == ""} {
			set tmpCmd "$hostName CreateGroupPool -GroupPoolName $groupPoolName -StartIP $startIP"
		} else {
			set tmpCmd "$hostName SetGroupPool -GroupPoolName $groupPoolName -StartIP $startIP"
		}

		if {$args != ""} {
			for {set i 0} {$i<10} {incr i} {
				if {[llength $args] == 1} {
					set args [lindex $args 0]
				} else {
					break
				}
			}
			foreach {option value} $args {
				lappend tmpCmd $option $value
			}

			LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
			# ִ������
			if {[catch {set res [eval $tmpCmd]} err] == 1} {
				set errMsg "����������IGMP/MLD GroupPool�����쳣��������ϢΪ:$err ."
				break
			}
			if {$res != 0} {
				set errMsg "����������IGMP/MLD GroupPoolʧ�ܣ�����ֵΪ:$res ."
				break
			}
		}

		set errMsg "����������IGMP/MLD GroupPool�ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::SendIGMPLeave {hostName {groupPoolList ""}}
#Description:   ��groupPoolListָ�����鲥�鷢��IGMP/MLD leave���鲥�뿪������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    hostName      ��ʾҪ���ͱ��ĵ�������
#    groupPoolList ��ʾIGMP/MLD Group �����Ʊ�ʶ�б�,��ָ����ʾ�������group
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::SendIGMPLeave {hostName {groupPoolList ""}} {

	set log [LOG::init TestCenter_SendIGMPLeave]
	set errMsg ""

	foreach once {once} {
		# ������hostNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $hostName]
		if {$tmpInfo == ""} {
			set errMsg "$hostName�����ڣ��޷�����IGMP/MLD leave����."
			break
		}

		# �齨����
		if {$groupPoolList == ""} {
			set tmpCmd "$hostName SendLeave"
		} else {
			for {set i 0} {$i<10} {incr i} {
				if {[llength $groupPoolList] == 1} {
					set groupPoolList [lindex $groupPoolList 0]
				} else {
					break
				}
			}
			set tmpCmd "$hostName SendLeave -GroupPoolList $groupPoolList"
		}

		if {$groupPoolList == ""} {
			set groupPoolList "���е��鲥��"
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "$hostName ��$groupPoolList ����IGMP/MLD Leave���ķ����쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "$hostName ��$groupPoolList ����IGMP/MLD Leave����ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "$hostName ��$groupPoolList ����IGMP/MLD Leave���ĳɹ���"

		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::SendIGMPReport {hostName {groupPoolList ""}}
#Description:   ��groupPoolListָ�����鲥�鷢��IGMP/MLD Join(�鲥����)����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    hostName      ��ʾҪ���ͱ��ĵ�������
#    groupPoolList ��ʾIGMP/MLD Group �����Ʊ�ʶ�б�,��ָ����ʾ�������group
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::SendIGMPReport {hostName {groupPoolList ""}} {

	set log [LOG::init TestCenter_SendIGMPReport]
	set errMsg ""

	foreach once {once} {
		# ������hostNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $hostName]
		if {$tmpInfo == ""} {
			set errMsg "$hostName�����ڣ��޷�����IGMP/MLD Join����."
			break
		}

		# �齨����
		if {$groupPoolList == ""} {
			set tmpCmd "$hostName SendReport"
		} else {
			for {set i 0} {$i<10} {incr i} {
				if {[llength $groupPoolList] == 1} {
					set groupPoolList [lindex $groupPoolList 0]
				} else {
					break
				}
			}
			set tmpCmd "$hostName SendReport -GroupPoolList $groupPoolList"
		}

		if {$groupPoolList == ""} {
			set groupPoolList "���е��鲥��"
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "$hostName ��$groupPoolList ����IGMP/MLD Join���ķ����쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "$hostName ��$groupPoolList ����IGMP/MLD Join����ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "$hostName ��$groupPoolList ����IGMP/MLD Join���ĳɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::SetupMLDHost {hostName args}
#Description:   ����MLD Host
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    hostName      ��ʾҪ���õ�MLD������
#    args          ��ʾMLD host�������б�,��ʽΪ{-option value}.���������������£�
#       -SrcMac    ��ʾԴMAC���������hostʱ��Ĭ��ֵ������1��Ĭ��Ϊ00:10:94:00:00:02
#       -SrcMacStep ��ʾԴMAC�ı仯������������MAC��ַ�����һλ�������ӣ�Ĭ��Ϊ1
#       -Ipv6Addr   ��ʾHost��ʼIPv6��ַ��Ĭ��Ϊ2000::2
#       -Ipv6AddrGateway  ��ʾGateWay��IPv6��ַ��Ĭ��Ϊ2000::1
#       -Ipv6AddrPrefixLen  ��ʾHost IPv6��ַPrefix���ȣ�Ĭ��Ϊ64
#       -Count              ��ʾHost IP��MAC��ַ������Ĭ��Ϊ1
#       -Increase           ��ʾIP��ַ������Ĭ��Ϊ1
#       -ProtocolType       ��ʾProtocol�����͡��Ϸ�ֵ��MLDv1/MLDv2��Ĭ��ΪMLDv1
#       -SendGroupRate      ָ��MLD Host�����鲥Э�鱨��ʱ�����ͱ��ĵ����ʣ���λfpsĬ��Ϊ����
#       -Active             ��ʾMLD Host�Ự�Ƿ񼤻Ĭ��ΪTRUE
#       -ForceRobustJoin        ָ������һ��MLD host����groupʱ���Ƿ���������2����Ĭ��ΪFALSE
#       -ForceLeave             ָ���������һ��֮���MLD Host��group���뿪ʱ���Ƿ���leave���ģ�Ĭ��ΪFALSE
#       -UnsolicitedReportInterval ָ��MLD host����unsolicited report��ʱ������Ĭ��Ϊ10
#       -InsertCheckSumErrors      ָ���Ƿ���MLD Host���͵ı����в���Checksum error��Ĭ��ΪFALSE
#       -InsertLengthErrors        ָ���Ƿ���MLD Host���͵ı����в���Length error��Ĭ��ΪFALSE
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::SetupMLDHost {hostName args} {

	set log [LOG::init TestCenter_SetupMLDHost]
	set errMsg ""

	foreach once {once} {
		# ������hostNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $hostName]
		if {$tmpInfo == ""} {
			set errMsg "$hostName�����ڣ��޷�����MLD host."
			break
		}

		# �齨����
		if {$args != ""} {
			set tmpCmd  "$hostName SetSession"
			for {set i 0} {$i<10} {incr i} {
				if {[llength $args] == 1} {
					set args [lindex $args 0]
				} else {
					break
				}
			}
			foreach {option value} $args {
				lappend tmpCmd $option $value
			}

			LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
			# ִ������
			if {[catch {set res [eval $tmpCmd]} err] == 1} {
				set errMsg "����MLD host�����쳣��������ϢΪ:$err ."
				break
			}
			if {$res != 0} {
				set errMsg "����MLD hostʧ�ܣ�����ֵΪ:$res ."
				break
			}
		} else {
			set errMsg "δ����MLD host���κ����ԣ��޷�����MLD host"
			break
		}

		set errMsg "����MLD host�ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::SetupMLDGroupPool {hostName groupPoolName startIP args}
#Description:   ����������MLD GroupPool
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    hostName      ��ʾҪ����������MLD GroupPool��������
#    groupPoolName ��ʾMLD Group�����Ʊ�ʶ��Ҫ���ڵ�ǰ MLD Host Ψһ
#    startIP       ��ʾGroup ��ʼ IP ��ַ��ȡֵԼ����IPV6�ĵ�ֵַ��MLD��
#    args          ��ʾIGMP Group pool�������б�,��ʽΪ{-option value}.���������������£�
#       -PrefixLen       ��ʾIP ��ַǰ׺���ȣ�ȡֵ��Χ��9��128��Ĭ��Ϊ64
#       -GroupCnt        ��ʾGroup ������ȡֵԼ����32λ��������Ĭ��Ϊ1
#       -GroupIncrement  ��ʾGroup IP ��ַ��������ȡֵ��Χ��32Ϊ��������Ĭ��Ϊ1
#       -SrcStartIP       ��ʼ����IP��ַ��MLDv2����ȡֵ��Χ��String ipv6��ʽ��ֵַ��Ĭ��Ϊ2000::3
#       -SrcCnt           ��ʾ������ַ������MLDv2����ȡֵ��Χ��32λ������Ĭ��Ϊ1
#       -SrcIncrement     ��ʾ���� IP ��ַ������MLDv2����ȡֵ��Χ��32λ������Ĭ��Ϊ1
#       -SrcPrefixLen     ��ʾ���� IP ��ַǰ׺���ȣ�MLDv2����ȡֵ��Χ��1��128��Ĭ��Ϊ64
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::SetupMLDGroupPool {hostName groupPoolName startIP args} {

	set log [LOG::init TestCenter_SetupMLDGroupPool]
	set errMsg ""

	foreach once {once} {
		# ������hostNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $hostName]
		if {$tmpInfo == ""} {
			set errMsg "$hostName�����ڣ��޷�����MLD host."
			break
		}

		# �齨����
		# ���groupPoolName�Ƿ��Ѿ����ڣ��������������������ã������½�
		set tmpInfo [array get TestCenter::object $groupPoolName]
		if {$tmpInfo == ""} {
			set tmpCmd "$hostName CreateGroupPool -GroupPoolName $groupPoolName -StartIP $startIP"
		} else {
			set tmpCmd "$hostName SetGroupPool -GroupPoolName $groupPoolName -StartIP $startIP"
		}

		if {$args != ""} {
			for {set i 0} {$i<10} {incr i} {
				if {[llength $args] == 1} {
					set args [lindex $args 0]
				} else {
					break
				}
			}
			foreach {option value} $args {
				lappend tmpCmd $option $value
			}

			LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
			# ִ������
			if {[catch {set res [eval $tmpCmd]} err] == 1} {
				set errMsg "����������MLD GroupPool�����쳣��������ϢΪ:$err ."
				break
			}
			if {$res != 0} {
				set errMsg "����������MLD GroupPoolʧ�ܣ�����ֵΪ:$res ."
				break
			}
		}

		set errMsg "����������MLD GroupPool�ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::SendMLDLeave {hostName {groupPoolList ""}}
#Description:   ��groupPoolListָ�����鲥�鷢��MLD leave���鲥�뿪������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    hostName      ��ʾҪ���ͱ��ĵ�������
#    groupPoolList ��ʾMLD Group �����Ʊ�ʶ�б�,��ָ����ʾ�������group
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::SendMLDLeave {hostName {groupPoolList ""}} {

	set log [LOG::init TestCenter_SendMLDLeave]
	set errMsg ""

	foreach once {once} {
		# ������hostNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $hostName]
		if {$tmpInfo == ""} {
			set errMsg "$hostName�����ڣ��޷�����MLD leave����."
			break
		}

		# �齨����
		if {$groupPoolList == ""} {
			set tmpCmd "$hostName SendLeave"
		} else {
			for {set i 0} {$i<10} {incr i} {
				if {[llength $groupPoolList] == 1} {
					set groupPoolList [lindex $groupPoolList 0]
				} else {
					break
				}
			}
			set tmpCmd "$hostName SendLeave -GroupPoolList $groupPoolList"
		}

		if {$groupPoolList == ""} {
			set groupPoolList "���е��鲥��"
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "$hostName ��$groupPoolList ����MLD Leave���ķ����쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "$hostName ��$groupPoolList ����MLD Leave����ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "$hostName ��$groupPoolList ����MLD Leave���ĳɹ���"

		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::SendMLDReport {hostName {groupPoolList ""}}
#Description:   ��groupPoolListָ�����鲥�鷢��MLD Join(�鲥����)����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    hostName      ��ʾҪ���ͱ��ĵ�������
#    groupPoolList ��ʾMLD Group �����Ʊ�ʶ�б�,��ָ����ʾ�������group
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::SendMLDReport {hostName {groupPoolList ""}} {

	set log [LOG::init TestCenter_SendMLDReport]
	set errMsg ""

	foreach once {once} {
		# ������hostNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $hostName]
		if {$tmpInfo == ""} {
			set errMsg "$hostName�����ڣ��޷�����MLD Join����."
			break
		}

		# �齨����
		if {$groupPoolList == ""} {
			set tmpCmd "$hostName SendReport"
		} else {
			for {set i 0} {$i<10} {incr i} {
				if {[llength $groupPoolList] == 1} {
					set groupPoolList [lindex $groupPoolList 0]
				} else {
					break
				}
			}
			set tmpCmd "$hostName SendReport -GroupPoolList $groupPoolList"
		}

		if {$groupPoolList == ""} {
			set groupPoolList "���е��鲥��"
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "$hostName ��$groupPoolList ����MLD Join���ķ����쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "$hostName ��$groupPoolList ����MLD Join����ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "$hostName ��$groupPoolList ����MLD Join���ĳɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::SetupRouter {portName routerName routerType args}
#Description:   ��ָ���˿ڴ���router��������router������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName   ��ʾ��Ҫ����router�Ķ˿���
#    routerName ��ʾ��Ҫ������ruoter�����֡����������ں���Ը�router����������
#    routerType ָ��Router����,ȡֵ��ΧΪ��Ospfv2Router�� Ospfv3Router��
#                        IsisRouter��RipRouter��RIPngRouter��BgpV4Router�� BgpV6Router��
#                        LdpRouter��RsvpRouter��IgmpRouter��MldRouter��PimRouter,
#                        MldHost, IGMPHost, PPPoEClient, DHCPClient, DHCPServer,
#                        PPPoEServer, DHCPRelay, PPPoL2TPLAC, PPPoL2TPLNS, IGMPoDHCP,
#                        IGMPoPPPoE��
#    args       ��ʾ��Ҫ������router�������б����ʽΪ{-option value}.����������У�
#       -RouterId        ָ��RouterId��Ĭ��Ϊ1.1.1.1
#       -RelateRouter    ָ��Ҫ���ӵ�·���������ƣ����Ϊ���򲻵��ӡ�
#                        �˲���ֻ�ڲ�ͬЭ�����ʱ���������壻
#                        Ŀǰ֧�ֵ��ӵ�Э����ospfv2/bgp/ldp
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::SetupRouter {portName routerName routerType args} {

	set log [LOG::init TestCenter_SetupRouter]
	set errMsg ""

	foreach once {once} {
		# ������portNameָ���Ķ˿ڶ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $portName]
		if {$tmpInfo == ""} {
			set errMsg "$portName�����ڣ��޷�����Router����."
			break
		}

		# ������routerName�Ƿ�Ϊ��
		if {$routerName == ""} {
			set errMsg "routerNameΪ�գ��޷�����Router����."
			break
		}

		# ������routerType�Ƿ�Ϊ��
		if {$routerType == ""} {
			set errMsg "routerTypeΪ�գ��޷�����Router����."
			break
		}

		# ����Router���󣬲�������������
		set tmpCmd "$portName CreateRouter -RouterName $routerName -RouterType $routerType"

		if {$args != ""} {
			for {set i 0} {$i<10} {incr i} {
				if {[llength $args] == 1} {
					set args [lindex $args 0]
				} else {
					break
				}
			}
			foreach {option value} $args {
				lappend tmpCmd $option $value
			}
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "����$routerName �����쳣, ������ϢΪ:$err ."
			break
		}
		if {$res == 0} {
			set TestCenter::object($routerName) $routerName
		} else {
			set errMsg "����$routerName ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "�ڶ˿�$portName ����$routerName �ɹ�"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::StartRouter {portName {routerList ""}}
#Description:   ��ָ���˿��Ͽ���ָ����Router����ʼЭ�����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName   ��ʾҪ��ʼЭ�����Ķ˿���
#    routerList ָ��Ҫ��ʼЭ������Router��������ƣ����Ϊ�գ���ʾ��ǰ�˿������е�Э�����
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::StartRouter {portName {routerList ""}} {

	set log [LOG::init TestCenter_StartRouter]
	set errMsg ""

	foreach once {once} {
		# ������portNameָ���Ķ˿ڶ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $portName]
		if {$tmpInfo == ""} {
			set errMsg "$portName�����ڣ��޷���ʼЭ�����."
			break
		}

		# �齨����
		if {$routerList == ""} {
			set tmpCmd "$portName StartRouter"
		} else {
			set tmpCmd "$portName StartRouter -RouterList $routerList"
		}

		if {$routerList == ""} {
			set routerList "���е�"
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "$portName ����$routerList Э����淢���쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "$portName ����$routerList Э�����ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "$portName ����$routerList Э�����ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::StopRouter {portName {routerList ""}}
#Description:   ��ָ���˿��Ϲر�ָ����Router��ֹͣЭ�����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName   ��ʾҪֹͣЭ�����Ķ˿���
#    routerList ָ��ҪֹͣЭ������Router��������ƣ����Ϊ�գ���ʾ��ǰ�˿������е�Э�����
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::StopRouter {portName {routerList ""}} {

	set log [LOG::init TestCenter_StopRouter]
	set errMsg ""

	foreach once {once} {
		# ������portNameָ���Ķ˿ڶ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $portName]
		if {$tmpInfo == ""} {
			set errMsg "$portName�����ڣ��޷�ֹͣЭ�����."
			break
		}

		# �齨����
		if {$routerList == ""} {
			set tmpCmd "$portName StopRouter"
		} else {
			set tmpCmd "$portName StopRouter -RouterList $routerList"
		}

		if {$routerList == ""} {
			set routerList "���е�"
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "$portName �ر�$routerList Э����淢���쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "$portName �ر�$routerList Э�����ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "$portName �ر�$routerList Э�����ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::SetupIGMPRouter {routerName routerIp args}
#Description:   ����IGMP/MLD router
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName      ��ʾҪ���õ�IGMP/MLD Router��
#    routerIp        ��ʾ IGMP/MLD Router �Ľӿ� IPv4/IPv6 ��ַ
#    args            ��ʾIGMP router�������б�,��ʽΪ{-option value}.���������������£�
#     IGMP router:
#       -SrcMac             ��ʾԴMac���������Routerʱ��Ĭ��ֵ���ղ���1����
#       -ProtocolType       ��ʾProtocol�����͡��Ϸ�ֵ��IGMPv1/IGMPv2/IGMPv3��Ĭ��ΪIGMPv2
#       -IgnoreV1Reports    ָ���Ƿ���Խ��յ��� IGMPv1 Host�ı��ģ�Ĭ��ΪFalse
#       -Ipv4DontFragment   ָ�������ĳ��ȴ��� MTU ʱ���Ƿ���з�Ƭ��Ĭ��ΪFalse
#       -LastMemberQueryCount  ��ʾ���϶�����û�г�Ա֮ǰ���͵��ض����ѯ�Ĵ�����Ĭ��Ϊ2
#       -LastMemberQueryInterval  ��ʾ���϶�����û�г�Ա֮ǰ����ָ�����ѯ���ĵ� ʱ��������λ ms����Ĭ��Ϊ1000
#       -QueryInterval            ��ʾ���Ͳ�ѯ���ĵ�ʱ��������λ s������Ĭ��Ϊ32
#       -QueryResponseUperBound   ��ʾIgmp Host���ڲ�ѯ���ĵ���Ӧ��ʱ����������ֵ����λ ms����Ĭ��Ϊ10000
#       -StartupQueryCount      ָ��Igmp Router����֮�����͵�Query���ĵĸ�����ȡֵ��Χ��1-255,Ĭ��Ϊ2
#       -Active                ��ʾIGMP Router�Ự�Ƿ񼤻Ĭ��ΪTRUE
#     MLD router:
#       -SrcMac             ��ʾԴMac���������Routerʱ��Ĭ��ֵ���ղ���1����
#       -ProtocolType       ��ʾProtocol�����͡��Ϸ�ֵ��MLDv1/MLDv2��Ĭ��Ϊ MLDv1
#       -LastMemberQueryCount  ��ʾ���϶�����û�г�Ա֮ǰ���͵��ض����ѯ�Ĵ���
#       -LastMemberQueryInterval  ��ʾ���϶�����û�г�Ա֮ǰ����ָ�����ѯ���ĵ� ʱ��������λ ms����Ĭ��Ϊ1000
#       -QueryInterval            ��ʾ���Ͳ�ѯ���ĵ�ʱ��������λ s������Ĭ��Ϊ125
#       -QueryResponseUperBound   ��ʾMLD Host���ڲ�ѯ���ĵ���Ӧ��ʱ����������ֵ����λ ms����Ĭ��Ϊ10000
#       -StartupQueryCount      ָ��MLD Router����֮�����͵�Query���ĵĸ�����ȡֵ��ΧΪ������,Ĭ��Ϊ2
#       -Active                ��ʾMLD Router�Ƿ񼤻ȡֵ��Χ��TRUE/FALSE,Ĭ��ΪTRUE
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::SetupIGMPRouter {routerName routerIp args} {

	set log [LOG::init TestCenter_SetupIGMPRouter]
	set errMsg ""

	foreach once {once} {
		# ������routerNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $routerName]
		if {$tmpInfo == ""} {
			set errMsg "$routerName�����ڣ��޷�����IGMP/MLD Router."
			break
		}

		if {$routerIp == ""} {
			set errMsg "$routerIpΪ�գ��޷�����IGMP/MLD Router."
			break
		}

		# �齨����
		set tmpCmd  "$routerName SetSession -TesterIp $routerIp"

		# ׷������
		if {$args != ""} {
			for {set i 0} {$i<10} {incr i} {
				if {[llength $args] == 1} {
					set args [lindex $args 0]
				} else {
					break
				}
			}
			foreach {option value} $args {
				lappend tmpCmd $option $value
			}
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		# ִ������
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "����IGMP/MLD Router�����쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "����IGMP/MLD Routerʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "����IGMP/MLD Router�ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::StartIGMPRouterQuery {routerName}
#Description:   ��ʼͨ�á��ض�IGMP/MLD��ѯ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName      ��ʾҪ��ʼͨ�á��ض�IGMP/MLD��ѯ��IGMP/MLD Router��
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::StartIGMPRouterQuery {routerName} {

	set log [LOG::init TestCenter_StartIGMPRouterQuery]
	set errMsg ""

	foreach once {once} {
		# ������routerNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $routerName]
		if {$tmpInfo == ""} {
			set errMsg "$routerName�����ڣ��޷���ʼͨ�á��ض�IGMP/MLD��ѯ."
			break
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $routerName StartAllQuery"
		# ִ������
		if {[catch {set res [$routerName StartAllQuery]} err] == 1} {
			set errMsg "��ʼͨ��IGMP/MLD��ѯ�����쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "��ʼͨ��IGMP/MLD��ѯʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "��ʼͨ��IGMP/MLD��ѯ�ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::StopIGMPRouterQuery {routerName}
#Description:   ֹͣͨ�á��ض�IGMP/MLD��ѯ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName      ��ʾҪ��ʼͨ�á��ض�IGMP/MLD��ѯ��IGMP/MLD Router��
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::StopIGMPRouterQuery {routerName} {

	set log [LOG::init TestCenter_StopIGMPRouterQuery]
	set errMsg ""

	foreach once {once} {
		# ������routerNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $routerName]
		if {$tmpInfo == ""} {
			set errMsg "$routerName�����ڣ��޷�ֹͣͨ��IGMP/MLD��ѯ."
			break
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $routerName StopAllQuery"
		# ִ������
		if {[catch {set res [$routerName StopAllQuery]} err] == 1} {
			set errMsg "ֹͣͨ��IGMP/MLD��ѯ�����쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "ֹͣͨ��IGMP/MLD��ѯʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "ֹͣͨ��IGMP/MLD��ѯ�ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::StartARPStudy {srcHost dstHost retries interval}
#Description:   ����ARP����ѧϰĿ��������MAC��ַ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    srcHost  ��ʾ����ARP�����������
#    dstHost  ��ʾ�������Ŀ��IP��ַ�����������ƣ�Ĭ��Ϊ���ص�ַ���ߵ�ַ�б�
#    retries   ָ��Arp����ʧ�����Դ�����Ĭ��Ϊ3
#    interval  ��ʾ��������ARP����ļ��ʱ�䣬��λs��Ĭ��Ϊ1
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::StartARPStudy {srcHost {dstHost ""} {retries "3"} {interval "1"}} {

	set log [LOG::init TestCenter_StartARPStudy]
	set errMsg ""

	foreach once {once} {
		# ������srcHostָ����host�����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $srcHost]
		if {$tmpInfo == ""} {
			set errMsg "$srcHost�����ڣ��޷�����ARPѧϰ."
			break
		}

		# ����ARPѧϰ����
		if {$dstHost == ""} {
			set tmpCmd "$srcHost SendArpRequest -retries $retries -timer $interval"
		} else {
			set tmpCmd "$srcHost SendArpRequest -host $dstHost -retries $retries -timer $interval"
		}

		if {$dstHost == ""} {
			set dstHost "���ص�ַ"
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "$srcHost ��$dstHost ����ARP�������쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "$srcHost ��$dstHost ����ARP����ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "$srcHost ��$dstHost ����ARP����ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:   ::TestCenter::CreateTraffic {portName trafficName}
#Description:    ���������������
#Calls:   ��
#Data Accessed:    ��
#Data Updated:   ��
#Input:
#     portName      ��ʾ��Ҫ����traffic�����������Ķ˿ڵĶ˿�����
#     trafficName   ��ʾҪ�����������������
#Output:    ��
# Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú�������
#   ����ֵ                                ��ʾʧ��
#Others:         ��
#*******************************************************************************
proc ::TestCenter::CreateTraffic {portName trafficName} {

	set log [LOG::init TestCenter_CreateTraffic]
	set errMsg ""

	foreach once {once} {
		# ������portNameָ���Ķ˿ڶ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $portName]
		if {$tmpInfo == ""} {
			set errMsg "$portName�����ڣ��޷����������������."
			break
		}
		# ������trafficName�Ƿ�Ϊ��
		if {$trafficName == ""} {
			set errMsg "$trafficNameΪ�գ��޷����������������"
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $portName CreateTraffic -TrafficName $trafficName"
		# �����������
		if {[catch {set res [$portName CreateTraffic -TrafficName $trafficName]} err] == 1} {
			set errMsg "�����������$trafficName �����쳣��������ϢΪ:$err ."
			break
		}
		if {$res == 0} {
			set TestCenter::object($trafficName) $trafficName
		} else {
			set errMsg "�����������$trafficName ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "$portName �����������$trafficName �ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:   ::TestCenter::SetupTrafficProfile {trafficName profileName args}
#Description:    ��������������������������Բ���,���profileName�Ѵ��ڣ���������ã�
#                ��������ڣ��򴴽�һ���µ�profile
#Calls:   ��
#Data Accessed:    ��
#Data Updated:   ��
#Input:
#     trafficName   ��ʾ��Ҫ����������profile�����������������
#     profileName   ��ʾ��Ҫ���������õ�profile����
#     args          ��ʾ����������������Բ���,��ʽΪ{-option value ...}.�������Բ������£�
#        -Type      ��ʾ�ǳ�������Burst��ȡֵ��ΧConstant/Burst��Ĭ��ΪConstant
#        -TrafficLoad      ��ʾ�����ĸ��ɣ���������ĵ�λ���ø�ֵ����Ĭ��Ϊ10
#        -TrafficLoadUnit  ��ʾ������λ��ȡֵ��Χfps/kbps/mbps/percent��Ĭ��ΪPercent
#        -BurstSize        ��ʾBurst ���������͵ı���������Ĭ��Ϊ1
#        -FrameNum         ��ʾһ�η��ͱ��ĵ�������Ϊ BurstSize ������������Ĭ��Ϊ100
#        -Blocking         ��ʾ�Ƿ�������ģʽ��Enable/Disable����Ĭ��ΪDisable
#Output:    ��
# Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú�������
#   ����ֵ                                         ��ʾʧ��
#Others:         ��
#*******************************************************************************
proc ::TestCenter::SetupTrafficProfile {trafficName profileName args} {

	set log [LOG::init TestCenter_SetupTrafficProfile]
	set errMsg ""

	foreach once {once} {
		# ������trafficNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $trafficName]
		if {$tmpInfo == ""} {
			set errMsg "$trafficName�����ڣ��޷��������������profile."
			break
		}

		# ������profileName�Ƿ�Ϊ��
		if {$profileName == ""} {
			set errMsg "profileNameΪ�գ��޷��������������profile."
			break
		}

		# �ж�profileName�Ƿ��Ѵ��ڣ�������ڣ��޸��������ԣ������½�profile����������������
		set tmpInfo [array get TestCenter::object $profileName]
		if {$tmpInfo != ""} {
			# ����profile
			set tmpCmd "$trafficName ConfigProfile -Name $profileName"
		} else {
			# ����profile
			set tmpCmd "$trafficName CreateProfile -Name $profileName"
		}

		if {$args != ""} {
			for {set i 0} {$i<10} {incr i} {
				if {[llength $args] == 1} {
					set args [lindex $args 0]
				} else {
					break
				}
			}
			foreach {option value} $args {
				lappend tmpCmd $option $value
			}
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "$trafficName ����$profileName �����쳣,������ϢΪ:$err ."
			break
		}
		if {$res == 0} {
			set TestCenter::object($profileName) $profileName
		} else {
			set errMsg "$trafficName ����$profileName ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "$trafficName ����$profileName �ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::SetupStream {trafficName streamName args}
#Description:  ��������������������������Ѵ��ڣ����޸��������ԣ���������ڣ���
#              �����µ������󣬲�������������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    trafficName  ��ʾ��Ҫ����stream�����traffic����Ķ�������
#    streamName   ��ʾ��Ҫ������stream���������
#    args         ��ʾ������������б���ʽΪ{-option value ...}��������������������£�
#       -FrameLen ָ������֡���� ��λΪbyte��Ĭ��Ϊ128
#       -StreamType ָ������ģ������; ȡֵ��ΧΪ:Normal,VPN,PPPoX DHCP��Ĭ��ΪNormal
#       -FrameLenMode ָ������֡���ȵı仯��ʽ��fixed | increment | decrement | random
#                     ��������Ϊrandomʱ������仯��ΧΪ:( FrameLen��FrameLen+ FrameLenCount-1)
#                     Ĭ��Ϊfixed
#       -FrameLenStep ��ʾ����֡���ȵı仯������Ĭ��Ϊ1
#       -FrameLenCount ��ʾ������Ĭ��Ϊ1
#       -insertsignature ָ���Ƿ����������в���signature field��ȡֵ��true | false  Ĭ��Ϊtrue������signature field
#       -ProfileName  ָ��Profile ������
#       -FillType   ָ��Payload����䷽ʽ��ȡֵ��ΧΪCONSTANT | INCR |DECR | PRBS��Ĭ��ΪCONSTANT
#       -ConstantFillPattern  ��FillTypeΪConstant��ʱ����Ӧ�����ֵ��Ĭ��Ϊ0
#       -EnableFcsErrorInsertion  ָ���Ƿ����CRC����֡��ȡֵ��ΧΪTRUE | FALSE��Ĭ��ΪFALSE
#       -EnableStream  ָ��modifierʹ��stream/flow����, ��ʹ��streamģʽʱ�����˿�stream�����ܳ���32k��
#                      ȡֵ��ΧTRUE | FALSE��Ĭ��ΪFALSE
#       -TrafficPattern ��Ҫ�������󶨵����Σ�ʹ��SrcPoolName�Լ�DstPoolNameʱ����
#                        ȡֵ��ΧΪPAIR | BACKBONE | MESH��Ĭ��ΪPAIR
#
#Output:    ��
# Return:
#    list $CPEConfig::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $CPEConfig::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                       ��ʾʧ��
#
#Others:    ��
#*******************************************************************************
proc ::TestCenter::SetupStream {trafficName streamName args} {

	set log [LOG::init TestCenter_SetupStream]
	set errMsg ""

	foreach once {once} {
		# ������trafficNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $trafficName]
		if {$tmpInfo == ""} {
			set errMsg "$trafficName�����ڣ��޷��������������������."
			break
		}

		# ������streamName�Ƿ�Ϊ��
		if {$streamName == ""} {
			set errMsg "streamNameΪ�գ��޷��������������������."
			break
		}

		# �ж�streamName�Ƿ��Ѵ��ڣ�������ڣ��޸��������ԣ������½�stream����������������
		set tmpInfo [array get TestCenter::object $streamName]
		if {$tmpInfo != ""} {
			# ����profile
			set tmpCmd "$trafficName ConfigStream -StreamName $streamName"
		} else {
			# ����profile
			set tmpCmd "$trafficName CreateStream -StreamName $streamName"
		}

		if {$args != ""} {
			for {set i 0} {$i<10} {incr i} {
				if {[llength $args] == 1} {
					set args [lindex $args 0]
				} else {
					break
				}
			}
			foreach {option value} $args {
				lappend tmpCmd $option $value
			}
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "$trafficName ����$streamName �����쳣,������ϢΪ:$err ."
			break
		}
		if {$res == 0} {
			set TestCenter::object($streamName) $streamName
		} else {
			set errMsg "$trafficName ����$streamName ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "$trafficName ����$streamName �ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::SetupHeader {headerName headerType args}
#Description:   �������������ݱ��ı�ͷ��Ϣ�����headerName�Ѵ��ڣ������ã���������ڣ��򴴽�������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#      headerName     ��ʾ��Ҫ���������õ����ݱ��ı�ͷ���֡�
#      headerType     ��ʾ��Ҫ���������õ����ݱ��ı�ͷ���ͣ�ȡֵ��ΧΪ��
#                     Eth | Vlan | IPV4 | TCP | UDP | MPLS | IPV6 | POS | HDLC
#      args           ��ʾ�������ԵĲ����б���ʽΪ{-option value ...},����������ݱ�������������ͬ��
#        ETH
#          -DA                ��ʾĿ��MAC,����ָ��
#          -SA                ��ʾԴMAC������ָ��
#           -saRepeatCounter  ��ʾԴMAC�ı仯��ʽ��fixed | increment | decrement��Ĭ��ΪFixed
#           -saStep           ��ʾԴMAC�ı仯������Ĭ��Ϊ1
#           -SrcOffset        ��ʾԴMAC�ı仯�����Ŀ�ʼλ�ã�Ĭ��Ϊ0
#           -daRepeatCounter  ��ʾĿ��MAC�ı仯��ʽ��fixed | increment | decrement��Ĭ��ΪFixed
#           -daStep           ��ʾĿ��MAC�ı仯������Ĭ��Ϊ1
#           -DstOffset        ��ʾĿ��MAC�ı仯�����Ŀ�ʼλ�ã�Ĭ��Ϊ0
#           -numDA            ��ʾ�仯��Ŀ��MAC������Ĭ��Ϊ1
#           -numSA            ��ʾ�仯��ԴMAC������Ĭ��Ϊ1
#           -EthType          ��ʾ��̫�����ͣ�16���ƣ�Ĭ��ֵΪauto���������̫��ͷ�ϲ��������Э��ͷʱ��
#                             ��Ĭ��ֵΪ88B5������������Э��ͷ������ֶ��Զ�����ӵ�Э��ͷ��ƥ�䡣
#           -EthTypeMode      ��ʾEthType�ı仯��ʽ��fixed |increment | decrement��Ĭ��Ϊfixed
#           -EthTypeStep      ��ʾEthType�ı仯������10���ƣ�Ĭ��Ϊ1
#           -EthTypeCount     ��ʾEthType������10���ƣ�Ĭ��Ϊ1
#        Vlan
#          -vlanId             ��ʾVlanֵ������ָ��
#           -userPriority      ��ʾ�û����ȼ���Ĭ��Ϊ0
#           -cfi               ��ʾCfiֵ��Ĭ��Ϊ0
#           -mode              ��ʾVlanֵ�ı仯��ʽ fixed | increment | decrement��Ĭ��ΪFixed
#           -repeat            ��ʾVlan�仯������Ĭ��Ϊ10
#           -step              ��ʾVlan�仯������Ĭ��Ϊ1
#           -maskval           ��ʾvlan�����룬Ĭ��Ϊ"0000XXXXXXXXXXXX"
#           -protocolTagId     ��ʾTPID,ȡֵ8100��9100��16������ֵ��Ĭ��Ϊ8100
#           -Vlanstack         ��ʾVlan�Ķ���ǩ��Single/Multiple �� -Vlanstack Single��Ĭ��ΪSingle
#           -Stack             ��ʾ���ڶ���ǩ����һ�㣬Ĭ��Ϊ1
#        IPV4
#           -precedence        ��ʾTos�е�����ת����ȡֵ�μ���������Ĭ��Ϊroutine
#           -delay             ��ʾTos����С��ʱ��ȡֵnormal��low��Ĭ��Ϊnormal
#           -throughput        ��ʾTos�������������ȡֵnormal��High��Ĭ��Ϊnormal
#           -reliability       ��ʾTos����ѿɿ��ԣ�ȡֵnormalReliability��HighReliability��Ĭ��ΪnormalReliability
#           -cost              ��ʾTos�Ŀ�����ȡֵnormalCost��LowCost��Ĭ��ΪnormalCost
#           -identifier        ��ʾ���ı�ǣ�Ĭ��Ϊ0
#           -reserved          ��ʾ����λ��Ĭ��Ϊ0��ע�⣬�����ԵĴ����ѱ����Σ�
#           -totalLength       ��ʾ�ܳ��ȣ�Ĭ��Ϊ46
#           -lengthOverride    ��ʾ�����Ƿ��Զ��壬ȡֵboolֵ��Ĭ��ΪFalse����0
#           -fragment          ��ʾ�ܷ��Ƭ��ȡֵboolֵ��Ĭ��ΪMay����1
#           -lastFragment      ��ʾ�Ƿ����һƬ��ȡֵboolֵ��Ĭ��ΪLast����1
#           -fragmentOffset    ��ʾ֡��ƫ������Ĭ��Ϊ0
#           -ttl               ��ʾTTL��Ĭ��Ϊ64
#           -ipProtocol        ��ʾЭ�����ͣ�10����ȡֵ����ö�٣�Ĭ��Ϊ6��TCP��
#           -ipProtocolMode    ��ʾipProtocol�ı仯��ʽ��fixed |increment | decrement��Ĭ��Ϊfixed
#           -ipProtocolStep    ��ʾipProtocol�ı仯������10���ƣ�Ĭ��Ϊ1
#           -ipProtocolCount   ��ʾipProtocol������10���ƣ�Ĭ��Ϊ1
#           -useValidChecksum  ��ʾCRC�Ƿ��Զ����㣬Ĭ��Ϊtrue
#          -sourceIpAddr       ��ʾԴIP������ָ��
#           -sourceIpMask      ��ʾԴIP�����룬Ĭ��Ϊ"255.0.0.0"
#           -sourceIpAddrMode  ��ʾԴIP�ı仯����Fixed Random Increment Decrement��Ĭ��ΪFixed
#           -sourceIpAddrOffset ָ����ʼ�仯��λ�ã�Ĭ��Ϊ0
#           -sourceIpAddrRepeatCount  ��ʾԴIP�ı仯������Ĭ��Ϊ10
#          -destIpAddr                ��ʾĿ��IP������ָ��
#           -destIpMask               ��ʾĿ��IP�����룬Ĭ��Ϊ"255.0.0.0"
#           -destIpAddrMode    ��ʾĿ��IP�ı仯������ö��ֵ���£�Fixed Random Increment Decrement��Ĭ��ΪFixed
#           -destIpAddrOffset  ָ����ʼ�仯��λ�ã�Ĭ��Ϊ0
#           -destIpAddrRepeatCount ��ʾĿ��IP�ı仯������Ĭ��Ϊ10
#           -destDutIpAddr         ָ����ӦDUT��ip��ַ�������أ�Ĭ��Ϊ192.85.1.1
#           -options               ��ʾ��ѡ�4�ֽ�������16������ֵ
#           -qosMode            ��ʾQos�����ͣ�tos/dscp �� -qosMode tos��Ĭ��Ϊdscp
#           -qosvalue           ��ʾQosȡֵ��Dscpȡֵ0~63��tosȡֵ0~255��ʮ����ȡֵ��Ĭ��Ϊ 0
#        TCP
#           -offset        ��ʾƫ������Ĭ��Ϊ5
#          -sourcePort     ��ʾԴ�˿ڣ�����ָ��
#           -srcPortMode   ��ʾ�˿ڸı�ģʽfixed | increment | decrement��Ĭ��Ϊfixed
#           -srcPortCount  ��ʾ������Ĭ��Ϊ1
#           -srcPortStep   ��ʾ������Ĭ��Ϊ1
#          -destPort       ��ʾĿ�Ķ˿ڣ�����ָ��
#           -dstPortMode   ��ʾ�˿ڸı�ģʽfixed | increment | decrement��Ĭ��Ϊfixed
#           -dstPortCount  ��ʾ������Ĭ��Ϊ1
#           -dstPortStep   ��ʾ������Ĭ��Ϊ1
#           -sequenceNumber ��ʾ����ţ�Ĭ��Ϊ0
#           -acknowledgementNumber   ��ʾ��Ӧ�ţ�Ĭ��Ϊ0
#           -window                  ��ʾ���ڣ�Ĭ��Ϊ0
#           -urgentPointer           ��ʾurgentPointer ��Ĭ��Ϊ0
#           -options                 ��ʾ��ѡ��
#           -urgentPointerValid      ��ʾ�Ƿ���λuP��Ĭ��ΪFalse
#           -acknowledgeValid        ��ʾ�Ƿ���λ��Ӧ��Ĭ��ΪFalse
#           -pushFunctionValid       ��ʾ�Ƿ���λpF��Ĭ��ΪFalse
#           -resetConnection         ��ʾ�Ƿ�����tcp���ӣ�Ĭ��ΪFalse
#           -synchronize             ��ʾ�Ƿ�ͬ����Ĭ��ΪFalse
#           -finished                ��ʾ�Ƿ������Ĭ��ΪFalse
#           -useValidChecksum        ��ʾTcp��У����Ƿ��Զ����㣬Ĭ��ΪEnable
#        UDP
#           -sourcePort       ��ʾԴ�˿ڣ�����ָ��
#            -srcPortMode     ��ʾ�˿ڸı�ģʽ fixed | increment | decrement��Ĭ��Ϊfixed
#            -srcPortCount    ��ʾ������Ĭ��Ϊ1
#            -srcPortStep     ��ʾ������Ĭ��Ϊ1
#           -destPort         ��ʾĿ�Ķ˿ڣ�����ָ��
#            -dstPortMode     ��ʾ�˿ڸı�ģʽfixed | increment | decrement��Ĭ��Ϊfixed
#            -dstPortCount    ��ʾ������Ĭ��Ϊ1
#            -dstPortStep     ��ʾ������Ĭ��1
#            -checksum        ��ʾУ��ͣ� Ĭ��Ϊ0
#            -enableChecksum  ��ʾ�Ƿ�ʹ��У��ͣ�Ĭ��ΪEnable
#            -length           ��ʾ����,Ĭ��Ϊ10
#            -lengthOverride   ��ʾ�����Ƿ����д��Ĭ��ΪDisable
#            -enableChecksumOverride   ��ʾ�Ƿ�ʹ��У�����д��Ĭ��ΪDisable
#            -checksumMode      ��ʾУ������ͣ�Ĭ��Ϊauto
#        MPLS
#            �����еĲ���
#            -type type optional,MPLS type, mplsUnicast or mplsMulticast, i.e -type mplsUnicast
#            -label label optional, MPLS label��i.e -label 0
#            -LabelCount LabelCount optional, MPLS label count��i.e -LabelCount 1
#            -LabelMode LabelMode optional, MPLS label change mode, fixed |increment | decrement��i.e -LabelMode fixed
#            -LabelStep LabelStep optional, MPLS label step��i.e -LabelStep 1
#            -Exp Exp optional��experience value��i.e  -Exp 0
#            -TTL TTL optional��TTL value��i.e -TTL 0
#            -bottomOfStack bottomOfStack optional��MPLS label stack��i.e -bottomOfStack 0
#            �û��ֲ��еĲ���
#            -type                 ��ʾMPLS������ͣ�mplsUnicast | mplsMulticast��Ĭ��ΪmplsUnicast
#            -label                ��ʾMPLS���ֵ��Ĭ��Ϊ0
#            -experimentalUse      ��ʾ����ֵ��Ĭ��Ϊ2
#            -timeToLive           ��ʾTTL��Ĭ��Ϊ64
#            -bottomOfStack        ��ʾMPLS���ջλ�ã�Ĭ��Ϊ0
#        IPV6
#            -TrafficClass    ��ʾ������ȼ���Ĭ��Ϊ0
#           -FlowLabel        ��ʾFlow ���ֵ������ָ��
#            -PayLoadLen      ��ʾ���ɳ��ȣ�û���������Զ����� ��Ĭ��Ϊ20
#            -NextHeader      ��ʾ��һ��ͷ���ͣ�Ĭ��Ϊ6
#            -HopLimit        ��ʾHop���ƣ�Ĭ��Ϊ255
#            -SourceAddress   ��ʾԴipv6Address��Ĭ��Ϊ2000::2
#            -DestinationAddress  ��ʾĿ��ipv6Address��Ĭ��Ϊ2000::1
#            -SourceAddressMode   ��ʾԭ��ַ�ı�ģʽ fixed | increment | decrement��Ĭ��Ϊfixed
#            -SourceAddressCount  ��ʾ������Ĭ��Ϊ1
#            -SourceAddressStep   ��ʾ�仯������Ĭ��Ϊ0000:0000:0000:0000:0000:0000:0000:0001
#            -SourceAddressOffset  ʾԭ��ַ�仯ƫ������Ĭ��Ϊ0
#            -DestAddressMode      ��ʾĿ�ĵ�ַ�ı�ģʽ��fixed | increment | decrement��Ĭ��Ϊfixed
#            -DestAddressCount     ��ʾ������Ĭ��Ϊ1
#            -DestAddressStep      ��ʾ�仯���� ��Ĭ��Ϊ0000:0000:0000:0000:0000:0000:0000:0001
#            -DestAddressOffSet     ��ʾƫ������Ĭ��Ϊ0
#        POS
#            -HdlcAddress      ��ʾ�ӿڵ�ַ��Ĭ��ΪFF
#            -HdlcControl      ��ʾ�ӿڿ������ͣ�Ĭ��Ϊ03
#            -HdlcProtocol     ��ʾ�ӿ���·��Э�飬Ĭ��Ϊ0021
#        HDLC
#            -HdlcAddress       ��ʾ�ӿڵ�ַ��Ĭ��Ϊ0F
#            -HdlcControl       ��ʾ�ӿڿ������ͣ�Ĭ��Ϊ00
#            -HdlcProtocol      ��ʾ�ӿ���·��Э�飬Ĭ��Ϊ0800
#
# ע�⣺POS �� HDLCֻ�ṩ�����µı���ͷ����֧���������б���ͷ
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError   $msg ��ʾ���ú���ʧ��
#    ����ֵ                               ��ʾʧ��
#
#Others:    ��
#*******************************************************************************
proc ::TestCenter::SetupHeader {headerName headerType args} {

	set log [LOG::init TestCenter_SetupHeader]
	set errMsg ""

	foreach once {once} {
		# ������headerName�Ƿ�Ϊ��
		if {$headerName == ""} {
			set errMsg "headerNameΪ�գ��޷��������������ݱ��ı�ͷ."
			break
		}

		# ������headerType�Ƿ�Ϊ��
		if {$headerType == ""} {
			set errMsg "headerTypeΪ�գ��޷��������������ݱ��ı�ͷ."
			break
		}

		# �ж�HeaderCreator�����Ƿ���ڣ���������ڣ����½�һ����Ϊheader1�Ķ���
		set tmpInfo [array get TestCenter::object "header1"]
		if {$tmpInfo == ""} {
			LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: HeaderCreator header1"
			# ����HeaderCreator����
			if {[catch {set headerObject [HeaderCreator header1]} err ] == 1} {
				set errMsg "����header�������쳣��������ϢΪ: $err ."
				break
			}
			if {[string match $headerObject "header1"] != 1} {
				set errMsg "����header����ʧ�ܣ�����ֵΪ:$headerObject ."
				break
			}
			set TestCenter::object($headerObject) $headerObject
		}

		# �ж�headerName�Ƿ��Ѵ��ڣ�������ڣ��޸��������ԣ������½�header����������������
		set tmpInfo [array get TestCenter::object $headerName]
		if {$tmpInfo != ""} {
			# �齨����header������
			if {$headerType == "POS" || $headerType == "HDLC"} {
				set errMsg "��֧������POS����HDLC���͵ı���ͷ��"
				break
			}
			set tmpSubCmd ""
			append tmpSubCmd Config $headerType Header
			set tmpCmd "header1 $tmpSubCmd -PduName $headerName"
		} else {
			# �齨����header������
			set tmpSubCmd ""
			append tmpSubCmd Create $headerType Header
			set tmpCmd "header1 $tmpSubCmd -PduName $headerName"
		}

		if {$args != ""} {
			for {set i 0} {$i<10} {incr i} {
				if {[llength $args] == 1} {
					set args [lindex $args 0]
				} else {
					break
				}
			}
			foreach {option value} $args {
				lappend tmpCmd $option $value
			}
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		# ִ������
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "����������$headerName �����쳣,������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "����������$headerName ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "����������$headerName �ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::SetupPacket {packetName packetType args}
#Description:   �������ݱ��ı�����Ϣ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    packetName     ָ����Ҫ���������ݱ��ı��Ķ�����
#    packetType     ��ʾ��Ҫ���������ݱ��ı������ͣ�ȡֵ��ΧΪ��
#                    DHCP | PIM | IGMP | PPPoE | ICMP | ARP | Custom
#    args           ��ʾ�������ԵĲ����б���ʽΪ{-option value ...},����������ݱ�������������ͬ��
#        DHCP
#          -op     ��ʾ���ͱ��ĵ����ͣ������� 1 ���� 2��1:client,2:server������ָ��
#          -htype  ��ʾӲ����ַ���ͣ��Ǹ�����ֵ������ָ��
#          -hlen   ��ʾӲ����ַ���ȣ��Ǹ�����ֵ������ָ��
#          -hops   ��ʾ�������Ǹ�����ֵ������ָ��
#          -xid    ��ʾ�����ţ��Ǹ�����ֵ������ָ��
#          -secs   ��ʾ�������Ǹ�����ֵ������ָ��
#          -bflag  ��ʾ�㲥��־λ, ������ 0/1������ָ��
#          -mbz15  ��ʾ�㲥��־λ��� 15 λ bit λ������ָ��
#          -ciaddr ��ʾ�ͻ��� IP ��ַ����ʽΪ0.0.0.0������ָ��
#          -yiaddr ��ʾ���Ի� IP ��ַ����ʽΪ0.0.0.0������ָ��
#          -siaddr ��ʾ������ IP ��ַ����ʽΪ0.0.0.0������ָ��
#          -giaddr ��ʾ�м̴��� IP ��ַ����ʽΪ 0.0.0.0������ָ��
#          -chaddr ��ʾ�ͻ���Ӳ����ַ����ʽΪ 00��00��00��00��00��00������ָ��
#           -sname  ��ʾ���������ƣ�64 Bytes �� 16 ����ֵ
#           -file   ��ʾDHCP ��ѡ����/�����ļ���, 128 Bytes �� 16 ����ֵ
#        PIM
#          -Type    ��ʾ��Ϣ���ͣ���ѡֵΪ Hello, Join_Prune, Register, Register_Stop, Assert������ָ��
#           -Version          ��ʾЭ��汾
#           -Reserved         ��ʾռ�ñ�־λ
#           -OptionType       ��ʾЭ�� option �ֶ�����
#           -OptionLength     ��ʾЭ�� option �ֶγ���
#           -OptionValue      ��ʾЭ�� option �ֶ�����
#           -UnicastAddrFamily
#           -GroupNum
#           -HoldTime
#           -GroupIpAddr
#           -GroupIpBBit
#           -GroupIpZBit
#           -SourceIpAddr
#           -PrunedSourceIpAddr
#           -RegBorderBit
#           -RegNullRegBit
#           -RegReservedField
#           -RegEncapMultiPkt
#           -RegGroupIpAddr
#           -RegSourceIpAddr
#           -AssertRptBit
#���������� -AssertMetricPerf
#           -AssertMetric
#        IGMP(����������в�һ�£���ȷ��)
#          -Type          ��ʾIGMP ��Ϣ���ͣ�����ָ��
#           -GroupAddr    ��ʾ�鲥���ַ
#           -MaxReponseTime ��ʾIGMPv2 �����Ӧʱ��
#           -SuppressFlag   ��ʾIGMPv3Query ��������λ
#           -SourceNum      ��ʾIGMPv3Դ��ַ����(���� Query �� Report)
#           -SourceAddr     ��ʾIGMPv3 Դ��ַ(���� Query �� Report)
#           -SourceAddrCnt  ��ʾIGMPv3 Դ��ַ����(���� Query �� Report)
#           -SourceAddrStep ��ʾIGMPv3 Դ��ַ����(���� Query �� Report)
#           -Reserved       ��ʾIGMPv3Report ռ��λ
#           -GroupRecords   ��ʾIGMPv3Report �鲥����Ϣ
#           -RecordType     ��ʾIGMPv3Report �鲥����Ϣ����
#           -AuxiliaryDataLen  ��ʾIGMPv3Report ������Ϣ����
#           -MulticastAddr   ��ʾIGMPv3Report �鲥��ַ
#        PPPoE
#          -PPPoEType  ��ʾPPPoE �������ͣ�����ָ��
#           -Version   ��ʾ����Э��汾��
#           -Type      ��ʾ����Э������
#           -Code      ��ʾ���Ĵ���(����Ӧ PPPoE_Session ʱ��code Ϊ����)
#           -SessionId ��ʾ�Ự ID
#           -Length    ��ʾ���ĳ���
#           -Tag       ��ʾ���ı�ǩ����
#           -TagLength ��ʾ���ı�ǩ����(16 ����)
#           -TagValue  ��ʾ���ı�ǩֵ(16 ����)
#        ICMP
#           -IcmpType  ��ʾICMP�����ͣ�echo_request��echo_reply��destination_unreachable��
#                      source_quench��redirect��time_exceeded��parameter_problem��
#                      timestamp_request��timestamp_reply��information_request��information_reply
#                      ֧��ֱ����д�����ؼ��ֶΣ�ͬʱҲ֧��0-255 ʮ����������д
#           -Code      ��ʾIcmp�����룬֧��0-255 ʮ����������д
#           -Checksum  ��ʾУ����,Ĭ���Զ�����
#           -SequNum   ��ʾIcmp�����к�
#           -Data      ��ʾICMP�����ݣ�Ĭ��Ϊ0000
#           -InternetHeader  ��ʾIP�ײ�����IcmpType��Ϊdestination_unreachable��parameter_problem��redirect��
#                            source_quench��time_exceededʱ��Ч
#           -OriginalDateFragment   ��ʾ��ʼ����Ƭ�Σ���IcmpType��Ϊdestination_unreachable��
#                                   parameter_problem��redirect��source_quench��time_exceededʱ��Ч
#                                   Ĭ��Ϊ0000000000000000
#           -GatewayInternetAdd    ��ʾ����IP��ַ����IcmpType��Ϊredirectʱ��Ч��Ĭ��Ϊ192.0.0.1
#           -Pointer               ��ʾָ�룬��IcmpType��Ϊparameter_problemʱ��Ч��Ĭ��Ϊ0
#           -Identifier            ��ʾ��ʶ����Ĭ��Ϊ 0
#           -OriginateTimeStamp    ��ʾ��ʼʱ�������IcmpType��Ϊtimestamp_request��timestamp_replyʱ��Ч��Ĭ��Ϊ0
#           -ReceiveTimeStamp      ��ʾ����ʱ�������IcmpType��Ϊtimestamp_request��timestamp_replyʱ��Ч��Ĭ��Ϊ0
#           -TransmitTimeStamp     ��ʾ����ʱ�������IcmpType��Ϊtimestamp_request��timestamp_replyʱ��Ч��Ĭ��Ϊ0
#        ARP
#           -operation    ָ�� arp �������ͣ���ѡֵΪ request,reply��Ĭ��Ϊrequest
#           -sourceHardwareAddr   ָ�� arp �����е� sender hardware address��Ĭ��Ϊ00:00:01:00:00:02
#           -sourceHardwareAddrMode  ָ�� sourceHardwareAddr �ı仯��ʽ����ѡֵΪ��fixed��incr��decr��Ĭ��Ϊfixed
#           -sourceHardwareAddrRepeatCount  ָ�� sourceHardwareAddr �ı仯������Ĭ��Ϊ1
#           -sourceHardwareAddrRepeatStep   ָ�� sourceHardwareAddr �ı仯������Ĭ��Ϊ00-00-00-00-00-01
#           -destHardwareAddr    ָ�� arp �����е� target hardware address��Ĭ��Ϊ00:00:01:00:00:02
#           -destHardwareAddrMode ָ�� destHardwareAddr �ı仯��ʽ����ѡֵΪ��fixed��incr��decr��Ĭ��Ϊfixed
#           -destHardwareAddrRepeatCount  ָ�� destHardwareAddr �ı仯������ Ĭ��Ϊ1
#           -destHardwareAddrRepeatStep   ָ�� destHardwareAddr �ı仯������Ĭ��Ϊ00-00-00-00-00-01
#           -sourceProtocolAddr   ָ�� arp �����е� sender ip address��Ĭ��Ϊ192.85.1.2
#           -sourceProtocolAddrMode  ָ�� sourceProtocolAddr �仯��ʽ����ѡֵΪ fixed��incr��decr��Ĭ��Ϊfixed
#           -sourceProtocolAddrRepeatCount  ָ�� sourceProtocolAddr �仯������Ĭ��Ϊ1
#           -sourceProtocolAddrRepeatStep    ָ�� sourceProtocolAddr �仯������Ĭ��Ϊ0.0.0.1
#           -destProtocolAddr   ָ�� arp �����е� tartget ip address��Ĭ��Ϊ192.85.1.2
#           -destProtocolAddrMode ָ�� destProtocolAddr �仯��ʽ����ѡֵΪ fixed��incr��decr��Ĭ��Ϊfixed
#           -destProtocolAddrRepeatCount  ָ�� destProtocolAddr �仯������Ĭ��Ϊ1
#           -destProtocolAddrRepeatStep  ָ�� destProtocolAddr �仯������Ĭ��Ϊ0.0.0.1
#        Custom
#            -HexString  ָ�����ݰ�����,Ĭ��Ϊ"aaaa"
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess   $msg        ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg   ��ʾ���ú���ʧ��
#    ����ֵ                               ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::SetupPacket {packetName packetType args} {

	set log [LOG::init TestCenter_SetupPacket]
	set errMsg ""

	foreach once {once} {
		# ������packetName�Ƿ�Ϊ��
		if {$packetName == ""} {
			set errMsg "packetNameΪ�գ��޷��������������ݱ��ı��Ķ���."
			break
		}

		# ������packetType�Ƿ�Ϊ��
		if {$packetType == ""} {
			set errMsg "packetTypeΪ�գ��޷��������������ݱ��ı��Ķ���."
			break
		}

		# �ж�PacketBuilder�����Ƿ���ڣ���������ڣ����½�һ����Ϊpacket1�Ķ���
		set tmpInfo [array get TestCenter::object "packet1"]
		if {$tmpInfo == ""} {
			LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: PacketBuilder packet1"
			# ����PacketBuilder����
			if {[catch {set packetObject [PacketBuilder packet1]} err ] == 1} {
				set errMsg "����packet�������쳣��������ϢΪ: $err ."
				break
			}
			if {[string match $packetObject "packet1"] != 1} {
				set errMsg "����packet����ʧ�ܣ�����ֵΪ:$packetObject ."
				break
			}
			set TestCenter::object($packetObject) $packetObject
		}

		# �ж�packetName�Ƿ��Ѵ��ڣ�������ڣ������Դ���ͬ���Ķ���
		set tmpInfo [array get TestCenter::object $packetName]
		if {$tmpInfo != ""} {
			set errMsg "$packetName�Ѿ��������������Դ���ͬ���Ķ���"
		} else {
			# �齨����packet������
			set tmpSubCmd ""
			append tmpSubCmd Create $packetType Pkt
			set tmpCmd "packet1 $tmpSubCmd -PduName $packetName"
		}

		if {$args != ""} {
			for {set i 0} {$i<10} {incr i} {
				if {[llength $args] == 1} {
					set args [lindex $args 0]
				} else {
					break
				}
			}
			foreach {option value} $args {
				lappend tmpCmd $option $value
			}
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		# ִ������
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "����$packetName �����쳣,������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "����$packetName ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "����$packetName �ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::AddPDUToStream {streamName PduList}
#Description:   ��PDUList�е�PDU��ӽ�streamName��
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    streamName     ָ��Ҫ���PDU��steam����
#    PduList        ��ʾ��Ҫ��ӵ�streamName�е�PDU�б�
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg   ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::AddPDUToStream {streamName PduList} {

	set log [LOG::init TestCenter_AddPDUToStream]
	set errMsg ""

	foreach once {once} {

		# ������PduList�Ƿ�Ϊ��
		if {$PduList == ""} {
			set errMsg "PduListΪ�գ��޷����PDU."
			break
		}
		# ȥ��PduList������б��{}
		for {set i 0} {$i<10} {incr i} {
			if {[llength $PduList] == 1} {
				set PduList [lindex $PduList 0]
			} else {
				break
			}
		}

		# ������PduList�е�Ԫ���Ƿ�Ϸ�
		#set pduValid 1
		#foreach pdu $PduList {
		#	set tmpInfo [array get TestCenter::object $pdu]
		#	if {$tmpInfo == ""} {
		#		set pduValid 0
		#		break
		#	}
		#}
		#if {$pduValid == 0} {
		#	set errMsg "PduList�е�ĳЩ���󲻴��ڣ��޷����PDU."
		#	break
		#}

		# �ж�streamName�Ƿ��Ѵ��ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $streamName]
		if {$tmpInfo != ""} {
			if {[llength $PduList] == 1} {
				set tmpPduList $PduList
			} else {
				set tmpPduList [list $PduList]
			}

			set tmpCmd "$streamName AddPdu -PduName $tmpPduList"
		} else {
			set errMsg "$streamName ��δ�������޷����PDU��"
			break
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "$streamName ���$PduList �����쳣,������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "$streamName ���$PduList ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "$streamName ���$PduList �ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::ClearTestResult {portOrStream {nameList ""}}
#Description:   ���㵱ǰ�Ĳ���ͳ�ƽ��
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#       portOrStream: ָ��������˿ڵ�ͳ�ƽ������stream��ͳ�ƽ��,���������е�ͳ�ƽ����ȡֵ��ΧΪ port | stream | all
#       nameList: ��ʾ�˿���list����stream��list�����Ϊ�գ���ʾ�������н��
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg   ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::ClearTestResult {portOrStream {nameList ""}} {

	set log [LOG::init TestCenter_ClearTestResult]
	set errMsg ""

	foreach once {once} {
		# ����֮ǰ������chassis1�����ͷ���Դ
		if {$::TestCenter::chassisObject == ""} {
			set errMsg "chassis1���󲻴��ڣ��޷�����ͳ�ƽ�� ."
			break
		}

		# ����portOrStream��namelist�����齨��ͬ������
		if {$portOrStream == "port"} {
			if {$nameList == ""} {

				set tmpCmd "$::TestCenter::chassisObject ClearTestResults -portnamelist All"
			} else {
				# ȥ��nameList������б��{}
				for {set i 0} {$i<10} {incr i} {
					if {[llength $nameList] == 1} {
						set nameList [lindex $nameList 0]
					} else {
						break
					}
				}

				set nameList [list $nameList]

				set tmpCmd "$::TestCenter::chassisObject ClearTestResults -portnamelist $nameList"

			}

		} elseif {$portOrStream == "stream"} {
			if {$nameList == ""} {

				set tmpCmd "$::TestCenter::chassisObject ClearTestResults -streamnamelist All"
			} else {
				# ȥ��nameList������б��{}
				for {set i 0} {$i<10} {incr i} {
					if {[llength $nameList] == 1} {
						set nameList [lindex $nameList 0]
					} else {
						break
					}
				}

				set nameList [list $nameList]

				set tmpCmd "$::TestCenter::chassisObject ClearTestResults -streamnamelist $nameList"
			}

		} elseif {$portOrStream == "all"} {
			set tmpCmd "$::TestCenter::chassisObject ClearTestResults"
		}

		if {$nameList == ""} {
			if {$portOrStream == "stream"} {
				set nameList "����stream"
			} elseif {$portOrStream == "port"} {
				set nameList "����port"
			} elseif {$portOrStream == "all"} {
				set nameList "����"
			}
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "���� $nameList ��ͳ�ƽ�������쳣,������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "���� $nameList ��ͳ�ƽ��ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "���� $nameList ��ͳ�ƽ���ɹ���"

		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::RemovePDUFromStream {streamName PduList}
#Description:   ��PDUList�е�PDU��streamName���Ƴ�
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    streamName     ָ��Ҫ�Ƴ�PDU��steam����
#    PduList        ��ʾ��Ҫ�Ƴ���PDU�б�
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg   ��ʾ���ú���ʧ��
#    ����ֵ                                ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::RemovePDUFromStream {streamName PduList} {

	set log [LOG::init TestCenter_AddPDUToStream]
	set errMsg ""

	foreach once {once} {
		# ������PduList�Ƿ�Ϊ��
		if {$PduList == ""} {
			set errMsg "PduListΪ�գ��޷��Ƴ�PDU."
			break
		}

		# ȥ��PduList������б��{}
		for {set i 0} {$i<10} {incr i} {
			if {[llength $PduList] == 1} {
				set PduList [lindex $PduList 0]
			} else {
				break
			}
		}

		# ������PduList�е�Ԫ���Ƿ�Ϸ�
		set pduValid 1
		foreach pdu $PduList {
			set tmpInfo [array get TestCenter::object $pdu]
			if {$tmpInfo == ""} {
				set pduValid 0
				break
			}
		}
		if {$pduValid == 0} {
			set errMsg "PduList�е�ĳЩ���󲻴��ڣ��޷��Ƴ�PDU."
			break
		}

		# �ж�streamName�Ƿ��Ѵ��ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $streamName]
		if {$tmpInfo != ""} {
			set tmpCmd "$streamName RemovePdu -PduName $PduList"
		} else {
			set errMsg "$streamName ��δ�������޷��Ƴ�PDU��"
			break
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "$streamName �Ƴ�$PduList �����쳣,������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "$streamName �Ƴ�$PduList ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "$streamName �Ƴ�$PduList �ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]

}


#*******************************************************************************
#Function:    ::TestCenter::SetupFilter {portName filterName filterType filterValue {filterOnStreamId FALSE}}
#Description:   ��ָ���˿ڴ��������ù�����������������Ѵ��ڣ������������ԣ���������ڣ�
#               ���ȴ���һ���µĹ�������������������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName   ��ʾ��Ҫ���������ù������Ķ˿���
#    filterName ��ʾ��Ҫ���������õĹ�������
#    filterType ��ʾ�������������� UDF ����Stack
#    filtervalue ��ʾ�����������ֵ����ʽΪ{{FilterExpr1}{FilterExpr2}��}
#         ��FilterTypeΪStackʱ��FilterExpr �ĸ�ʽΪ��
#              -ProtocolField ProtocolField -min min -max max -mask mask
#              -ProtocolField: ָ������Ĺ����ֶΣ���ѡ������ProtocolField �ľ�������ֶμ�˵�����£�
#                  srcMac   Դ MAC ��ַ
#                  dstMac   Ŀ�� MAC ��ַ
#                  Id        VLAN ID
#                  Pri       VLAN ���ȼ�
#                  srcIp     Դ IP ��ַ
#                  dstIp     Ŀ�� IP��ַ
#                  tos       Ipv4��tos�ֶ�
#                  pro       Ipv4Э���ֶ�
#                  srcPort   TCP��UDPЭ��Դ�˿ں�
#                  dstPort   TCP��UDPЭ��Դ�˿ں�
#              -min��ָ�������ֶε���ʼֵ����ѡ����
#              -max:ָ�������ֶε����ֵ����ѡ��������δָ����Ĭ��ֵΪ min
#              -mask��ָ�������ֶε�����ֵ����ѡ������ȡֵ�������ֶ���ء�
#         ��FilterTypeΪUDFʱ��FilterExpr �ĸ�ʽΪ��
#              -pattern pattern -offset offset  -max max -mask mask
#              -Pattern����ʾ����ƥ��ֵ�� 16 ���ơ���ѡ����������0x0806
#              -max�� ��ʾƥ������ֵ��16���ơ���ѡ����Ĭ����Pattern��ͬ
#              -Offset����ʾƫ��ֵ����ѡ������Ĭ��ֵΪ 0����ʼλ�ôӰ��ĵ�һ���ֽ���
#              -Mask����ʾ����ֵ, 16 ����.��ѡ������Ĭ��ֵΪ�� pattern������ͬ��ȫ f������ 0xffff
#       filterOnStreamId  ��ʾ�Ƿ�ʹ��StreamId���й��ˣ�����������
#                          ��ȡ����ʵʱͳ�ƱȽ���Ч��ȡֵ��ΧΪTRUE/FALSE��Ĭ��ΪFALSE
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg   ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::SetupFilter {portName filterName filterType filterValue {filterOnStreamId FALSE}} {

	set log [LOG::init TestCenter_SetupFilter]
	set errMsg ""

	foreach once {once} {
		# ������portNameָ���Ķ˿ڶ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $portName]
		if {$tmpInfo == ""} {
			set errMsg "$portName�����ڣ��޷����������ù���������."
			break
		}

		# ������filterName�Ƿ�Ϊ��
		if {$filterName == ""} {
			set errMsg "filterNameΪ�գ��޷����������ù���������."
			break
		}

		set tmpFilterValue [list $filterValue]

		# �ж�filterName�Ƿ��Ѵ��ڣ�������ڣ��޸��������ԣ������½�filter����������������
		set tmpInfo [array get TestCenter::object $filterName]
		if {$tmpInfo != ""} {
			# ����filter
			set tmpCmd "$portName ConfigFilter -FilterName $filterName -FilterType $filterType \
			            -Filtervalue $tmpFilterValue -FilterOnStreamId $filterOnStreamId"
		} else {
			# ����filter
			set tmpCmd "$portName CreateFilter -FilterName $filterName -FilterType $filterType \
			            -Filtervalue $tmpFilterValue -FilterOnStreamId $filterOnStreamId"
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "$portName ����$filterName �����쳣,������ϢΪ:$err ."
			break
		}
		if {$res == 0} {
			set TestCenter::object($filterName) $filterName
		} else {
			set errMsg "$portName ����$filterName ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "$portName ����$filterName �ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]

}


#*******************************************************************************
#Function:    ::TestCenter::SetupStaEngine {portName staEngineName staEngineType}
#Description:   ��ָ���˿ڴ���ͳ�Ʒ�������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName          ��ʾ��Ҫ����ͳ�Ʒ�������Ķ˿���
#    staEngineName     ��ʾ��Ҫ������ͳ�Ʒ������������
#    staEmgomeType     ��ʾ������StaEngine ������ ��ѡֵStatistics, Analysis��
#                      Statistics��Ҫ���ڽ��ͳ�ƣ���Analysis��Ҫ����ץ������
#                      Ĭ��ΪStatistics

#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:    ��
#*******************************************************************************
proc ::TestCenter::SetupStaEngine {portName staEngineName {staEngineType "Statistics"}} {

	set log [LOG::init TestCenter_SetupStaEngine]
	set errMsg ""

	foreach once {once} {
		# ������portNameָ���Ķ˿ڶ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $portName]
		if {$tmpInfo == ""} {
			set errMsg "$portName�����ڣ��޷�����ͳ�Ʒ�������."
			break
		}

		# ������staEngineName�Ƿ�Ϊ��
		if {$staEngineName == ""} {
			set errMsg "staEngineNameΪ�գ��޷�����ͳ�Ʒ�������."
			break
		}

		# �ж�staEngineName�Ƿ��Ѵ��ڣ�������ڣ��򷵻�ʧ��
		set tmpInfo [array get TestCenter::object $staEngineName]
		if {$tmpInfo != ""} {
			set errMsg "$staEngineName�Ѿ����ڣ����ܴ���ͬ������."
			break
		} else {
			# ����staEngineName
			set tmpCmd "$portName CreateStaEngine -StaEngineName $staEngineName -staType $staEngineType"
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $tmpCmd"
		if {[catch {set res [eval $tmpCmd]} err] == 1} {
			set errMsg "$portName ����$staEngineName �����쳣,������ϢΪ:$err ."
			break
		}
		if {$res == 0} {
			set TestCenter::object($staEngineName) $staEngineName
		} else {
			set errMsg "$portName ����$staEngineName ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "$portName ����$staEngineName �ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]

}


#*******************************************************************************
#Function:    ::TestCenter::StartStaEngine {portName }
#Description:   ��ָ���˿ڿ���ͳ�Ʒ�������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName   ��ʾ��Ҫ����ͳ������Ķ˿���
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg   ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::StartStaEngine {portName} {

	set log [LOG::init TestCenter_StartStaEngine]
	set errMsg ""

	foreach once {once} {
		# ������portNameָ���Ķ˿ڶ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $portName]
		if {$tmpInfo == ""} {
			set errMsg "$portName�����ڣ��޷�����ͳ�Ʒ�������."
			break
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $portName StartStaEngine"
		# ����ָ���˿ڵ�ͳ������
		if {[catch {set res [$portName StartStaEngine]} err] == 1} {
			set errMsg "����$portName ��ͳ�����淢���쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "����$portName ��ͳ������ʧ�ܣ�����ֵΪ:$res ."
			break
		}
		set errMsg "$portName ����ͳ�Ʒ�������ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]

}


#*******************************************************************************
#Function:    ::TestCenter::StopStaEngine {portName }
#Description:   ��ָ���˿�ֹͣͳ������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName   ��ʾ��Ҫֹͣͳ������Ķ˿���
#
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg    ��ʾ���ú���ʧ��
#    ����ֵ                                         ��ʾʧ��
#
#Others:         ��
#*******************************************************************************
proc ::TestCenter::StopStaEngine {portName} {

	set log [LOG::init TestCenter_StopStaEngine]
	set errMsg ""

	foreach once {once} {
		# ������portNameָ���Ķ˿ڶ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $portName]
		if {$tmpInfo == ""} {
			set errMsg "$portName�����ڣ��޷�ֹͣͳ�Ʒ�������."
			break
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $portName StopStaEngine"
		# ָֹͣ���˿ڵ�ͳ������
		if {[catch {set res [$portName StopStaEngine]} err] == 1} {
			set errMsg "ֹͣ$portName ��ͳ�����淢���쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "ֹͣ$portName ��ͳ������ʧ�ܣ�����ֵΪ:$res ."
			break
		}
		set errMsg "$portName ֹͣͳ�Ʒ�������ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]

}


#*******************************************************************************
#Function:    ::TestCenter::PortStartTraffic {chassisName {portList ""} { clearStatistic "1"} { flagArp "TRUE" } }
#Description:   ���ƶ˿ڽ��з���
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    chassisName     ��ʾ�����˿���������Ļ��������
#    portList        ��ʾ��Ҫ�����Ķ˿ڵĶ˿����б�Ϊ�ձ�ʾ���ж˿� ��Ĭ��Ϊ��
#    clearStatistic  ��ʾ�Ƿ�����˿ڵ�ͳ�Ƽ�����Ϊ1�������Ϊ0�������,Ĭ��Ϊ1
#    flagArp         ��ʾ�Ƿ����ARPѧϰ��ΪTRUE, ���У�ΪFLASE�������У�Ĭ��ΪTRUE
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::PortStartTraffic {chassisName {portList ""} {clearStatistic "1"} {flagArp "TRUE"} } {

	set log [LOG::init TestCenter_PortStartTraffic]
	set errMsg ""

	foreach once {once} {
		# ������chassisNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		if {$::TestCenter::chassisObject != $chassisName} {
			set errMsg "$chassisName�����ڣ��޷���������."
			break
		}

		# ����portList�Ƿ�Ϊ�գ��齨��ͬ���ƿ�ʼ����������
		if {$portList != ""} {
			# ȥ��portList������б��
			for {set i 0} {$i<10} {incr i} {
				if {[llength $portList] == 1} {
					set portList [lindex $portList 0]
				} else {
					break
				}
			}
			# ת��portListΪ�б�
			if {[llength $portList] == 1} {
				set tmpPortList $portList
			} else {
				set tmpPortList [list $portList]
			}

			set cmd "$chassisName StartTraffic -PortList $tmpPortList -ClearStatistic $clearStatistic -FlagArp $flagArp"
		} else {
			set cmd "$chassisName StartTraffic -ClearStatistic $clearStatistic -FlagArp $flagArp"
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $cmd"
		# port��ʼ����
		if {[catch {set res [eval $cmd]} err] == 1} {
			set errMsg "����port���������쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "����port����ʧ�ܣ�����ֵΪ:$res ."
			break
		}
		set errMsg "����port�����ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::PortStopTraffic {chassisName portList}
#Description:   ���ƶ˿�ֹͣ����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    chassisName   ��ʾ�����˿���������Ļ��������
#    portList      ��ʾ��Ҫֹͣ�����Ķ˿ڵĶ˿����б�Ϊ�ձ�ʾ���ж˿ڣ�Ĭ��Ϊ��
#Output:   ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg   ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:    ��
#*******************************************************************************
proc ::TestCenter::PortStopTraffic {chassisName {portList ""}} {

	set log [LOG::init TestCenter_PortStopTraffic]
	set errMsg ""

	foreach once {once} {
		# ������chassisNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		if {$::TestCenter::chassisObject != $chassisName} {
			set errMsg "$chassisName�����ڣ��޷�ͣ�ڷ���."
			break
		}

		# ����portList�Ƿ�Ϊ�գ��齨��ͬ����ֹͣ����������
		if {$portList != ""} {
			for {set i 0} {$i<10} {incr i} {
				if {[llength $portList] == 1} {
					set portList [lindex $portList 0]
				} else {
					break
				}
			}
			if {[llength $portList] == 1} {
				set tmpPortList $portList
			} else {
				set tmpPortList [list $portList]
			}
			set cmd "$chassisName StopTraffic -PortList $tmpPortList"
		} else {
			set cmd "$chassisName StopTraffic"
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $cmd"
		# ֹͣport����
		if {[catch {set res [eval $cmd]} err] == 1} {
			set errMsg "ֹͣport���������쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "ֹͣport����ʧ�ܣ�����ֵΪ:$res ."
			break
		}
		set errMsg "ֹͣport�����ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::StreamStartTraffic {portName { clearStatistic "1"} {flagArp "TRUE" } {streamList ""}}
#Description:   ����stream���з���
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName        ��ʾ����stream�����˿ڵĶ˿ڶ�����
#    clearStatistic  ��ʾ�Ƿ�����˿ڵ�ͳ�Ƽ�����Ϊ1�������Ϊ0���������Ĭ��Ϊ1
#    flagArp         ��ʾ�Ƿ����ARPѧϰ��ΪTRUE, ���У�ΪFLASE�������У�Ĭ��ΪTRUE
#    streamList      ��ʾ��Ҫ������stream�������б�Ϊ�ձ�ʾ�ö˿���������,Ĭ��Ϊ��
#
#Output:  ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::StreamStartTraffic {portName {clearStatistic "1"} {flagArp "TRUE"} {streamList ""}} {

	set log [LOG::init TestCenter_StreamStartTraffic]
	set errMsg ""

	foreach once {once} {
		# ������portNameָ���Ķ˿ڶ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $portName]
		if {$tmpInfo == ""} {
			set errMsg "$portName�����ڣ��޷���������."
			break
		}

		# ����streamList�Ƿ�Ϊ�գ��齨��ͬ���ƿ�ʼ����������
		if {$streamList != ""} {
			for {set i 0} {$i<10} {incr i} {
				if {[llength $streamList] == 1} {
					set streamList [lindex $streamList 0]
				} else {
					break
				}
			}

			if {[llength $streamList] == 1} {
				set tmpStreamList $streamList
			} else {
				set tmpStreamList [list $streamList]
			}

			set cmd "$portName StartTraffic -StreamNameList $tmpStreamList -ClearStatistic $clearStatistic -FlagArp $flagArp"
		} else {
			set cmd "$portName StartTraffic -ClearStatistic $clearStatistic -FlagArp $flagArp"
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $cmd"
		# stream��ʼ����
		if {[catch {set res [eval $cmd]} err] == 1} {
			set errMsg "����stream���������쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "����stream����ʧ�ܣ�����ֵΪ:$res ."
			break
		}
		set errMsg "����stream�����ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::StreamStopTraffic {portName streamList}
#Description:   ����streamֹͣ����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName       ��ʾ����stream�����˿ڵĶ˿ڶ�����
#    streamList     ��ʾ��Ҫֹͣ������stream�������б�Ϊ�ձ�ʾ�ö˿���������
#Output:    ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:    ��
#*******************************************************************************
proc ::TestCenter::StreamStopTraffic {portName {streamList ""}} {

	set log [LOG::init TestCenter_StreamStopTraffic]
	set errMsg ""

	foreach once {once} {
		# ������portNameָ���Ķ˿ڶ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $portName]
		if {$tmpInfo == ""} {
			set errMsg "$portName�����ڣ��޷�ֹͣ����."
			break
		}

		# ����streamList�Ƿ�Ϊ�գ��齨��ͬ����ֹͣ����������
		if {$streamList != ""} {
			for {set i 0} {$i<10} {incr i} {
				if {[llength $streamList] == 1} {
					set streamList [lindex $streamList 0]
				} else {
					break
				}
			}
			if {[llength $streamList] == 1} {
				set tmpStreamList $streamList
			} else {
				set tmpStreamList [list $streamList]
			}
			set cmd "$portName StopTraffic -StreamNameList $tmpStreamList"
		} else {
			set cmd "$portName StopTraffic"
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $cmd"
		# ֹͣstream����
		if {[catch {set res [eval $cmd]} err] == 1} {
			set errMsg "ֹͣstream���������쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "ֹͣstream����ʧ�ܣ�����ֵΪ:$res ."
			break
		}
		set errMsg "ֹͣstream�����ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::StartCapture {staEngineName {savePath ""} {filterName ""}}
#Description:   ���Ʒ������濪ʼ�����ģ����汨�ĵ�ָ��·����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    staEngineName   ��ʾ��Ҫ���������ĵķ���������
#    savePath        ��ʾ����ı��ı����·����������ò���Ϊ�գ�
#                    Ĭ�ϱ��浽C���£��Զ˿ں�����������:C:/port1.pap
#    filterName      ��ʾҪ���˱��汨��ʹ�õĹ����������֡�
#Output:         ��
# Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::StartCapture {staEngineName {savePath ""} {filterName ""}} {

	set log [LOG::init TestCenter_StartCapture]
	set errMsg ""

	foreach once {once} {
		# ������staEngineNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $staEngineName]
		if {$tmpInfo == ""} {
			set errMsg "$staEngineName�����ڣ��޷�����������."
			break
		}

		#���ݴ�������齨����
		if {$filterName != "" } {
			if {$savePath  != ""} {
				set cmd "$staEngineName ConfigCaptureMode -FilterName $filterName -CaptureFile $savePath"
			} else {
				set cmd "$staEngineName ConfigCaptureMode -FilterName $filterName"
			}
		} else {
			if {$savePath != ""} {
				set cmd "$staEngineName ConfigCaptureMode -CaptureFile $savePath"
			} else {
				set cmd  ""
			}
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $cmd"
		#���ñ��ı����·���͹�����
		if {$cmd != ""} {
			if {[catch {set res [eval $cmd]} err] == 1} {

				set errMsg "���ñ��ı����·���͹����������쳣��������ϢΪ:$err ."
				break
			}
			if {$res != 0} {
				set errMsg "���ñ��ı����·���͹�����ʧ�ܣ�����ֵΪ:$res ."
				break
			}
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $staEngineName StartCapture"
		#����������
		if {[catch {set res [$staEngineName StartCapture]} err] == 1} {
			set errMsg "���������ķ����쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "����������ʧ�ܣ�����ֵΪ:$res ."
			break
		}
		set errMsg "���������ĳɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::StopCapture {staEngineName}
#Description:    ֹͣ�������沶����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#      staEngineName   ��ʾ��Ҫֹͣ�����ĵķ���������
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg   ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:         ��
#*******************************************************************************
proc ::TestCenter::StopCapture {staEngineName} {

	set log [LOG::init TestCenter_StopCapture]
	set errMsg ""

	foreach once {once} {
		# ������staEngineNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $staEngineName]
		if {$tmpInfo == ""} {
			set errMsg "$staEngineName�����ڣ��޷��رղ�����."
			break
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $staEngineName StopCapture"
		# ֹͣ������
		if {[catch {set res [$staEngineName StopCapture]} err] == 1} {
			set errMsg "ֹͣ�����ķ����쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "ֹͣ������ʧ�ܣ�����ֵΪ:$res ."
			break
		}

		set errMsg "ֹͣ�����ĳɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::GetPortStats {staEngineName resultData {subOption ""} {filterStream "0"}}
#Description:   �Ӷ˿�ͳ����Ϣ�л�ȡָ����option����Ϣ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    staEngineName    ��ʾ��ȡͳ����Ϣ�Ķ˿ڵ�ͳ��������
#    filterStream     ��ʾ�Ƿ����ͳ�ƽ����Ϊ1�����ع��˹���Ľ��ֵ��Ϊ0�����ع���ǰ��ֵ
#    subOption        ��ʾ��Ҫ��ȡ��ͳ�ƽ�������������Ϊ�գ�����������Ϣ
#Output:
#    resultData    ���ػ�ȡ��ͳ�ƽ����Ϣ�����ָ���˹��ˣ��򷵻ع��˺��������Ϣ��
#                  ���ָ����subOption���򷵻�ָ�������Ϣ
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg   ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:  ��
#*******************************************************************************
proc ::TestCenter::GetPortStats {staEngineName resultData {filterStream "0"} {subOption ""}} {

	set log [LOG::init TestCenter_GetPortStats]
	set errMsg ""

	foreach once {once} {
		# ������staEngineNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $staEngineName]
		if {$tmpInfo == ""} {
			set errMsg "$staEngineName�����ڣ��޷���ȡ�˿�ͳ�ƽ��."
			break
		}

		# �󶨱��ر����ͷ���ֵ
		upvar 1 $resultData tmpResult

		# �ж��Ƿ��ȡ����ͳ�ƽ����Ϣ,ִ����Ӧ����
		if {$filterStream == 0} {
			set cmd "$staEngineName GetPortStats"
		} else {
			set cmd "$staEngineName GetPortStats -FilteredStream 1"
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $cmd"
		if {[catch {set result [eval $cmd]} err] == 1} {
			set errMsg "ͨ��$staEngineName ��ȡ�˿ڵ�ͳ��������Ϣ�����쳣��������ϢΪ:$err ."
			break
		}

		# ����subOptionָ�������Ϣ
		if {$result != ""} {
			if {$subOption != ""} {
				if {$filterStream == 0} {
					set index [lsearch -nocase $result -$subOption]
					if {$index != -1} {
						set tmpResult [lindex $result [expr $index + 1]]
					} else {
						set errMsg "��ͳ�ƽ���л�ȡ$subOption����Ϣʧ�ܣ�����ֵΪ:$result ."
						break
					}
				} else {
					set aggregateResult [lindex $result 0]

					set index [lsearch -nocase $aggregateResult -$subOption]
					if {$index != -1} {
						set tmpResult [lindex $aggregateResult [expr $index + 1]]
					} else {
						set errMsg "��ͳ�ƽ���л�ȡ$subOption����Ϣʧ�ܣ�����ֵΪ:$aggregateResult ."
						break
					}
				}
			} else {
				set tmpResult $result
			}
		} else {
			set errMsg "ͨ��$staEngineName ��ȡ�˿ڵ�ͳ��������Ϣʧ�ܣ�����ֵΪ:$result ."
			break
		}

		set errMsg "ͨ��$staEngineName ��ȡ�˿ڵ�ͳ��������Ϣ�ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::GetPortStatsSnapshot {staEngineName resultData {filterStream "0"} {resultPath ""}}
#Description:   ��ȡ�˿�ͳ����Ϣ����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    staEngineName    ��ʾ��ȡͳ����Ϣ�Ķ˿ڵ�ͳ��������
#    filterStream     ��ʾ�Ƿ����ͳ�ƽ����Ϊ1�����ع��˹���Ľ��ֵ��Ϊ0�����ع���ǰ��ֵ
#    resultPath      ��ʾͳ�ƽ�������·����������ò���Ϊ��,�򱣴浽Ĭ��·����
#Output:
#    resultData    ���ػ�ȡ��ͳ�ƽ����Ϣ�����ָ���˹��ˣ��򷵻ع��˺��������Ϣ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg   ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:  ��
#*******************************************************************************
proc ::TestCenter::GetPortStatsSnapshot {staEngineName resultData {filterStream "0"} {resultPath ""}} {

	set log [LOG::init TestCenter_GetPortStats]
	set errMsg ""

	foreach once {once} {
		# ������staEngineNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $staEngineName]
		if {$tmpInfo == ""} {
			set errMsg "$staEngineName�����ڣ��޷���ȡ�˿�ͳ�ƽ��."
			break
		}

		# �󶨱��ر����ͷ���ֵ
		upvar 1 $resultData tmpResult

		# �ж��Ƿ��ȡ����ͳ�ƽ����Ϣ,ִ����Ӧ����
		if {$filterStream == 0} {
			set cmd "$staEngineName GetPortStats -ResultPath $resultPath"
		} else {
			set cmd "$staEngineName GetPortStats -FilteredStream 1 -ResultPath $resultPath"
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $cmd"
		if {[catch {set result [eval $cmd]} err] == 1} {
			set errMsg "ͨ��$staEngineName ��ȡ�˿ڵ�ͳ��������Ϣ�����쳣��������ϢΪ:$err ."
			break
		}

		# �ж�result
		if {$result != ""} {
			if {$filterStream == 0} {
				set tmpResult $result
			} else {
				set tmpResult [lindex $result 0]
			}
		} else {
			set errMsg "ͨ��$staEngineName ��ȡ�˿ڵ�ͳ��������Ϣʧ�ܣ�����ֵΪ:$result ."
			break
		}

		set errMsg "ͨ��$staEngineName ��ȡ�˿ڵ�ͳ��������Ϣ�ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::GetStreamStats {staEngineName streamName resultData option }
#Description:   ��Streamͳ����Ϣ�л�ȡָ����option����Ϣ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    staEngineName   ��ʾ��ȡͳ����Ϣ�Ķ˿ڵ�ͳ��������
#    streamName      ��ʾ��Ҫͳ�Ƶ���������
#    subOption       ��ʾ��Ҫ��ȡ��ͳ�ƽ���������������Ϊ�գ���������������Ϣ
#Output:
#    resultData    ���ػ�ȡ��ͳ�ƽ����Ϣ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::GetStreamStats {staEngineName streamName resultData {subOption ""}} {

	set log [LOG::init TestCenter_GetStreamStats]
	set errMsg ""

	foreach once {once} {
		# ������staEngineNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $staEngineName]
		if {$tmpInfo == ""} {
			set errMsg "$staEngineName�����ڣ��޷���ȡ��ͳ�ƽ��."
			break
		}

		# �󶨱��ر����ͷ���ֵ
		upvar 1 $resultData tmpResult

		if {$subOption != ""} {
			# ��ȡ����ͳ����Ϣ�е�ָ���������Ϣ
			set cmd "$staEngineName GetStreamStats -StreamName $streamName -$subOption tmpResult"
			LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $cmd"
			if {[catch {set res [eval $cmd]} err] == 1} {
				set errMsg "��ȡ$streamName �е�$subOption ����Ϣ�����쳣��������ϢΪ:$err ."
				break
			}
			if {$res != 0} {
				set errMsg "��ȡ$streamName �е�$subOption ����Ϣʧ�ܣ�����ֵΪ:$res ."
				break
			}
		} else {
			# ��ȡ�������������ͳ����Ϣ
			set cmd "$staEngineName GetStreamStats -StreamName $streamName"
			LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $cmd"
			if {[catch {set tmpResult [eval $cmd]} err] == 1} {
				set errMsg "��ȡ$streamName �е�$subOption ����Ϣ�����쳣��������ϢΪ:$err ."
				break
			}
			if {$tmpResult == ""} {
				set errMsg "��ȡ$streamName �е�$subOption ����Ϣʧ�ܣ�����ֵΪ:$tmpResult ."
				break
			}
		}

		set errMsg "��ȡ$streamName �е�$subOption ����Ϣ�ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::GetStreamStatsSnapshot {staEngineName streamName resultData {resultPath ""}}
#Description:   ��ȡStreamͳ����Ϣ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    staEngineName   ��ʾ��ȡͳ����Ϣ�Ķ˿ڵ�ͳ��������
#    streamName      ��ʾ��Ҫͳ�Ƶ���������
#    resultPath      ��ʾͳ�ƽ�������·����������ò���Ϊ��,�򱣴浽Ĭ��·����
#Output:
#    resultData    ���ػ�ȡ��ͳ�ƽ����Ϣ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::GetStreamStatsSnapshot {staEngineName streamName resultData {resultPath ""}} {

	set log [LOG::init TestCenter_GetStreamStatsSnapshot]
	set errMsg ""

	foreach once {once} {
		# ������staEngineNameָ���Ķ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $staEngineName]
		if {$tmpInfo == ""} {
			set errMsg "$staEngineName�����ڣ��޷���ȡ��ͳ�ƽ��."
			break
		}

		# �󶨱��ر����ͷ���ֵ
		upvar 1 $resultData tmpResult

		# ��ȡ�������������ͳ����Ϣ
		set cmd "$staEngineName GetStreamStats -StreamName $streamName -ResultPath $resultPath"
		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $cmd"
		if {[catch {set tmpResult [eval $cmd]} err] == 1} {
			set errMsg "��ȡ$streamName ��ͳ����Ϣ���շ����쳣��������ϢΪ:$err ."
			break
		}
		if {$tmpResult == ""} {
			set errMsg "��ȡ$streamName ��ͳ����Ϣ����ʧ�ܣ�����ֵΪ:$tmpResult ."
			break
		}

		set errMsg "��ȡ$streamName ��ͳ����Ϣ���ճɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::SaveConfig { path}
#Description:  ���ű����ñ���Ϊxml�ļ�
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#       path  xml�ļ������·��
#Output:
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg   ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::SaveConfig {path} {

	set log [LOG::init TestCenter_SaveConfig]
	set errMsg ""

	LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: SaveConfigAsXML $path"
	if {[catch {SaveConfigAsXML $path} err] == 1} {

		set errMsg "�������õ�$path �ļ������쳣��������ϢΪ:$err ."
		LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
		return [list $TestCenter::FunctionExecuteError $errMsg]
	}

	set errMsg "�������õ�$path �ļ��ɹ���"
	return [list $TestCenter::ExpectSuccess $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::SetStreamSchedulingMode {portName {schedulingMode RATE_BASED}}
#Description:  ���ö˿����������ĵ���ģʽ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#       portName  �˿���
#       schedulingMode �������ĵ���ģʽ��ȡֵ��ΧΪ��PORT_BASED | RATE_BASED | PRIORITY_BASED��Ĭ��ΪRATE_BASED
#Output:
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg   ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::SetStreamSchedulingMode {portName {schedulingMode RATE_BASED}} {

	set log [LOG::init TestCenter_SetStreamSchedulingMode]
	set errMsg ""

	foreach once {once} {

		# ����֮ǰ������chassis1�������ö˿��������ĵ���ģʽ
		if {$::TestCenter::chassisObject == ""} {
			set errMsg "δ����TestCenter,�޷������������ĵ���ģʽ ."
			break
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $::TestCenter::chassisObject ConfigStreamSchedulingMode -portname $portName -schedulingmode $schedulingMode"
		if {[catch {set res [$::TestCenter::chassisObject ConfigStreamSchedulingMode -portname $portName -schedulingmode $schedulingMode]} err] == 1} {
			set errMsg "���ö˿�$portName���������ĵ���ģʽΪ$schedulingMode �����쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "���ö˿�$portName���������ĵ���ģʽΪ$schedulingMode ʧ�ܣ�������ϢΪ:$err ."
			break
		}

		set errMsg "���ö˿�$portName���������ĵ���ģʽΪ$schedulingMode �ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}

	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::CleanupTest { }
#Description:  ������ԣ��ͷ���Դ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:   ��
#Output:
#Return:
#    list $TestCenter::ExpectSuccess $msg          ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg   ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::CleanupTest {} {

	set log [LOG::init TestCenter_CleanupTest]
	set errMsg ""

	foreach once {once} {
		# ����֮ǰ������chassis1�����ͷ���Դ
		if {$::TestCenter::chassisObject == ""} {
			set errMsg "chassis1���󲻴��ڣ��޷��ͷ���Դ ."
			break
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $::TestCenter::chassisObject CleanupTest"
		if {[catch {set res [$::TestCenter::chassisObject CleanupTest]} err] == 1} {
			set errMsg "�ͷ���Դ�����쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "�ͷ���Դʧ�ܣ�������ϢΪ:$err ."
			break
		}

		# ��ձ������ı���
		set ::TestCenter::chassisObject ""
		array unset ::TestCenter::object
		array set ::TestCenter::object {}

		set errMsg "�ͷ���Դ�ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}

    LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::DestroyFilter { }
#Description:  ���ٹ���������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:   ��
#Output:
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError  $msg  ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::DestroyFilter {portName} {

	set log [LOG::init TestCenter_DestroyFilter]
	set errMsg ""

	foreach once {once} {
		# ������portNameָ���Ķ˿ڶ����Ƿ���ڣ���������ڣ�����ʧ��
		set tmpInfo [array get TestCenter::object $portName]
		if {$tmpInfo == ""} {
			set errMsg "$portName�����ڣ��޷����ٹ���������."
			break
		}

		LOG::DebugInfo $log [expr $[namespace current]::currentFileName] "RUN CMD: $portName DestroyFilter"
		# ����֮ǰ������portName�����ͷ���Դ
		if {[catch {set res [$portName DestroyFilter]} err] == 1} {
			set errMsg "���ٹ������������쳣��������ϢΪ:$err ."
			break
		}
		if {$res != 0} {
			set errMsg "���ٹ���������ʧ�ܣ�������ϢΪ:$err ."
			break
		}

		set errMsg "$portName ���ٹ���������ɹ���"
		return [list $TestCenter::ExpectSuccess $errMsg]
	}
	LOG::DebugErr $log [expr $[namespace current]::currentFileName] $errMsg
	return [list $TestCenter::FunctionExecuteError $errMsg]
}


#*******************************************************************************
#Function:    ::TestCenter::IsObjectExist { objectName }
#Description:  ���objectName�Ƿ����::TestCenter::object�����У����ڷ���1�������ڷ���0
#Calls:   ��
#Data Accessed:
#     ::TestCenter::object
#Data Updated:  ��
#Input:
#       objectName    ��ʾҪ���Ķ�����
#Output:
#Return:
#    1           ��ʾ����
#    0           ��ʾ������
#    ����ֵ      ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::TestCenter::IsObjectExist {objectName} {

	set tmpInfo [array get TestCenter::object $objectName]
	if {$tmpInfo == ""} {
		return 0
	} else {
		return 1
	}
}
