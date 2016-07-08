#***************************************************************************
#  Copyright (C), 2012-1, SHENZHEN GONGJIN ELECTRONICS. Co., Ltd.
#  ģ�����ƣ�ATTTestCenter
#  ģ�鹦�ܣ�����ĳЩ�ײ�ӿڹ��ܣ��ṩ�м����ýӿڣ�����ĳЩ�м����
#  ����: ATT��Ŀ������
#  �汾: V1.0
#  ����: 2013.02.27
#  �޸ļ�¼��
#      lana     created    2013-02-27
#
#***************************************************************************

# add project path to auto_path
set projectPath [file dirname [info script]]
lappend auto_path  $projectPath

if {[catch {

    # source testcenter pkgIndex.tcl
    set filepath [file join $projectPath "Source\\pkgIndexs.tcl"]
    source  $filepath
    puts "source TestCenter start_file successfully!"
    } err] == 1} {

    set msg "Source TestCenter �����ļ������쳣��������ϢΪ: $err ."
    puts $msg
    }

package require xmlrpc
package require LOG
package require TestCenter

set ::ATT_TESTCENTER_SUC 0
set ::ATT_TESTCENTER_FAIL -1


#ȫ�ֺ���: return proc name
proc ::__FUNC__ {args} {

    set procName ""

    if { [catch {

            set procName [lindex [info level -1] 0]
        }  err ] } {

            puts "Warning:__FUNC__: $err."
        }

    return [string trimleft $procName "::"]
}


package provide ::ATTTestCenter 1.0

namespace eval ::ATTTestCenter {


    set  __FILE__   ATTTestCenter.tcl
	set reservePort ""                  ;# ���ݳɹ�ԤԼ�Ķ˿�
    array set PortStatsSnapshot {}            ;# ���ڱ����ȡ���Ķ˿�ͳ�ƿ���
    array set StreamStatsSnapshot {}          ;# ���ڱ����ȡ����streamͳ�ƿ���

}


#*******************************************************************************
#Function:   ::ATTTestCenter::ConnectChassis {chassisAddr}
#Description:  ʹ�ø�����chassisAddr����TestCenter
#Calls:  ��
#Data Accessed:   ��
#Data Updated:  ��
#Input:
#      chassisAddr     ��ʾ�����ַ����������TestCenter��IP��ַ
#
#Output:   ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::ConnectChassis {chassisAddr } {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::ConnectChassis����TestCenter
		if {[catch {set res [TestCenter::ConnectChassis $chassisAddr]} err] == 1} {

			set msg "����TestCenter::ConnectChassis�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set nRet $::ATT_TESTCENTER_FAIL
			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:   ::ATTTestCenter::ReservePort {portLocation portName {portType "Ethernet"}}
#Description:  ԤԼ�˿ڣ���ԤԼ�˿�ʱ����Ҫָ���˿ڵ�λ�ã��˿ڵ����ֺͶ˿ڵ�����
#             �����ö˿�������·��Ҫʹ�õ�Э�����ͣ���ȡֵ��ΧΪ��Ethernet,Wan,Atm,LowRate
#Calls:  ��
#Data Accessed:   ��
#Data Updated:  ��
#Input:
#      portLocation     ��ʾ�˿ڵ�λ�ã��ɰ忨����˿ں���ɣ���'/'���ӡ�����ԤԼ1�Ű忨��1�Ŷ˿ڣ����� "1/1"
#      portName         ָ��ԤԼ�˿ڵı��������ں���Ըö˿ڵ�����������
#      portType         ָ��ԤԼ�Ķ˿����͡�Ĭ��Ϊ"Ethernet"
#
#Output:   ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::ReservePort {portLocation portName {portType "Ethernet"}} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::ReservePortԤԼ�˿�
		if {[catch {set res [TestCenter::ReservePort $portLocation $portName $portType]} err] == 1} {

			set msg "����TestCenter::ReservePort�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set nRet $::ATT_TESTCENTER_FAIL
			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

			# ���ݳɹ�ԤԼ�Ķ˿������Ա���������ʹ��
			lappend ::ATTTestCenter::reservePort $portName
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:   ::ATTTestCenter::ConfigPort {portName args}
#Description:  ����Ethernet�˿ڵ�����
#Calls:  ��
#Data Accessed:   ��
#Data Updated:  ��
#Input:
#      portName     ��ʾҪ���õĶ˿ڵ����֣�����Ķ˿�����ԤԼ�˿�ʱָ��������
#      args         ��ʾҪ���õĶ˿ڵ����Ե��б���ʽΪ{-options value ...},�˿ڵľ����������£�
#        -mediaType   ��ʾ�˿ڽ������ͣ�ȡֵ��ΧΪCOPPER��FIBER��Ĭ��ΪCOPPER
#        -linkSpeed   ��ʾ�˿����ʣ�ȡֵ��ΧΪ10M,100M,1G,10G,AUTO��Ĭ��ΪAUTO
#        -duplexMode  ��ʾ�˿ڵ�˫��ģʽ��ȡֵ��ΧΪFULL��HALF��Ĭ��ΪFULL
#        -autoNeg     ��ʾ�Ƿ����˿ڵ���Э��ģʽ��ȡֵ��ΧΪEnable��Disable��Ĭ��ΪEnable
#        -autoNegotiationMasterSlave ��ʾ��Э��ģʽ��ȡֵ��ΧΪMASTER,SLAVE��Ĭ��ΪMASTER
#        -flowControl ��ʾ�Ƿ����˿ڵ����ع��ܣ�ȡֵ��ΧΪON��OFF��Ĭ��ΪOFF
#        -mtuSize     ��ʾ�˿ڵ�MTU��Ĭ��Ϊ1500
#        -portMode    �����10G,ȡֵ��ΧΪLAN��WAN��Ĭ��ΪLAN
#
#Output:   ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::ConfigPort {portName args} {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::ConfigPort���ö˿ڵ�����
		if {[catch {set res [TestCenter::ConfigPort $portName $args]} err] == 1} {

			set msg "����TestCenter::ConfigPort�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set nRet $::ATT_TESTCENTER_FAIL
			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:   ::ATTTestCenter::GetPortState {portName state}
#Description:  ��ȡEthernet�˿ڵ�״̬��Ϣ�������˿ڵ�����״̬����·״̬����·���ʣ���·˫��״̬
#Calls:  ��
#Data Accessed:   ��
#Data Updated:  ��
#Input:
#      portName     ��ʾҪ��ȡ״̬�Ķ˿ڵ����֣�����Ķ˿�����ԤԼ�˿�ʱָ��������
#      state        ��ʾҪ��ȡ�˿ڵ���һ��״̬��ȡֵ��ΧΪ��PhyState,LinkState, LinkSpeed, DuplexMode
#
#Output:   ��
#Return:
#    $ATT_TESTCENTER_SUC  $state $msg ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL "err"  $msg ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::GetPortState {portName state} {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""
	set portStates ""
	set value "err"
	set tmpState -$state

	foreach once {once} {

		# ����::TestCenter::GetPortState��ȡ�˿�״̬��Ϣ
		if {[catch {set res [TestCenter::GetPortState $portName portStates]} err] == 1} {

			set msg "����TestCenter::GetPortState�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set nRet $::ATT_TESTCENTER_FAIL
			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
		}
		# ��ȡ��ѯ��״̬���ֵ,״̬����Բ����ִ�Сд
		set index [lsearch -nocase $portStates $tmpState]
		if {$index != -1} {

			set value [lindex $portStates [expr $index + 1]]
            set msg "��ȡ�˿�$portName ��$state ���Գɹ�����ֵΪ$value ��"
		} else {

			set nRet $::ATT_TESTCENTER_FAIL
			set msg "��֧�ֲ�ѯ״̬�� $state.��ȷ��ƴд�Ƿ���ȷ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
		}
	}

	return [list array [list [list int $nRet] [list string $value] [list string $msg] ]]
}


#*******************************************************************************
#Function:   ::ATTTestCenter::CreateProfile {portName profileName args}
#Description:    ����profile, profile�����õ����Կ�Ӧ���ڶ˿�
#Calls:   ��
#Data Accessed:    ��
#Data Updated:   ��
#Input:
#     portName      ��ʾ��Ҫ����profile�Ķ˿���������Ķ˿�����ԤԼ�˿�ʱָ��������
#     profileName   ��ʾ��Ҫ������profile���֣������ֿ����ں����profile����������
#     args          ��ʾprofile�����Բ���,��ʽΪ{-option value ...}.�������Բ������£�
#        -Type             ��ʾ�������ǳ����Ļ���ͻ���ģ�ȡֵ��ΧConstant/Burst��Ĭ��ΪConstant
#        -TrafficLoad      ��ʾ�����ĸ��ɣ���������ĵ�λ���ø�ֵ����Ĭ��Ϊ10
#        -TrafficLoadUnit  ��ʾ������λ��ȡֵ��Χfps/kbps/mbps/percent��Ĭ��ΪPercent
#        -BurstSize        ��ʾ��type��Burstʱ���������͵ı���������Ĭ��Ϊ1
#        -FrameNum         ��ʾһ�η��ͱ��ĵ����������typeΪburst��Ӧ����Ϊ BurstSize ������������Ĭ��Ϊ100
#        -Blocking         ��ʾ�Ƿ�������ģʽ��Enable/Disable����Ĭ��ΪDisable
#
#Output:    ��
# Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#Others:         ��
#*******************************************************************************
proc ::ATTTestCenter::CreateProfile {portName profileName args} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����portName����traffic��������portName_traffic
		set trafficName $portName\_traffic
		# ���traffic�����Ƿ��Ѵ���
		set isExistFlag [TestCenter::IsObjectExist $trafficName]
		if {$isExistFlag == 0} {
			# ����::TestCenter::CreateTraffic����Traffic����
			if {[catch {set res [TestCenter::CreateTraffic $portName $trafficName ] } err] == 1} {

				set msg "����TestCenter::CreateTraffic�����쳣��������ϢΪ: $err ."
				LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
				set nRet $::ATT_TESTCENTER_FAIL
				break
			}
			# �ж�ִ�н��
			if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

				set msg [lindex $res 1]
				LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
				set nRet $::ATT_TESTCENTER_FAIL
				break
			}
		}

		# ����::TestCenter::SetupTrafficProfile����profile
		if {[catch {set res [TestCenter::SetupTrafficProfile $trafficName $profileName $args ] } err] == 1} {

			set msg "����TestCenter::SetupTrafficProfile�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set nRet $::ATT_TESTCENTER_FAIL
			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "�ڶ˿�$portName ���� $profileName �ɹ���"
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::CreateEmptyStream {portName streamName args}
#Description:  �����������������������֣� ֡�����Լ����ʵ����ԣ�
#             �������ĵ�����ͨ�� ADD PDU �ķ�ʽ����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName     ��ʾ��Ҫ����stream�Ķ˿���������Ķ˿�����ԤԼ�˿�ʱָ��������
#    streamName   ��ʾ��Ҫ������stream�����֣������ֿ����ں����stream����������
#    args         ��ʾ������������б���ʽΪ{-option value ...}��������������������£�
#       -FrameLen   ָ������֡���ȣ���λΪbyte��Ĭ��Ϊ128
#       -StreamType ָ������ģ������; ȡֵ��ΧΪ:Normal,VPN,PPPoX DHCP��Ĭ��ΪNormal
#       -FrameLenMode ָ������֡���ȵı仯��ʽ��fixed | increment | decrement | random
#                     ��������Ϊrandomʱ������仯��ΧΪ:( FrameLen��FrameLen+ FrameLenCount-1)
#                     Ĭ��Ϊfixed
#       -FrameLenStep ��ʾ����֡���ȵı仯������Ĭ��Ϊ1
#       -FrameLenCount ��ʾ����֡���ȱ仯��������Ĭ��Ϊ1
#       -insertsignature ָ���Ƿ����������в���signature field��ȡֵ��true | false  Ĭ��Ϊtrue������signature field
#       -ProfileName     ָ��streamҪʹ�õ�Profile �����֣������profile������֮ǰ��������profile
#       -FillType        ָ��Payload����䷽ʽ��ȡֵ��ΧΪCONSTANT | INCR |DECR | PRBS��Ĭ��ΪCONSTANT
#       -ConstantFillPattern  ��FillTypeΪConstant��ʱ����Ӧ�����ֵ��Ĭ��Ϊ0
#       -EnableFcsErrorInsertion  ָ���Ƿ����CRC����֡��ȡֵ��ΧΪTRUE | FALSE��Ĭ��ΪFALSE
#       -EnableStream  ָ��modifierʹ��stream/flow����, ��ʹ��streamģʽʱ�����˿�stream�����ܳ���32k��
#                      ȡֵ��ΧTRUE | FALSE��Ĭ��ΪFALSE
#       -TrafficPattern ��Ҫ�������󶨵����Σ�ʹ��SrcPoolName�Լ�DstPoolNameʱ����
#                        ȡֵ��ΧΪPAIR | BACKBONE | MESH��Ĭ��ΪPAIR
#
#Output:    ��
# Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:    ��
#*******************************************************************************
proc ::ATTTestCenter::CreateEmptyStream {portName streamName args} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����portName����traffic��������portName_traffic
		set trafficName $portName\_traffic

		# ���traffic�����Ƿ��Ѵ���
		set isExistFlag [TestCenter::IsObjectExist $trafficName]
		if {$isExistFlag == 0} {
			# ����::TestCenter::CreateTraffic����Traffic����
			if {[catch {set res [TestCenter::CreateTraffic $portName $trafficName ] } err] == 1} {

				set msg "����TestCenter::CreateTraffic�����쳣��������ϢΪ: $err ."
				LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
				set nRet $::ATT_TESTCENTER_FAIL
				break
			}
			# �ж�ִ�н��
			if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

				set msg [lindex $res 1]
				LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
				set nRet $::ATT_TESTCENTER_FAIL
				break
			}
		}

		# ����::TestCenter::SetupStream������
		if {[catch {set res [TestCenter::SetupStream $trafficName $streamName $args ] } err] == 1} {

			set msg "����TestCenter::SetupStream�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set nRet $::ATT_TESTCENTER_FAIL
			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "�ڶ˿�$portName ���� $streamName �ɹ���"
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::CreateHeader {headerName headerType args}
#Description:   �������ݱ��ı�ͷPDU
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#      headerName     ��ʾ��Ҫ���������ݱ��ı�ͷ���֣������ֿ����ں���Ա�ͷPDU����������
#      headerType     ��ʾ��Ҫ���������ݱ��ı�ͷ���ͣ�ȡֵ��ΧΪ��
#                     Eth | Vlan | IPV4 | TCP | UDP | MPLS | IPV6 | POS | HDLC
#      args           ��ʾ�������ԵĲ����б���ʽΪ{-option value ...},����������ݱ�������������ͬ��
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��

#*******************************************************************************
proc ::ATTTestCenter::CreateHeader {headerName headerType args} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::SetupHeader����header pdu
		if {[catch {set res [TestCenter::SetupHeader $headerName $headerType $args]} err] == 1} {

			set msg "����TestCenter::SetupHeader�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set nRet $::ATT_TESTCENTER_FAIL
			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "����$headerName header�ɹ���"
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::CreatePacket {packetName packetType args}
#Description:   �������ݱ��ı���PDU
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    packetName     ָ����Ҫ���������ݱ��ı��Ķ�����,�����ֿ����ں���Ըñ���PDU����������
#    packetType     ��ʾ��Ҫ���������ݱ��ı������ͣ�ȡֵ��ΧΪ��
#                    DHCP | PIM | IGMP | PPPoE | ICMP | ARP | Custom
#    args           ��ʾ�������ԵĲ����б���ʽΪ{-option value ...},����������ݱ�������������ͬ��
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::CreatePacket {packetName packetType args} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::SetupPacket����packet PDU
		if {[catch {set res [TestCenter::SetupPacket $packetName $packetType $args]} err] == 1} {

			set msg "����TestCenter::SetupPacket�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set nRet $::ATT_TESTCENTER_FAIL
			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "����$packetName packet�ɹ���"
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::AddPDUToStream {streamName PduList}
#Description:   ��PDUList�е�PDU��ӽ�streamName��,�����pduָ����ǰ�洴����header��packet
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    streamName     ָ��Ҫ���PDU��steam����,�����streamName������ǰ���Ѿ������õ�stream����
#    PduList        ��ʾ��Ҫ��ӵ�streamName�е�PDU�б�
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::AddPDUToStream {streamName PduList} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::AddPDUToStream���PDU��stream��
		if {[catch {set res [TestCenter::AddPDUToStream $streamName $PduList]} err] == 1} {

			set msg "����TestCenter::AddPDUToStream�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set nRet $::ATT_TESTCENTER_FAIL
			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::ClearTestResult {portOrStream {nameList ""}}
#Description:   ���㵱ǰ�Ĳ���ͳ�ƽ��
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#       portOrStream: ָ��������˿ڵ�ͳ�ƽ������stream��ͳ�ƽ�������������е�ͳ�ƽ����ȡֵ��ΧΪ port | stream | all
#       nameList: ��ʾ�˿���list����stream��list�����Ϊ�գ���ʾ�������н��
#Output:         ��
#Return:
#    list $TestCenter::ExpectSuccess  $msg         ��ʾ�ɹ�
#    list $TestCenter::FunctionExecuteError $msg   ��ʾ���ú���ʧ��
#    ����ֵ                                        ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::ClearTestResult {portOrStream {nameList ""}} {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::ClearTestResult����ָ�������ͳ�ƽ��
		if {[catch {set res [TestCenter::ClearTestResult $portOrStream $nameList]} err] == 1} {

			set msg "����TestCenter::ClearTestResult�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set nRet $::ATT_TESTCENTER_FAIL
			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::CreateFilter {portName filterName filterType filterValue {filterOnStreamId FALSE}}
#Description:   ��ָ���˿ڴ���������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName   ��ʾ��Ҫ�����������Ķ˿���������Ķ˿�����ԤԼ�˿�ʱָ��������
#    filterName ��ʾ��Ҫ�����Ĺ�������
#    filterType ��ʾ�������������� UDF ����Stack
#    filterValue ��ʾ�����������ֵ����ʽΪ{{FilterExpr1}{FilterExpr2}��}
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
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::CreateFilter {portName filterName filterType filterValue {filterOnStreamId FALSE}} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::SetupFilter����������
		if {[catch {set res [TestCenter::SetupFilter $portName $filterName $filterType $filterValue $filterOnStreamId]} err] == 1} {

			set msg "����TestCenter::SetupFilter�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set nRet $::ATT_TESTCENTER_FAIL
			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "�ڶ˿�$portName ����$filterName �ɹ�!"
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::StartCapture {portName {savePath ""} {filterName ""}}
#Description:   ��ָ���Ķ˿��Ͽ�ʼץ�������汨�ĵ�ָ��·���£�
#              ���û�и�������·�����򱣴浽Ĭ��·����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName        ��ʾ��Ҫ���������ĵĶ˿���������Ķ˿�����ԤԼ�˿�ʱָ��������
#    savePath        ��ʾ����ı��ı����·����������ò���Ϊ�գ�
#                    �򱣴浽Ĭ��·����
#    filterName      ��ʾҪ���˱��汨��ʹ�õĹ�����������
#
#Output:         ��
# Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::StartCapture {portName {savePath ""} {filterName ""}} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����portName���ɷ�������Analysis��������portName_Analysis
		set AnalysisName $portName\_Analysis

		# ���Analysis�����Ƿ��Ѵ���
		set isExistFlag [TestCenter::IsObjectExist $AnalysisName]

		# Analysis���󲻴��ڣ������µĶ���
		if {$isExistFlag == 0} {
			# ����::TestCenter::SetupStaEngine����Analysis����
			if {[catch {set res [TestCenter::SetupStaEngine $portName $AnalysisName Analysis] } err] == 1} {

				set msg "����TestCenter::SetupStaEngine�����쳣��������ϢΪ: $err ."
				LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
				set nRet $::ATT_TESTCENTER_FAIL
				break
			}
			# �ж�ִ�н��
			if {[lindex $res 0] != $TestCenter::ExpectSuccess} {
				set msg [lindex $res 1]
				LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
				set nRet $::ATT_TESTCENTER_FAIL
				break
			}
		}

		# ����::TestCenter::StartCapture����ץ��
		if {[catch {set res [TestCenter::StartCapture $AnalysisName $savePath $filterName] } err] == 1} {

			set msg "����TestCenter::SetupStaEngine�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set nRet $::ATT_TESTCENTER_FAIL
			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "�˿�$portName �������Ĳ���ɹ�"
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::StopCapture {portName}
#Description:    ֹͣץ��
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#      portName   ��ʾ��Ҫֹͣ�����ĵĶ˿���������Ķ˿�����ԤԼ�˿�ʱָ��������
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:         ��
#*******************************************************************************
proc ::ATTTestCenter::StopCapture {portName} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����portName���ɷ�������Analysis��������portName_Analysis
		set AnalysisName $portName\_Analysis

		# ���Analysis�����Ƿ��Ѵ���
		set isExistFlag [TestCenter::IsObjectExist $AnalysisName]

		# Analysis���󲻴��ڣ�����ʧ��
		if {$isExistFlag == 0} {
			set msg "$portName �˿�δ����ץ��������ֹͣץ��."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}

		# ����::TestCenter::StopCaptureֹͣץ��
		if {[catch {set res [TestCenter::StopCapture $AnalysisName]} err] == 1} {

			set msg "����TestCenter::StopCapture�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set nRet $::ATT_TESTCENTER_FAIL
			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "�˿�$portName ֹͣ���Ĳ���ɹ�"
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::TrafficOnPort {{trafficTime 0} {flagArp "TRUE"} {portList ""}}
#Description:   ���ڶ˿ڿ�ʼ��������ָ��ʱ�������ֹͣ������
#              ���trafficTimeΪ0,�������������̷��أ����û�ֹͣ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    trafficTime     ��ʾ����ʱ�䣬��λΪs,Ĭ��Ϊ0
#    flagArp         ��ʾ�Ƿ����ARPѧϰ��ΪTRUE, ���У�ΪFLASE�������У�Ĭ��ΪTRUE
#    portList        ��ʾ����Ҫ�����Ķ˿�����ɵ��б�Ϊ�ձ�ʾ���ж˿� ��Ĭ��Ϊ��
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::TrafficOnPort {{trafficTime 0} {flagArp "TRUE"} {portList ""}} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ׼��ͳ������,����::ATTTestCenter::SetupStaEngine����������ͳ������
		if {[catch {set res [::ATTTestCenter::SetupStaEngine] } err] == 1} {

			set msg "����::ATTTestCenter::SetupStaEngine�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $::ATT_TESTCENTER_SUC} {
			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# ��ȡ��Ҫ�����Ķ˿�
		if { $portList != "" } {
			set tmpPortList $portList
		} else {
			set tmpPortList $::ATTTestCenter::reservePort
		}
		# ����::TestCenter::PortStartTraffic��ʼ����
		if {[catch {set res [TestCenter::PortStartTraffic "chassis1" $tmpPortList 1 $flagArp]} err] == 1} {

			set msg "����TestCenter::PortStartTraffic�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}

		# �жϷ���ʱ��,���Ϊ0�����̷��أ�����ȴ�������ʱ�䵽��ֹͣ����
		if {$trafficTime == 0} {
			set msg "���������ɹ�!"
			set nRet $::ATT_TESTCENTER_SUC
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
			break
		}

		# �ȴ�����
		set sendTime [expr $trafficTime * 1000]
		after $sendTime

		# ֹͣ����
		# ����::TestCenter::PortStopTrafficֹͣ����
		if {[catch {set res [TestCenter::PortStopTraffic "chassis1" $tmpPortList]} err] == 1} {

			set msg "����TestCenter::PortStopTraffic�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "�˿�$portList �����Ѿ��ɹ����!"
		}

	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::StopTrafficOnPort {portList}
#Description:   ���ƶ˿�ֹͣ����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portList      ��ʾ��Ҫֹͣ�����Ķ˿ڵĶ˿����б�Ϊ�ձ�ʾ���ж˿ڣ�Ĭ��Ϊ��
#
#Output:   ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:    ��
#*******************************************************************************
proc ::ATTTestCenter::StopTrafficOnPort {{portList ""}} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {
		# ��ȡ��Ҫֹͣ�����Ķ˿��б�
		if {$portList == ""} {
			set tmpPortList $::ATTTestCenter::reservePort
		} else {
			set tmpPortList $portList
		}

		# ����::TestCenter::PortStopTrafficֹͣ����
		if {[catch {set res [TestCenter::PortStopTraffic "chassis1" $tmpPortList]} err] == 1} {

			set msg "����TestCenter::PortStopTraffic�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "�˿�$portList ֹͣ�����ɹ�!"
		}
	}
	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::TrafficOnStream {portName {flagArp "TRUE" } {trafficTime 0} {streamList ""}}
#Description:   ������������ʼ��������ָ��ʱ�������ֹͣ���������ʱ��Ϊ0�����̷��أ����û�ֹͣ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName        ��ʾ����stream�����˿ڵĶ˿ڶ�����
#    flagArp         ��ʾ�Ƿ����ARPѧϰ��ΪTRUE, ���У�ΪFLASE�������У�Ĭ��ΪTRUE
#    trafficTime     ��ʾ����ʱ�䣬��λΪs��Ĭ��Ϊ0
#    streamList      ��ʾ��Ҫ������stream�������б�Ϊ�ձ�ʾ�ö˿���������,Ĭ��Ϊ��
#
#Output:  ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::TrafficOnStream {portName {flagArp "TRUE"} {trafficTime 0} {streamList ""}} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ׼��ͳ������,����::ATTTestCenter::SetupStaEngine����������ͳ������
		if {[catch {set res [::ATTTestCenter::SetupStaEngine] } err] == 1} {

			set msg "����::ATTTestCenter::SetupStaEngine�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $::ATT_TESTCENTER_SUC} {
			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}

		# ����::TestCenter::StreamStartTraffic��������
		if {[catch {set res [TestCenter::StreamStartTraffic $portName 1 $flagArp $streamList]} err] == 1} {

			set msg "����TestCenter::StreamStartTraffic�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}

		# �жϷ���ʱ��,���Ϊ0�����̷��أ�����ȴ�������ʱ�䵽��ֹͣ����
		if {$trafficTime == 0} {
			set msg "���������ɹ�!"
			set nRet $::ATT_TESTCENTER_SUC
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
			break
		}

		# �ȴ�����
		set sendTime [expr $trafficTime * 1000]
		after $sendTime

		# ֹͣ����
		# ����::TestCenter::StreamStopTrafficֹͣ����
		if {[catch {set res [TestCenter::StreamStopTraffic $portName $streamList]} err] == 1} {

			set msg "����TestCenter::StreamStopTraffic�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "�˿�$portName �ϵ������� $streamList �����Ѿ��ɹ����!"
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::StopTrafficOnStream {portName {streamList ""}}
#Description:   ����streamֹͣ����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName       ��ʾ����stream�����˿ڵĶ˿ڶ�����
#    streamList     ��ʾ��Ҫֹͣ������stream�������б�Ϊ�ձ�ʾ�ö˿���������
#
#Output:    ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:    ��
#*******************************************************************************
proc ::ATTTestCenter::StopTrafficOnStream {portName {streamList ""}} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::StreamStopTrafficֹͣ����
		if {[catch {set res [TestCenter::StreamStopTraffic $portName $streamList]} err] == 1} {

			set msg "����TestCenter::StreamStopTraffic�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "�˿�$portName �ϵ������� $streamList �ɹ�ֹͣ����!"
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::GetPortStatsSnapshot {portName {filterStream "0"} {resultPath ""}}
#Description:   ��ȡ�˿�ͳ����Ϣ����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName         ��ʾ��ȡͳ����Ϣ�Ķ˿���������Ķ˿�����ԤԼ�˿�ʱָ��������
#    filterStream     ��ʾ�Ƿ����ͳ�ƽ����Ϊ1�����ع��˹���Ľ��ֵ��Ϊ0�����ع���ǰ��ֵ
#    resultPath      ��ʾͳ�ƽ�������·����������ò���Ϊ��,�򱣴浽Ĭ��·����
#
#Output:   ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:  ��
#*******************************************************************************
proc ::ATTTestCenter::GetPortStatsSnapshot {portName {filterStream "0"} {resultPath ""}} {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����portName����ͳ������StaEngine��������portName_StaEngine
		set StaEngineName $portName\_StaEngine

		# ���StaEngine�����Ƿ����
		set isExistFlag [TestCenter::IsObjectExist $StaEngineName]

		# StaEngine���󲻴��ڣ�����ʧ��
		if {$isExistFlag == 0} {
			set msg "$portName �˿�δ�������������ܻ�ȡͳ�ƽ��."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}

		# ����::TestCenter::GetPortStatsSnapshot��ȡͳ����Ϣ
		set resultData ""
		if {[catch {set res [TestCenter::GetPortStatsSnapshot $StaEngineName resultData $filterStream $resultPath]} err] == 1} {

			set msg "����TestCenter::GetPortStatsSnapshot�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
            set ::ATTTestCenter::PortStatsSnapshot($portName) $resultData

            # set msg display to user
            set msg "��ȡ�˿�$portName ��ͳ�ƿ��ճɹ������Ϊ��$resultData"
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::GetStreamStatsSnapshot {portName streamName {resultPath ""}}
#Description:   ��ȡStreamͳ����Ϣ����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName        ��ʾ��ȡͳ����Ϣ�Ķ˿���������Ķ˿�����ԤԼ�˿�ʱָ��������
#    streamName      ��ʾ��Ҫͳ�Ƶ��������֣������stream�������Ǵ�������stream
#    resultPath      ��ʾͳ�ƽ�������·����������ò���Ϊ��,�򱣴浽Ĭ��·����
#
#Output:    ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::GetStreamStatsSnapshot {portName streamName {resultPath ""}} {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����portName����ͳ������StaEngine��������portName_StaEngine
		set StaEngineName $portName\_StaEngine

		# ���StaEngine�����Ƿ����
		set isExistFlag [TestCenter::IsObjectExist $StaEngineName]

		# StaEngine���󲻴��ڣ�����ʧ��
		if {$isExistFlag == 0} {
			set msg "$portName �˿�δ�������������ܻ�ȡͳ�ƽ��."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}

		# ����::TestCenter::GetStreamStatsSnapshot��ȡͳ����Ϣ
		set resultData ""

		if {[catch {set res [TestCenter::GetStreamStatsSnapshot $StaEngineName $streamName resultData $resultPath]} err] == 1} {

			set msg "����TestCenter::GetStreamStatsSnapshot�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            set ::ATTTestCenter::StreamStatsSnapshot($streamName) $resultData

            # set msg display to user
            set msg "��ȡ������$streamName ��ͳ�ƽ�����ճɹ������Ϊ��$resultData"
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::GetPortStats {portName {filterStream "0"} {subOption ""}}
#Description:   �Ӷ˿�ͳ����Ϣ�л�ȡָ����option����Ϣ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName         ��ʾ��ȡͳ����Ϣ�Ķ˿���������Ķ˿�����ԤԼ�˿�ʱָ��������
#    filterStream     ��ʾ�Ƿ����ͳ�ƽ����Ϊ1�����ع��˹���Ľ��ֵ��Ϊ0�����ع���ǰ��ֵ
#    subOption        ��ʾ��Ҫ��ȡ��ͳ�ƽ�������������Ϊ�գ�����������Ϣ
#
#Output:   ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:  ��
#*******************************************************************************
proc ::ATTTestCenter::GetPortStats {portName {filterStream "0"} {subOption ""}} {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""
	set resultData ""

	foreach once {once} {

        # �ж�portName�Ƿ����п���
        set tmpInfo [array get ::ATTTestCenter::PortStatsSnapshot $portName]
		if {$tmpInfo != ""} {
            # �Ѿ��п��գ�ֱ�Ӳ�������ֵ
            set result [lindex $tmpInfo 1]
			# ��ȡָ�������ֵ�����û��ָ�����������н��
            if {$subOption != ""} {

                set index [lsearch -nocase $result -$subOption]
                if {$index != -1} {

                    set resultData [lindex $result [expr $index + 1]]
                    set msg "��$portName ��ͳ�ƽ�������л�ȡ$subOption �ɹ�����ֵΪ$resultData ��"
                    LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
                } else {

                    set msg "��$portName ��ͳ�ƽ�������л�ȡ$subOption����Ϣʧ�ܣ�ͳ�ƽ������Ϊ:$result ."
                    LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                    set nRet $::ATT_TESTCENTER_FAIL
                    break
                }
			} else {

                set resultData $result
                set msg "��$portName ��ͳ�ƽ�������л�ȡ$subOption �ɹ�����ֵΪ$resultData ��"
                LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
			}
		} else {
            # ��û�п��գ���ȡʵʱ����ֵ

            # ����portName����ͳ������StaEngine��������portName_StaEngine
            set StaEngineName $portName\_StaEngine

            # ���StaEngine�����Ƿ����
            set isExistFlag [TestCenter::IsObjectExist $StaEngineName]

            # StaEngine���󲻴��ڣ�����ʧ��
            if {$isExistFlag == 0} {
                set msg "$portName �˿�δ�������������ܻ�ȡͳ�ƽ��."
                LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                set nRet $::ATT_TESTCENTER_FAIL
                break
            }

            # ����::TestCenter::GetPortStats��ȡͳ����Ϣ
            if {[catch {set res [TestCenter::GetPortStats $StaEngineName resultData $filterStream $subOption]} err] == 1} {

                set msg "����TestCenter::GetPortStats�����쳣��������ϢΪ: $err ."
                LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                set nRet $::ATT_TESTCENTER_FAIL
                break
            }
            # �ж�ִ�н��
            if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

                set msg [lindex $res 1]
                LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                set nRet $::ATT_TESTCENTER_FAIL
                break
            } else {

                set msg [lindex $res 1]
                LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

                # set msg display to user
                set msg "��ȡ�˿�$portName ��$subOption �ɹ�����ֵΪ$resultData ��"
            }
        }
	}

	return [list array [list [list int $nRet] [list string $resultData] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::GetStreamStats {portName streamName option}
#Description:   ��Streamͳ����Ϣ�л�ȡָ����option����Ϣ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName        ��ʾ��ȡͳ����Ϣ�Ķ˿���������Ķ˿�����ԤԼ�˿�ʱָ��������
#    streamName      ��ʾ��Ҫͳ�Ƶ��������֣������stream�������Ǵ�������stream
#    subOption       ��ʾ��Ҫ��ȡ��ͳ�ƽ���������������Ϊ�գ���������������Ϣ
#Output:    ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::GetStreamStats {portName streamName {subOption ""}} {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

        # �ж�streamName�Ƿ����п���
        set tmpInfo [array get ::ATTTestCenter::StreamStatsSnapshot $streamName]
		if {$tmpInfo != ""} {
            # �Ѿ��п��գ�ֱ�Ӳ�������ֵ
            set result [lindex $tmpInfo 1]
			# ��ȡָ�������ֵ�����û��ָ�����������н��
            if {$subOption != ""} {

                set index [lsearch -nocase $result -$subOption]
                if {$index != -1} {

                    set resultData [lindex $result [expr $index + 1]]
                    set msg "��$streamName ��ͳ�ƽ�������л�ȡ$subOption �ɹ�����ֵΪ$resultData ��"
                    LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
                } else {

                    set msg "��$streamName ��ͳ�ƽ�������л�ȡ$subOption����Ϣʧ�ܣ�ͳ�ƽ������Ϊ:$result ."
                    LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                    set nRet $::ATT_TESTCENTER_FAIL
                    break
                }
			} else {

                set resultData $result
                set msg "��$streamName ��ͳ�ƽ�������л�ȡ$subOption �ɹ�����ֵΪ$resultData ��"
                LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
			}
		} else {
            # ��û�п��գ���ȡʵʱ����ֵ

            # ����portName����ͳ������StaEngine��������portName_StaEngine
            set StaEngineName $portName\_StaEngine

            # ���StaEngine�����Ƿ����
            set isExistFlag [TestCenter::IsObjectExist $StaEngineName]

            # StaEngine���󲻴��ڣ�����ʧ��
            if {$isExistFlag == 0} {
                set msg "$portName �˿�δ�������������ܻ�ȡͳ�ƽ��."
                LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                set nRet $::ATT_TESTCENTER_FAIL
                break
            }

            # ����::TestCenter::GetStreamStats��ȡͳ����Ϣ
            set resultData ""

            if {[catch {set res [TestCenter::GetStreamStats $StaEngineName $streamName resultData $subOption ]} err] == 1} {

                set msg "����TestCenter::GetStreamStats�����쳣��������ϢΪ: $err ."
                LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                set nRet $::ATT_TESTCENTER_FAIL
                break
            }
            # �ж�ִ�н��
            if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

                set msg [lindex $res 1]
                LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                set nRet $::ATT_TESTCENTER_FAIL
                break
            } else {

                set msg [lindex $res 1]
                LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

                # set msg display to user
                set msg "��ȡ������$streamName ��$subOption �ɹ�����ֵΪ$resultData ��"
            }
        }
	}

	return [list array [list [list int $nRet] [list string $resultData] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::CreateHost {portName hostName args}
#Description:   ��ָ���˿ڴ���Host��������host������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName   ��ʾ��Ҫ����host�Ķ˿���������Ķ˿�����ԤԼ�˿�ʱָ��������
#    hostName   ��ʾ��Ҫ������host�����֡����������ں���Ը�host����������
#    args       ��ʾ��Ҫ������IGMP host�������б����ʽΪ{-option value}.host�������У�
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
#       -Increase         ָ��IP��ַ������Ĭ��Ϊ1
#       -FlagPing         ָ���Ƿ�֧��Ping���ܣ�enable/disable��Ĭ��Ϊenable
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::CreateHost {portName hostName args} {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""
	set IntName $portName

	foreach once {once} {

        # ȥ��args���{}
        if {[llength $args] == 1} {
            set args [lindex $args 0]
        }

        # �ж��Ƿ�Ҫ���vlan
        set index [lsearch -nocase $args -EnableVlan]
        if {$index != -1} {

            set EnableVlan [lindex $args [expr $index + 1]]
            set args [lreplace $args $index [expr $index + 1]]
        } else  {
            set EnableVlan disable
        }

        # ���Ҫ���vlan����Ҫ�ȴ���vlan�ӽӿڣ�Ȼ�������ӽӿڴ���host
        if {[string tolower $EnableVlan] == "enable"} {
            # ��ȡ�ӽӿڵ�������Ϣ
            set index [lsearch -nocase $args -VlanId]
            if {$index != -1} {
                set VlanId [lindex $args [expr $index + 1]]
                set args [lreplace $args $index [expr $index + 1]]
            } else  {
                set VlanId 100
            }

            set index [lsearch -nocase $args -VlanPriority]
            if {$index != -1} {
                set VlanPriority [lindex $args [expr $index + 1]]
                set args [lreplace $args $index [expr $index + 1]]
            } else  {
                set VlanPriority 0
            }

            # ����::TestCenter::SetupVlan�����ӽӿ�
            set vlanName vlan_$hostName
            if {[catch {set res [TestCenter::SetupVlan $portName $vlanName -VlanId $VlanId -VlanPriority $VlanPriority]} err] == 1} {

                set msg "����TestCenter::SetupVlan�����쳣��������ϢΪ: $err ."
                LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                set nRet $::ATT_TESTCENTER_FAIL
                break
            }
            # �ж�ִ�н��
            if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

                set msg [lindex $res 1]
                LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                set nRet $::ATT_TESTCENTER_FAIL
                break
            }
            LOG::DebugInfo $func $::ATTTestCenter::__FILE__  "����Vlan�ӽӿڳɹ���"
            set IntName $vlanName
        }

		# ����::TestCenter::SetupHost����host
		if {[catch {set res [TestCenter::SetupHost $IntName $hostName $args]} err] == 1} {

			set msg "����TestCenter::SetupHost�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::StartARPStudy {srcHost dstHost retries interval}
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
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::StartARPStudy {srcHost {dstHost ""} {retries "3"} {interval "1"}} {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::SetupHost����host
		if {[catch {set res [TestCenter::StartARPStudy $srcHost $dstHost $retries $interval]} err] == 1} {

			set msg "����TestCenter::StartARPStudy�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::CreateDHCPServer {portName routerName args}
#Description:   ��ָ���˿ڴ���DHCP server��������DHCP server������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName     ��ʾ��Ҫ����DHCP Server�Ķ˿���������Ķ˿�����ԤԼ�˿�ʱָ��������
#    routerName   ��ʾ��Ҫ������DHCP Server�����֡����������ں���Ը�DHCP Server����������
#    args         ��ʾ��Ҫ������DHCP Server�������б����ʽΪ{-option value}.router�������У�
#       -PoolName     �������ڴ���������Ŀ�ĵ�ַ��Դ��ַ���Ǳ����������Ӧ�ĵ�ַ�仯��������湦�ܶ�Ӧ�ĸ���εķ�װ��
#                     ע�⣺PoolName��routerName��Ҫ��ͬ��Ĭ��Ϊ�ա�
#       -RouterId     ��ʾָ����RouterId��Ĭ��Ϊ1.1.1.1
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
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::CreateDHCPServer {portName routerName args} {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""
	set IntName $portName
    set argsSetupRouter ""

    foreach once {once} {

		# ȥ��args���{}
        if {[llength $args] == 1} {
            set args [lindex $args 0]
        }

        # �ж��Ƿ�Ҫ���vlan
        set index [lsearch -nocase $args -EnableVlan]
        if {$index != -1} {

            set EnableVlan [lindex $args [expr $index + 1]]
            set args [lreplace $args $index [expr $index + 1]]
        } else  {
            set EnableVlan disable
        }

        # ���Ҫ���vlan����Ҫ�ȴ���vlan�ӽӿڣ�Ȼ�������ӽӿڴ���host
        if {[string tolower $EnableVlan] == "enable"} {
            # ��ȡ�ӽӿڵ�������Ϣ
            set index [lsearch -nocase $args -VlanId]
            if {$index != -1} {
                set VlanId [lindex $args [expr $index + 1]]
                set args [lreplace $args $index [expr $index + 1]]
            } else  {
                set VlanId 100
            }

            set index [lsearch -nocase $args -VlanPriority]
            if {$index != -1} {
                set VlanPriority [lindex $args [expr $index + 1]]
                set args [lreplace $args $index [expr $index + 1]]
            } else  {
                set VlanPriority 0
            }

            # ����::TestCenter::SetupVlan�����ӽӿ�
            set vlanName vlan_$routerName
            if {[catch {set res [TestCenter::SetupVlan $portName $vlanName -VlanId $VlanId -VlanPriority $VlanPriority]} err] == 1} {

                set msg "����TestCenter::SetupVlan�����쳣��������ϢΪ: $err ."
                LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                set nRet $::ATT_TESTCENTER_FAIL
                break
            }
            # �ж�ִ�н��
            if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

                set msg [lindex $res 1]
                LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                set nRet $::ATT_TESTCENTER_FAIL
                break
            }
            LOG::DebugInfo $func $::ATTTestCenter::__FILE__  "����Vlan�ӽӿڳɹ���"
            set IntName $vlanName
        }

        # �ж��Ƿ�Ҫ����RouterId
        set index [lsearch -nocase $args -RouterId]
        if {$index != -1} {

            set RouterId [lindex $args [expr $index + 1]]
            set args [lreplace $args $index [expr $index + 1]]
            set argsSetupRouter [list -RouterId $RouterId]
        }

        # ����::TestCenter::SetupRouter����DHCP Server
        if {[catch {set res [TestCenter::SetupRouter $IntName $routerName DHCPServer $argsSetupRouter]} err] == 1} {

            set msg "����TestCenter::�����쳣��������ϢΪ: $err ."
            LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
            set nRet $::ATT_TESTCENTER_FAIL
            break
        }
        # �ж�ִ�н��
        if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

            set msg [lindex $res 1]
            LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
            set nRet $::ATT_TESTCENTER_FAIL
            break
        }

        # ����::TestCenter::SetupDHCPServer����DHCP Server
		if {[catch {set res [TestCenter::SetupDHCPServer $routerName $args]} err] == 1} {

			set msg "����TestCenter::SetupDHCPServer�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "�ڶ˿�$portName ����$routerName �ɹ���"
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::EnableDHCPServer {routerName}
#Description:   ����DHCP Server����ʼЭ�����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName   ��ʾҪ��ʼЭ������DHCP Server����
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::EnableDHCPServer {routerName } {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

    foreach once {once} {

        # ����::TestCenter::EnableDHCPServer����DHCP Server����
        if {[catch {set res [TestCenter::EnableDHCPServer $routerName]} err] == 1} {

			set msg "����TestCenter::EnableDHCPServer �����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
        # �ж�ִ�н��
        if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
        }
    }

    return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::DisableDHCPServer {routerName}
#Description:   �ر�DHCP Server��ֹͣЭ�����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName   ��ʾҪֹͣЭ������DHCP Server����
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::DisableDHCPServer {routerName } {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

    foreach once {once} {

        # ����::TestCenter::DisableDHCPServer�ر�DHCP Server����
        if {[catch {set res [TestCenter::DisableDHCPServer $routerName]} err] == 1} {

			set msg "����TestCenter::DisableDHCPServer �����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
        # �ж�ִ�н��
        if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
        }
    }

    return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::CreateDHCPClient {portName routerName args}
#Description:   ��ָ���˿ڴ���DHCP Client��������DHCP Client������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName     ��ʾ��Ҫ����DHCP Client�Ķ˿���������Ķ˿�����ԤԼ�˿�ʱָ��������
#    routerName   ��ʾ��Ҫ������DHCP Client�����֡����������ں���Ը�DHCP Client����������
#    args         ��ʾ��Ҫ������DHCP Client�������б����ʽΪ{-option value}.router�������У�
#       -PoolName     �������ڴ���������Ŀ�ĵ�ַ��Դ��ַ���Ǳ����������Ӧ�ĵ�ַ�仯��������湦�ܶ�Ӧ�ĸ���εķ�װ��
#                     ע�⣺PoolName��routerName��Ҫ��ͬ��Ĭ��Ϊ�ա�
#       -RouterId     ��ʾָ����RouterId��Ĭ��Ϊ1.1.1.1
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
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::CreateDHCPClient {portName routerName args} {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""
	set IntName $portName
    set argsSetupRouter ""

    foreach once {once} {

		# ȥ��args���{}
        if {[llength $args] == 1} {
            set args [lindex $args 0]
        }

        # �ж��Ƿ�Ҫ���vlan
        set index [lsearch -nocase $args -EnableVlan]
        if {$index != -1} {

            set EnableVlan [lindex $args [expr $index + 1]]
            set args [lreplace $args $index [expr $index + 1]]
        } else  {
            set EnableVlan disable
        }

        # ���Ҫ���vlan����Ҫ�ȴ���vlan�ӽӿڣ�Ȼ�������ӽӿڴ���host
        if {[string tolower $EnableVlan] == "enable"} {
            # ��ȡ�ӽӿڵ�������Ϣ
            set index [lsearch -nocase $args -VlanId]
            if {$index != -1} {
                set VlanId [lindex $args [expr $index + 1]]
                set args [lreplace $args $index [expr $index + 1]]
            } else  {
                set VlanId 100
            }

            set index [lsearch -nocase $args -VlanPriority]
            if {$index != -1} {
                set VlanPriority [lindex $args [expr $index + 1]]
                set args [lreplace $args $index [expr $index + 1]]
            } else  {
                set VlanPriority 0
            }

            # ����::TestCenter::SetupVlan�����ӽӿ�
            set vlanName vlan_$routerName
            if {[catch {set res [TestCenter::SetupVlan $portName $vlanName -VlanId $VlanId -VlanPriority $VlanPriority]} err] == 1} {

                set msg "����TestCenter::SetupVlan�����쳣��������ϢΪ: $err ."
                LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                set nRet $::ATT_TESTCENTER_FAIL
                break
            }
            # �ж�ִ�н��
            if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

                set msg [lindex $res 1]
                LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                set nRet $::ATT_TESTCENTER_FAIL
                break
            }
            LOG::DebugInfo $func $::ATTTestCenter::__FILE__  "����Vlan�ӽӿڳɹ���"
            set IntName $vlanName
        }

        # �ж��Ƿ�Ҫ����RouterId
        set index [lsearch -nocase $args -RouterId]
        if {$index != -1} {

            set RouterId [lindex $args [expr $index + 1]]
            set args [lreplace $args $index [expr $index + 1]]
            set argsSetupRouter [list -RouterId $RouterId]
        }

        # ����::TestCenter::SetupRouter����DHCP Client
        if {[catch {set res [TestCenter::SetupRouter $IntName $routerName DHCPClient $argsSetupRouter]} err] == 1} {

            set msg "����TestCenter::�����쳣��������ϢΪ: $err ."
            LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
            set nRet $::ATT_TESTCENTER_FAIL
            break
        }
        # �ж�ִ�н��
        if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

            set msg [lindex $res 1]
            LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
            set nRet $::ATT_TESTCENTER_FAIL
            break
        }

        # ����::TestCenter::SetupDHCPServer����DHCP Client
		if {[catch {set res [TestCenter::SetupDHCPClient $routerName $args]} err] == 1} {

			set msg "����TestCenter::SetupDHCPServer�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "�ڶ˿�$portName ����$routerName �ɹ���"
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::EnableDHCPClient {routerName}
#Description:   ʹ��DHCP Client
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName   ��ʾҪʹ�ܵ�DHCP Client����
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::EnableDHCPClient {routerName } {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

    foreach once {once} {

        # ����::TestCenter::EnableDHCPClientʹ��DHCP Client
        if {[catch {set res [TestCenter::EnableDHCPClient $routerName]} err] == 1} {

			set msg "����TestCenter::EnableDHCPClient �����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
        # �ж�ִ�н��
        if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
        }
    }

    return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::DisableDHCPClient {routerName}
#Description:   ֹͣDHCP Client
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName   ��ʾҪֹͣ��DHCP Client����
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::DisableDHCPClient {routerName } {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

    foreach once {once} {

        # ����::TestCenter::DisableDHCPClientֹͣDHCP Client
        if {[catch {set res [TestCenter::DisableDHCPClient $routerName]} err] == 1} {

			set msg "����TestCenter::DisableDHCPClient �����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
        # �ж�ִ�н��
        if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
        }
    }

    return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::MethodDHCPClient {routerName method}
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
proc ::ATTTestCenter::MethodDHCPClient {routerName method} {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

    foreach once {once} {

        # ����::TestCenter::MethodDHCPClient��ʼDHCP Client����
        if {[catch {set res [TestCenter::MethodDHCPClient $routerName $method]} err] == 1} {

			set msg "����TestCenter::MethodDHCPClient �����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
        # �ж�ִ�н��
        if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
        }
    }

    return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::CreatePPPoEServer {portName routerName args}
#Description:   ��ָ���˿ڴ���PPPoE server��������PPPoE server������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName     ��ʾ��Ҫ����PPPoE Server�Ķ˿���������Ķ˿�����ԤԼ�˿�ʱָ��������
#    routerName   ��ʾ��Ҫ������PPPoE Server�����֡����������ں���Ը�DHCP Server����������
#    args         ��ʾ��Ҫ������PPPoE Server�������б����ʽΪ{-option value}.router�������У�
#       -RouterId           ��ʾָ����RouterId��Ĭ��Ϊ1.1.1.1
#       -SourceMacAddr      ��ʾserver�ӿ�MAC��Ĭ��Ϊ00:00:00:C0:00:01
#       -PoolNum            ��ʾ֧�ֵ�PPPoE Client������Ĭ��Ϊ1
#       -PoolName           �������ڴ���������Ŀ�ĵ�ַ��Դ��ַ���Ǳ����������Ӧ�ĵ�ַ�仯��������湦�ܶ�Ӧ�ĸ���εķ�װ��
#                           ע�⣺PoolName��routerName��Ҫ��ͬ��Ĭ��Ϊ�ա�
#       -PPPoEServiceName   ��ʾ�����������ƣ�Ĭ��Ϊspirent
#       -Active             ��ʾPPPoE server�Ự�Ƿ񼤻Ĭ��ΪTRUE
#       -MRU                ��ʾ�ϲ�ɽ��ܵ�����䵥Ԫ�ֽڣ�Ĭ��Ϊ1492
#       -EchoRequestTimer   ��ʾ����echo request�ֽڵļ��ʱ�䣬Ĭ��Ϊ0
#       -MaxConfigCount     ��ʾ����config request���ĵ���������Ĭ��Ϊ10
#       -RestartTimer       ��ʾ���·���config request���ĵĵȴ�ʱ�䣬Ĭ��Ϊ3s
#       -MaxTermination     ��ʾ����termination request���ĵ���������Ĭ��Ϊ2
#       -MaxFailure         ��ʾ��ȷ��PPPʧ��ǰ�յ���NAK���ĵ���������Ĭ��Ϊ5
#       -AuthenticationRole ��ʾ��֤���ͺ�ģʽ��Ĭ��ΪSUT
#                           ע�⣺������SUT, CHAP, PAP��SUT��ʾ�豸�ڲ�������Ҫ��֤��
#       -AuthenUsername     ��ʾ��֤�û�����Ĭ��Ϊwho
#       -AuthenPassword     ��ʾ��֤���룬Ĭ��Ϊwho
#       -SourceIPAddr       ��ʾsrouce ip addr��Ĭ��Ϊ192.0.0.1
#       -EnableVlan         ָ���Ƿ����vlan��enable/disable, Ĭ��Ϊdisable
#       -VlanId             ָ��Vlan id��ֵ��ȡֵ��Χ0-4095��������Χ����Ϊ0���� Ĭ��Ϊ100
#       -VlanPriority       ���ȼ�,ȡֵ��Χ0-7��Ĭ��Ϊ0
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::CreatePPPoEServer {portName routerName args} {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""
	set IntName $portName
    set argsSetupRouter ""

    foreach once {once} {

		# ȥ��args���{}
        if {[llength $args] == 1} {
            set args [lindex $args 0]
        }

        # �ж��Ƿ�Ҫ���vlan
        set index [lsearch -nocase $args -EnableVlan]
        if {$index != -1} {

            set EnableVlan [lindex $args [expr $index + 1]]
            set args [lreplace $args $index [expr $index + 1]]
        } else  {
            set EnableVlan disable
        }

        # ���Ҫ���vlan����Ҫ�ȴ���vlan�ӽӿڣ�Ȼ�������ӽӿڴ���host
        if {[string tolower $EnableVlan] == "enable"} {
            # ��ȡ�ӽӿڵ�������Ϣ
            set index [lsearch -nocase $args -VlanId]
            if {$index != -1} {
                set VlanId [lindex $args [expr $index + 1]]
                set args [lreplace $args $index [expr $index + 1]]
            } else  {
                set VlanId 100
            }

            set index [lsearch -nocase $args -VlanPriority]
            if {$index != -1} {
                set VlanPriority [lindex $args [expr $index + 1]]
                set args [lreplace $args $index [expr $index + 1]]
            } else  {
                set VlanPriority 0
            }

            # ����::TestCenter::SetupVlan�����ӽӿ�
            set vlanName vlan_$routerName
            if {[catch {set res [TestCenter::SetupVlan $portName $vlanName -VlanId $VlanId -VlanPriority $VlanPriority]} err] == 1} {

                set msg "����TestCenter::SetupVlan�����쳣��������ϢΪ: $err ."
                LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                set nRet $::ATT_TESTCENTER_FAIL
                break
            }
            # �ж�ִ�н��
            if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

                set msg [lindex $res 1]
                LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                set nRet $::ATT_TESTCENTER_FAIL
                break
            }
            LOG::DebugInfo $func $::ATTTestCenter::__FILE__  "����Vlan�ӽӿڳɹ���"
            set IntName $vlanName
        }

        # �ж��Ƿ�Ҫ����RouterId
        set index [lsearch -nocase $args -RouterId]
        if {$index != -1} {

            set RouterId [lindex $args [expr $index + 1]]
            set args [lreplace $args $index [expr $index + 1]]
            set argsSetupRouter [list -RouterId $RouterId]
        }

        # ����::TestCenter::SetupRouter����PPPoE Server
        if {[catch {set res [TestCenter::SetupRouter $IntName $routerName PPPoEServer $argsSetupRouter]} err] == 1} {

            set msg "����TestCenter::�����쳣��������ϢΪ: $err ."
            LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
            set nRet $::ATT_TESTCENTER_FAIL
            break
        }
        # �ж�ִ�н��
        if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

            set msg [lindex $res 1]
            LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
            set nRet $::ATT_TESTCENTER_FAIL
            break
        }

        # ����::TestCenter::SetupPPPoEServer����PPPoE Server
		if {[catch {set res [TestCenter::SetupPPPoEServer $routerName $args]} err] == 1} {

			set msg "����TestCenter::SetupPPPoEServer�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "�ڶ˿�$portName ����$routerName �ɹ���"
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::EnablePPPoEServer {routerName}
#Description:   ����PPPoE Server����ʼЭ�����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName   ��ʾҪ��ʼЭ������PPPoE Server����
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::EnablePPPoEServer {routerName } {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

    foreach once {once} {

        # ����::TestCenter::EnablePPPoEServer����PPPoE Server����
        if {[catch {set res [TestCenter::EnablePPPoEServer $routerName]} err] == 1} {

			set msg "����TestCenter::EnablePPPoEServer �����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
        # �ж�ִ�н��
        if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
        }
    }

    return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::DisablePPPoEServer {routerName}
#Description:   �ر�PPPoE Server��ֹͣЭ�����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName   ��ʾҪֹͣЭ������PPPoE Server����
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::DisablePPPoEServer {routerName } {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

    foreach once {once} {

        # ����::TestCenter::DisablePPPoEServer�ر�PPPoE Server����
        if {[catch {set res [TestCenter::DisablePPPoEServer $routerName]} err] == 1} {

			set msg "����TestCenter::DisablePPPoEServer �����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
        # �ж�ִ�н��
        if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
        }
    }

    return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::CreateIGMPHost {portName hostName args}
#Description:   ��ָ���˿ڴ���IGMP Host��������IGMP host������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName   ��ʾ��Ҫ����host�Ķ˿���������Ķ˿�����ԤԼ�˿�ʱָ��������
#    hostName   ��ʾ��Ҫ������host�����֡����������ں���Ը�host����������
#    args       ��ʾ��Ҫ������IGMP host�������б����ʽΪ{-option value}.host�������У�
#       -SrcMac    ��ʾԴMAC���������hostʱ��Ĭ��ֵ������1��Ĭ��Ϊ00:10:94:00:00:02
#       -SrcMacStep ��ʾԴMAC�ı仯������������MAC��ַ�����һλ�������ӣ�Ĭ��Ϊ1
#       -Ipv4Addr   ��ʾHost��ʼIPv4��ַ��Ĭ��Ϊ192.85.1.3
#       -Ipv4AddrGateway  ��ʾGateWay��IPv4��ַ��Ĭ��Ϊ192.85.1.1
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
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::CreateIGMPHost {portName hostName args} {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""
	set IntName $portName

	foreach once {once} {

		# ȥ��args���{}
        if {[llength $args] == 1} {
            set args [lindex $args 0]
        }

		# �ж��Ƿ�Ҫ���vlan
        set index [lsearch -nocase $args -EnableVlan]
        if {$index != -1} {

            set EnableVlan [lindex $args [expr $index + 1]]
            set args [lreplace $args $index [expr $index + 1]]
        } else  {
            set EnableVlan disable
        }

        # ���Ҫ���vlan����Ҫ�ȴ���vlan�ӽӿڣ�Ȼ�������ӽӿڴ���host
        if {[string tolower $EnableVlan] == "enable"} {
            # ��ȡ�ӽӿڵ�������Ϣ
            set index [lsearch -nocase $args -VlanId]
            if {$index != -1} {
                set VlanId [lindex $args [expr $index + 1]]
                set args [lreplace $args $index [expr $index + 1]]
            } else  {
                set VlanId 100
            }

            set index [lsearch -nocase $args -VlanPriority]
            if {$index != -1} {
                set VlanPriority [lindex $args [expr $index + 1]]
                set args [lreplace $args $index [expr $index + 1]]
            } else  {
                set VlanPriority 0
            }

            # ����::TestCenter::SetupVlan�����ӽӿ�
            set vlanName vlan_$hostName
            if {[catch {set res [TestCenter::SetupVlan $portName $vlanName -VlanId $VlanId -VlanPriority $VlanPriority]} err] == 1} {

                set msg "����TestCenter::SetupVlan�����쳣��������ϢΪ: $err ."
                LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                set nRet $::ATT_TESTCENTER_FAIL
                break
            }
            # �ж�ִ�н��
            if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

                set msg [lindex $res 1]
                LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                set nRet $::ATT_TESTCENTER_FAIL
                break
            }
            LOG::DebugInfo $func $::ATTTestCenter::__FILE__  "����Vlan�ӽӿڳɹ���"
            set IntName $vlanName
        }

		# ����::TestCenter::SetupHost����host
		if {[catch {set res [TestCenter::SetupHost $IntName $hostName -HostType IgmpHost]} err] == 1} {

			set msg "����TestCenter::SetupHost�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}

		# ����::TestCenter::SetupIGMPHost����IGMP host
		if {[catch {set res [TestCenter::SetupIGMPHost $hostName $args]} err] == 1} {

			set msg "����TestCenter::SetupIGMPHost�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "�ڶ˿�$portName ����$hostName �ɹ���"
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::SetupIGMPGroupPool {hostName groupPoolName startIP args}
#Description:   ����������IGMP GroupPool
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    hostName      ��ʾҪ����������IGMP GroupPool��������
#    groupPoolName ��ʾIGMP Group�����Ʊ�ʶ��Ҫ���ڵ�ǰ IGMP Host Ψһ
#    startIP       ��ʾGroup ��ʼ IP ��ַ��ȡֵԼ����String��IPv4�ĵ�ֵַ
#    args          ��ʾIGMP Group pool�������б�,��ʽΪ{-option value}.���������������£�
#       -PrefixLen       ��ʾIP ��ַǰ׺���ȣ�ȡֵ��Χ��5��32��Ĭ��Ϊ24
#       -GroupCnt        ��ʾGroup ������ȡֵԼ����32λ��������Ĭ��Ϊ1
#       -GroupIncrement  ��ʾGroup IP ��ַ��������ȡֵ��Χ��32Ϊ��������Ĭ��Ϊ1
#       -FilterMode       Specific Source Filter Mode(IGMPv3), ȡֵ��ΧΪInclude Exclude��Ĭ��ΪExclude
#       -SrcStartIP       ��ʾ��ʼ���� IP ��ַ��IGMPv3����ȡֵԼ����String��Ĭ��Ϊ192.168.1.2
#       -SrcCnt           ��ʾ������ַ������IGMPv3����ȡֵ��Χ��32λ������Ĭ��Ϊ1
#       -SrcIncrement     ��ʾ���� IP ��ַ������IGMPv3����ȡֵ��Χ��32λ������Ĭ��Ϊ1
#       -SrcPrefixLen     ��ʾ���� IP ��ַǰ׺���ȣ�IGMPv3����ȡֵ��Χ��1��32��Ĭ��Ϊ24
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::SetupIGMPGroupPool {hostName groupPoolName startIP args} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::SetupIGMPGroupPool����IGMP GroupPool
		if {[catch {set res [TestCenter::SetupIGMPGroupPool $hostName $groupPoolName $startIP $args]} err] == 1} {

			set msg "����TestCenter::SetupIGMPGroupPool�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "��$hostName ����$groupPoolName �ɹ���"
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::SendIGMPLeave {hostName {groupPoolList ""}}
#Description:   ��groupPoolListָ�����鲥�鷢��IGMP leave���鲥�뿪������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    hostName      ��ʾҪ���ͱ��ĵ�������
#    groupPoolList ��ʾIGMP Group �����Ʊ�ʶ�б�,��ָ����ʾ�������group
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::SendIGMPLeave {hostName {groupPoolList ""}} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::SendIGMPLeave
		if {[catch {set res [TestCenter::SendIGMPLeave $hostName $groupPoolList]} err] == 1} {

			set msg "����TestCenter::SendIGMPLeave�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::SendIGMPReport {hostName {groupPoolList ""}}
#Description:   ��groupPoolListָ�����鲥�鷢��IGMP leave���鲥�뿪������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    hostName      ��ʾҪ���ͱ��ĵ�������
#    groupPoolList ��ʾIGMP Group �����Ʊ�ʶ�б�,��ָ����ʾ�������group
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::SendIGMPReport {hostName {groupPoolList ""}} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::SendIGMPReport
		if {[catch {set res [TestCenter::SendIGMPReport $hostName $groupPoolList]} err] == 1} {

			set msg "����TestCenter::SendIGMPReport�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::CreateIGMPRouter {portName routerName routerIp args}
#Description:   ����IGMP router
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName        ��ʾ��Ҫ����router�Ķ˿���������Ķ˿�����ԤԼ�˿�ʱָ��������
#    routerName      ��ʾҪ���õ�IGMP Router��
#    routerIp        ��ʾ IGMP Router �Ľӿ� IPv4 ��ַ
#    args            ��ʾIGMP router�������б�,��ʽΪ{-option value}.���������������£�
#       -SrcMac      ��ʾԴMac���������Routerʱ��Ĭ��ֵ���ղ���1����
#       -ProtocolType       ��ʾProtocol�����͡��Ϸ�ֵ��IGMPv1/IGMPv2/IGMPv3��Ĭ��ΪIGMPv2
#       -IgnoreV1Reports    ָ���Ƿ���Խ��յ��� IGMPv1 Host�ı��ģ�Ĭ��ΪFalse
#       -Ipv4DontFragment   ָ�������ĳ��ȴ��� MTU ʱ���Ƿ���з�Ƭ��Ĭ��ΪFalse
#       -LastMemberQueryCount  ��ʾ���϶�����û�г�Ա֮ǰ���͵��ض����ѯ�Ĵ�����Ĭ��Ϊ2
#       -LastMemberQueryInterval  ��ʾ���϶�����û�г�Ա֮ǰ����ָ�����ѯ���ĵ� ʱ��������λ ms����Ĭ��Ϊ1000
#       -QueryInterval            ��ʾ���Ͳ�ѯ���ĵ�ʱ��������λ s������Ĭ��Ϊ32
#       -QueryResponseUperBound   ��ʾIgmp Host���ڲ�ѯ���ĵ���Ӧ��ʱ����������ֵ����λ ms����Ĭ��Ϊ10000
#       -StartupQueryCount      ָ��Igmp Router����֮�����͵�Query���ĵĸ�����ȡֵ��Χ��1-255,Ĭ��Ϊ2
#       -Active                ��ʾIGMP Router�Ự�Ƿ񼤻Ĭ��ΪTRUE
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::CreateIGMPRouter {portName routerName routerIp args} {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::SetupRouter����router
		if {[catch {set res [TestCenter::SetupRouter $portName $routerName IgmpRouter]} err] == 1} {

			set msg "����TestCenter::SetupRouter�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}

		# ����::TestCenter::SetupIGMPRouter����IGMP Router
		if {[catch {set res [TestCenter::SetupIGMPRouter $routerName $routerIp $args]} err] == 1} {

			set msg "����TestCenter::SetupIGMPRouter�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "�ڶ˿�$portName ����$routerName �ɹ���"
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::StartIGMPRouterQuery {routerName}
#Description:   ��ʼͨ��IGMP��ѯ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName      ��ʾҪ��ʼͨ��IGMP��ѯ��IGMP Router��
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::StartIGMPRouterQuery {routerName} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::StartIGMPRouterQuery
		if {[catch {set res [TestCenter::StartIGMPRouterQuery $routerName]} err] == 1} {

			set msg "����TestCenter::StartIGMPRouterQuery�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::StopIGMPRouterQuery {routerName}
#Description:   ֹͣͨ��IGMP��ѯ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName      ��ʾҪ��ʼͨ��IGMP��ѯ��IGMP Router��
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::StopIGMPRouterQuery {routerName} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::StopIGMPRouterQuery
		if {[catch {set res [TestCenter::StopIGMPRouterQuery $routerName]} err] == 1} {

			set msg "����TestCenter::StopIGMPRouterQuery�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {
			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {
			set nRet $::ATT_TESTCENTER_SUC
			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::CreateMLDHost {portName hostName args}
#Description:   ��ָ���˿ڴ���MLD Host��������MLD host������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName   ��ʾ��Ҫ����host�Ķ˿���������Ķ˿�����ԤԼ�˿�ʱָ��������
#    hostName   ��ʾ��Ҫ������host�����֡����������ں���Ը�host����������
#    args       ��ʾ��Ҫ������MLD host�������б����ʽΪ{-option value}.host�������У�
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
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::CreateMLDHost {portName hostName args} {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""
	set IntName $portName

    foreach once {once} {

        # ȥ��args���{}
        if {[llength $args] == 1} {
            set args [lindex $args 0]
        }

        # �ж��Ƿ�Ҫ���vlan
        set index [lsearch -nocase $args -EnableVlan]
        if {$index != -1} {

            set EnableVlan [lindex $args [expr $index + 1]]
            set args [lreplace $args $index [expr $index + 1]]
        } else  {
            set EnableVlan disable
        }

        # ���Ҫ���vlan����Ҫ�ȴ���vlan�ӽӿڣ�Ȼ�������ӽӿڴ���host
        if {[string tolower $EnableVlan] == "enable"} {
            # ��ȡ�ӽӿڵ�������Ϣ
            set index [lsearch -nocase $args -VlanId]
            if {$index != -1} {
                set VlanId [lindex $args [expr $index + 1]]
                set args [lreplace $args $index [expr $index + 1]]
            } else  {
                set VlanId 100
            }

            set index [lsearch -nocase $args -VlanPriority]
            if {$index != -1} {
                set VlanPriority [lindex $args [expr $index + 1]]
                set args [lreplace $args $index [expr $index + 1]]
            } else  {
                set VlanPriority 0
            }

            # ����::TestCenter::SetupVlan�����ӽӿ�
            set vlanName vlan_$hostName
            if {[catch {set res [TestCenter::SetupVlan $portName $vlanName -VlanId $VlanId -VlanPriority $VlanPriority]} err] == 1} {

                set msg "����TestCenter::SetupVlan�����쳣��������ϢΪ: $err ."
                LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                set nRet $::ATT_TESTCENTER_FAIL
                break
            }
            # �ж�ִ�н��
            if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

                set msg [lindex $res 1]
                LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
                set nRet $::ATT_TESTCENTER_FAIL
                break
            }
            LOG::DebugInfo $func $::ATTTestCenter::__FILE__  "����Vlan�ӽӿڳɹ���"
            set IntName $vlanName
        }

        # ����::TestCenter::SetupHost����host
		if {[catch {set res [TestCenter::SetupHost $IntName $hostName -IpVersion ipv6 -HostType MldHost]} err] == 1} {

			set msg "����TestCenter::SetupHost�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}

		# ����::TestCenter::SetupMldHost����MLD host
		if {[catch {set res [TestCenter::SetupMLDHost $hostName $args]} err] == 1} {

			set msg "����TestCenter::SetupMLDHost�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "�ڶ˿�$portName ����$hostName �ɹ���"
		}
    }

    return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::SetupMLDGroupPool {hostName groupPoolName startIP args}
#Description:   ����������MLD GroupPool
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    hostName      ��ʾҪ����������MLD GroupPool��������
#    groupPoolName ��ʾMLD Group�����Ʊ�ʶ��Ҫ���ڵ�ǰ MLD Host Ψһ
#    startIP       ��ʾGroup ��ʼ IP ��ַ��ȡֵԼ����String��IPv6�ĵ�ֵַ
#    args          ��ʾIGMP Group pool�������б�,��ʽΪ{-option value}.���������������£�
#       -PrefixLen       ��ʾIP ��ַǰ׺���ȣ�ȡֵ��Χ��9��128��Ĭ��Ϊ64
#       -GroupCnt        ��ʾGroup ������ȡֵԼ����32λ��������Ĭ��Ϊ1
#       -GroupIncrement  ��ʾGroup IP ��ַ��������ȡֵ��Χ��32Ϊ��������Ĭ��Ϊ1
#       -SrcStartIP       ��ʾ��ʼ���� IP ��ַ��MLDv2����ȡֵԼ����String��Ĭ��Ϊ2000::3
#       -SrcCnt           ��ʾ������ַ������MLDv2����ȡֵ��Χ��32λ������Ĭ��Ϊ1
#       -SrcIncrement     ��ʾ���� IP ��ַ������MLDv2����ȡֵ��Χ��32λ������Ĭ��Ϊ1
#       -SrcPrefixLen     ��ʾ���� IP ��ַǰ׺���ȣ�MLDv2����ȡֵ��Χ��1��128��Ĭ��Ϊ64
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::SetupMLDGroupPool {hostName groupPoolName startIP args} {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

    foreach once {once} {

        # ����::TestCenter::SetupIGMPGroupPool����IGMP GroupPool
		if {[catch {set res [TestCenter::SetupMLDGroupPool $hostName $groupPoolName $startIP $args]} err] == 1} {

			set msg "����TestCenter::SetupMLDGroupPool�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

            # set msg display to user
            set msg "��$hostName ����$groupPoolName �ɹ���"
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::SendMLDLeave {hostName {groupPoolList ""}}
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
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::SendMLDLeave {hostName {groupPoolList ""}} {

    set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

    foreach once {once} {

		# ����::TestCenter::SendMLDLeave
		if {[catch {set res [TestCenter::SendMLDLeave $hostName $groupPoolList]} err] == 1} {

			set msg "����TestCenter::SendMLDLeave�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::SendMLDReport {hostName {groupPoolList ""}}
#Description:   ��groupPoolListָ�����鲥�鷢��MLD Report���鲥���룩����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    hostName      ��ʾҪ���ͱ��ĵ�������
#    groupPoolList ��ʾMLD Group �����Ʊ�ʶ�б�,��ָ����ʾ�������group
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::SendMLDReport {hostName {groupPoolList ""}} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::SendMLDReport
		if {[catch {set res [TestCenter::SendMLDReport $hostName $groupPoolList]} err] == 1} {

			set msg "����TestCenter::SendMLDReport�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::SaveConfigAsXML { path }
#Description:  ���ű����ñ���Ϊxml�ļ�
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#       path  xml�ļ������·��
#Output:
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::SaveConfigAsXML {path} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::SaveConfigAsXML
		if {[catch {set res [TestCenter::SaveConfig $path]} err] == 1} {
			set msg "����TestCenter::SaveConfigAsXML�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}

		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {

			set nRet $::ATT_TESTCENTER_SUC
			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::SetStreamSchedulingMode {portName {schedulingMode RATE_BASED}}
#Description:  ���ö˿����������ĵ���ģʽ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#       portName  �˿���
#       schedulingMode �������ĵ���ģʽ��ȡֵ��ΧΪ��PORT_BASED | RATE_BASED | PRIORITY_BASED��Ĭ��ΪRATE_BASED
#Output:
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::SetStreamSchedulingMode {portName {schedulingMode RATE_BASED}} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::SetStreamSchedulingMode�����������ĵ���ģʽ
		if {[catch {set res [TestCenter::SetStreamSchedulingMode $portName $schedulingMode]} err] == 1} {

			set msg "����TestCenter::SetStreamSchedulingMode�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}
		# �ж�ִ�н��
		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

			set nRet $::ATT_TESTCENTER_FAIL
			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
		} else {

			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::CleanupTest {{useless ""}}
#Description:  ������ԣ��ͷ���Դ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#      useless    û���õĲ�����������Ϊ��xmlrpc���ø�ʽ����Ҫ�����봫��
#Output:
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::CleanupTest {{useless ""}} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ����::TestCenter::CleanupTest
		if {[catch {set res [TestCenter::CleanupTest]} err] == 1} {
			set msg "����TestCenter::CleanupTest�����쳣��������ϢΪ: $err ."
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		}

		if {[lindex $res 0] != $TestCenter::ExpectSuccess} {
			set msg [lindex $res 1]
			LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
			set nRet $::ATT_TESTCENTER_FAIL
			break
		} else {
			set nRet $::ATT_TESTCENTER_SUC
			set msg [lindex $res 1]
			LOG::DebugInfo $func $::ATTTestCenter::__FILE__  $msg

			# ɾ�����ݵ�ԤԼ�ɹ��Ķ˿���
			set ::ATTTestCenter::reservePort ""
		}
	}

	return [list array [list [list int $nRet] [list string $msg]]]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::SetupStaEngine {}
#Description:  �������������ж˿ڵ�ͳ������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:   ��
#Output:
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::SetupStaEngine {} {

	set nRet $::ATT_TESTCENTER_SUC
	set func [::__FUNC__]
	set msg  ""

	foreach once {once} {

		# ��ȡ��Ҫͳ�ƵĶ˿��б�
		set tmpPortList $::ATTTestCenter::reservePort

		# ׼��ͳ������
		foreach portName $tmpPortList {
			# ���ÿһ���˿�����ͳ������StaEngine��������portName_StaEngine
			set StaEngineName $portName\_StaEngine

			# ���StaEngine�����Ƿ��Ѵ���
			set isExistFlag [TestCenter::IsObjectExist $StaEngineName]

			# StaEngine���󲻴��ڣ������µĶ���
			if {$isExistFlag == 0} {
				# ����::TestCenter::SetupStaEngine����StaEngine����
				if {[catch {set res [TestCenter::SetupStaEngine $portName $StaEngineName ] } err] == 1} {

					set msg "����TestCenter::SetupStaEngine�����쳣��������ϢΪ: $err ."
					LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
					set nRet $::ATT_TESTCENTER_FAIL
					break
				}
				# �ж�ִ�н��
				if {[lindex $res 0] != $TestCenter::ExpectSuccess} {
					set msg [lindex $res 1]
					LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
					set nRet $::ATT_TESTCENTER_FAIL
					break
				}
			}
		}

		# �������ͳ������ʧ�ܣ��˳�ѭ��������ʧ��
		if {$nRet == $::ATT_TESTCENTER_FAIL} {
			break
		}

		# ����ͳ������
		foreach portName $tmpPortList {
			# ����::TestCenter::StartStaEngine����ͳ������
			if {[catch {set res [TestCenter::StartStaEngine $portName] } err] == 1} {

				set msg "����TestCenter::StartStaEngine�����쳣��������ϢΪ: $err ."
				LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
				set nRet $::ATT_TESTCENTER_FAIL
				break
			}
			# �ж�ִ�н��
			if {[lindex $res 0] != $TestCenter::ExpectSuccess} {

				set msg [lindex $res 1]
				LOG::DebugErr $func $::ATTTestCenter::__FILE__  $msg
				set nRet $::ATT_TESTCENTER_FAIL
				break
			}
		}

		# �������ͳ������ʧ�ܣ��˳�ѭ��������ʧ��
		if {$nRet == $::ATT_TESTCENTER_FAIL} {
			break
		}
	}

	return [list $nRet $msg]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::CheckServerIsStart {{useless ""}}
#Description:  �ù�����������xmlrpc server�Ƿ�ɹ�������������õ��ù��̣�˵���������Ѿ�������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#      useless    û���õĲ�����������Ϊ��xmlrpc���ø�ʽ����Ҫ�����봫��
#Output:
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::CheckServerIsStart {{useless ""}} {

	set nRet $::ATT_TESTCENTER_SUC
	set msg  "xmlrpc server is running..."

	return [list array [list [list int $nRet] [list string $msg]]]
}


if {[catch {

    # ���ڸ÷������������ӽ����У������������ļ�����log
    #LOG::Start
    xmlrpc::serve 51800
    puts "start xmlrpc server successfully!"
    vwait forever
    } err] == 1} {

    set msg "����xmlrpc server�����쳣��������ϢΪ: $err ."
    puts $msg
    }
