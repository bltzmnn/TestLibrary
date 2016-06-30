#coding:utf-8
#***************************************************************************
#  Copyright (C), 2012-1, SHENZHEN GONGJIN ELECTRONICS. Co., Ltd.
#  ģ�����ƣ�ATTTestCenter
#  ģ�鹦�ܣ��ṩTCL client���м��ӿڣ�ͨ��xmlrpc����TCL server�˵�ATTTestCenterģ���еĽӿڣ�
#            ֱ����python ATTTestCenterģ���ṩ����
#  ����: ATT��Ŀ������
#  �汾: V1.0
#  ����: 2013.02.27
#  �޸ļ�¼��
#      lana     created    2013-02-27
#
#***************************************************************************


set projectPath [file dirname [info script]]
lappend auto_path  $projectPath

package require xmlrpc



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

    return $procName
}


package provide ::ATTTestCenter 1.0

namespace eval ::ATTTestCenter {


    set     __FILE__               ATTTestCenter.tcl

    set     url                    "http://127.0.0.1:51800"
}


#*******************************************************************************
#Function:   ::ATTTestCenter::SetURL {url}
#Description:  ����Զ�˷�������URL���Ա��������̽���Զ�̵���
#Calls:  ��
#Data Accessed:   ��
#Data Updated:  ��
#Input:
#      url     ��ʾԶ��xmlrpc��������url
#
#Output:   ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::SetURL {url} {

    set nRet $::ATT_TESTCENTER_SUC
	set msg "set remote url success!"

    set ::ATTTestCenter::url $url

	return [list $nRet $msg]
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

	# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
	if {[catch {set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::ConnectChassis" \
            [list [list string $chassisAddr] ] ]} err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

	# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch {set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::ReservePort" \
                                      [list [list string $portLocation] \
									        [list string $portName] \
											[list string $portType] ] ]} err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

	# �齨�����б�
    set tmpArgs ""
    foreach var $args {
        lappend tmpArgs [list string $var]
    }
    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch {set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::ConfigPort" \
                                      [list [list string $portName] \
									        [list array $tmpArgs] ] ]} err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::GetPortState" \
                                       [list [list string $portName] \
										     [list string $state] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

	# �齨�����б�
    set tmpArgs ""
    foreach var $args {
        lappend tmpArgs [list string $var]
    }
	# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::CreateProfile" \
                                       [list [list string $portName] \
										     [list string $profileName] \
											 [list array $tmpArgs] ] ]} err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

	# �齨�����б�
    set tmpArgs ""
    foreach var $args {
        lappend tmpArgs [list string $var]
    }
	# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::CreateEmptyStream" \
                                       [list [list string $portName] \
										     [list string $streamName] \
											 [list array $tmpArgs] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

	# �齨�����б�
    set tmpArgs ""
    foreach var $args {
        lappend tmpArgs [list string $var]
    }
	# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::CreateHeader" \
                                       [list [list string $headerName] \
										     [list string $headerType] \
											 [list array $tmpArgs] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

	# �齨�����б�
    set tmpArgs ""
    foreach var $args {
        lappend tmpArgs [list string $var]
    }
	# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::CreatePacket" \
                                       [list [list string $packetName] \
										     [list string $packetType] \
											 [list array $tmpArgs]] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::AddPDUToStream {streamName args}
#Description:   ��PDUList�е�PDU��ӽ�streamName��,�����pduָ����ǰ�洴����header��packet
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    streamName     ָ��Ҫ���PDU��steam����,�����streamName������ǰ���Ѿ������õ�stream����
#    args           ��ʾ��Ҫ��ӵ�streamName�е�PDU�б�
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::AddPDUToStream {streamName args} {

	# �齨�����б�
    set tmpArgs ""
	if {[llength $args] == 1} {
		set tmpArgs $args

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
		if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::AddPDUToStream" \
										   [list [list string $streamName] \
												 [list string $tmpArgs] ] ]} err] == 1} {

			set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
			set nRet $::ATT_TESTCENTER_FAIL
			return [list $nRet $msg]
		}
	} else {
		foreach var $args {
			lappend tmpArgs [list string $var]
		}

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
		if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::AddPDUToStream" \
										   [list [list string $streamName] \
												 [list array $tmpArgs] ] ]} err] == 1} {

			set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
			set nRet $::ATT_TESTCENTER_FAIL
			return [list $nRet $msg]
		}
	}

    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::ClearTestResult {portOrStream args}
#Description:   ���㵱ǰ�Ĳ���ͳ�ƽ��
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portOrStream: ָ��������˿ڵ�ͳ�ƽ������stream��ͳ�ƽ��,���������е�ͳ�ƽ����ȡֵ��ΧΪ port | stream | all
#    args:    ָ��Ҫ����Ķ����б������Ƕ˿��б�Ҳ�������������б�,Ϊ�ձ�ʾ�������н��
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::ClearTestResult {portOrStream args} {

    # �齨�����б�
    set tmpArgs ""
	if {[llength $args] == 1} {
		set tmpArgs $args

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
		if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::ClearTestResult" \
										   [list [list string $portOrStream] \
                                                 [list string $tmpArgs] ] ]} err] == 1} {

			set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
			set nRet $::ATT_TESTCENTER_FAIL
			return [list $nRet $msg]
		}
	} else {
		foreach var $args {
			lappend tmpArgs [list string $var]
		}

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
		if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::ClearTestResult" \
										   [list [list string $portOrStream] \
                                                 [list array $tmpArgs] ] ]} err] == 1} {

			set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
			set nRet $::ATT_TESTCENTER_FAIL
			return [list $nRet $msg]
		}
	}

    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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
#    filterType  ��ʾ��������������UDF����Stack
#    filterValue  ��ʾ�����������ֵ����ʽΪ{{FilterExpr1}{FilterExpr2}��}
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
#    filterOnStreamId  ��ʾ�Ƿ�ʹ��StreamId���й��ˣ�����������
#                      ��ȡ����ʵʱͳ�ƱȽ���Ч��ȡֵ��ΧΪTRUE/FALSE��Ĭ��ΪFALSE
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


	# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::CreateFilter" \
                                       [list [list string $portName] \
										     [list string $filterName] \
											 [list string $filterType] \
											 [list string $filterValue] \
											 [list string $filterOnStreamId]] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

	# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::StartCapture" \
                                       [list [list string $portName] \
									         [list string $savePath] \
	                                         [list string $filterName] ] ]} err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::StopCapture {portName}
#Description:    ָֹͣ���˿ڵ�ץ��
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

	# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::StopCapture" \
                                      [list [list string $portName] ] ]} err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::TrafficOnPort {{trafficTime 0} {flagArp "TRUE"} args}
#Description:   ���ڶ˿ڿ�ʼ��������ָ��ʱ�������ֹͣ������
#              ���trafficTimeΪ0,�������������̷��أ����û�ֹͣ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    trafficTime     ��ʾ����ʱ�䣬��λΪs,Ĭ��Ϊ0
#    flagArp         ��ʾ�Ƿ����ARPѧϰ��ΪTRUE, ���У�ΪFLASE�������У�Ĭ��ΪTRUE
#    args          ��ʾ����Ҫ�����Ķ˿�����ɵ��б�Ϊ�ձ�ʾ���ж˿� ��Ĭ��Ϊ��
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::TrafficOnPort {{trafficTime 0} {flagArp "TRUE"} args} {

    # �齨�����б�
    set tmpArgs ""
	if {[llength $args] == 1} {
		set tmpArgs $args

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
        if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::TrafficOnPort" \
                                          [list [list int $trafficTime] \
                                                [list string $flagArp] \
                                                [list string $tmpArgs] ] ]} err] == 1} {

            set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
            set nRet $::ATT_TESTCENTER_FAIL
            return [list $nRet $msg]
        }
	} else {
		foreach var $args {
			lappend tmpArgs [list string $var]
		}

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
        if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::TrafficOnPort" \
                                          [list [list int $trafficTime] \
                                                [list string $flagArp] \
                                                [list array $tmpArgs] ] ]} err] == 1} {

            set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
            set nRet $::ATT_TESTCENTER_FAIL
            return [list $nRet $msg]
        }
	}

    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::StopTrafficOnPort {args}
#Description:   ���ƶ˿�ֹͣ����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    args      ��ʾ��Ҫֹͣ�����Ķ˿ڵĶ˿����б�Ϊ�ձ�ʾ���ж˿ڣ�Ĭ��Ϊ��
#
#Output:   ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:    ��
#*******************************************************************************
proc ::ATTTestCenter::StopTrafficOnPort {args} {

    # �齨�����б�
    set tmpArgs ""
	if {[llength $args] == 1} {
		set tmpArgs $args

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
        if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::StopTrafficOnPort" \
                                           [list [list string $tmpArgs] ] ] } err] == 1} {

            set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
            set nRet $::ATT_TESTCENTER_FAIL
            return [list $nRet $msg]
        }
	} else {
		foreach var $args {
			lappend tmpArgs [list string $var]
		}

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
        if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::StopTrafficOnPort" \
                                           [list [list array $tmpArgs] ] ] } err] == 1} {

            set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
            set nRet $::ATT_TESTCENTER_FAIL
            return [list $nRet $msg]
        }
	}

    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::TrafficOnStream {portName {flagArp "TRUE" } {trafficTime 0} args}
#Description:   ������������ʼ��������ָ��ʱ�������ֹͣ���������ʱ��Ϊ0�����̷��أ����û�ֹͣ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName        ��ʾ����stream�����˿ڵĶ˿ڶ�����
#    flagArp         ��ʾ�Ƿ����ARPѧϰ��ΪTRUE, ���У�ΪFLASE�������У�Ĭ��ΪTRUE
#    trafficTime     ��ʾ����ʱ�䣬��λΪs��Ĭ��Ϊ0
#    args           ��ʾ��Ҫ������stream�������б�Ϊ�ձ�ʾ�ö˿���������,Ĭ��Ϊ��
#
#Output:  ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::TrafficOnStream {portName {flagArp "TRUE"} {trafficTime 0} args} {

    # �齨�����б�
    set tmpArgs ""
	if {[llength $args] == 1} {
		set tmpArgs $args

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
        if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::TrafficOnStream" \
                                           [list [list string $portName] \
                                                  [list string $flagArp]\
                                                  [list int $trafficTime]\
                                                  [list string $tmpArgs] ] ]} err] == 1} {

            set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
            set nRet $::ATT_TESTCENTER_FAIL
            return [list $nRet $msg]
        }
	} else {
		foreach var $args {
			lappend tmpArgs [list string $var]
		}

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
        if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::TrafficOnStream" \
                                           [list [list string $portName] \
                                                  [list string $flagArp]\
                                                  [list int $trafficTime]\
                                                  [list array $tmpArgs] ] ]} err] == 1} {

            set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
            set nRet $::ATT_TESTCENTER_FAIL
            return [list $nRet $msg]
        }
	}

    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::StopTrafficOnStream {portName args}
#Description:   ����streamֹͣ����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName       ��ʾ����stream�����˿ڵĶ˿ڶ�����
#    args          ��ʾ��Ҫֹͣ������stream�������б�Ϊ�ձ�ʾ�ö˿���������
#
#Output:    ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:    ��
#*******************************************************************************
proc ::ATTTestCenter::StopTrafficOnStream {portName args} {

    # �齨�����б�
    set tmpArgs ""
	if {[llength $args] == 1} {
		set tmpArgs $args

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
        if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::StopTrafficOnStream" \
                                           [list [list string $portName] \
                                                 [list string $tmpArgs] ] ] } err] == 1} {

            set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
            set nRet $::ATT_TESTCENTER_FAIL
            return [list $nRet $msg]
        }
	} else {
		foreach var $args {
			lappend tmpArgs [list string $var]
		}

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
        if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::StopTrafficOnStream" \
                                           [list [list string $portName] \
                                                 [list array $tmpArgs] ] ] } err] == 1} {

            set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
            set nRet $::ATT_TESTCENTER_FAIL
            return [list $nRet $msg]
        }
	}

    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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
#    resultPath       ��ʾͳ�ƽ�������·����������ò���Ϊ��,�򱣴浽Ĭ��·����
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

    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::GetPortStatsSnapshot" \
                                       [list [list string $portName] \
										     [list string $filterStream] \
	                                         [list string $resultPath] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::GetStreamStatsSnapshot" \
                                       [list [list string $portName] \
									         [list string $streamName] \
	                                         [list string $resultPath] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::GetPortStats {portName subOption {filterStream "0"}}
#Description:   �Ӷ˿�ͳ����Ϣ�л�ȡָ����option����Ϣ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    portName         ��ʾ��ȡͳ����Ϣ�Ķ˿���������Ķ˿�����ԤԼ�˿�ʱָ��������
#    subOption        ��ʾ��Ҫ��ȡ��ͳ�ƽ�������������Ϊ�գ�����������Ϣ
#    filterStream     ��ʾ�Ƿ����ͳ�ƽ����Ϊ1�����ع��˹���Ľ��ֵ��Ϊ0�����ع���ǰ��ֵ
#
#Output:   ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:  ��
#*******************************************************************************
proc ::ATTTestCenter::GetPortStats {portName subOption {filterStream "0"}} {

    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::GetPortStats" \
                                       [list [list string $portName] \
										      [list string $filterStream]\
											  [list string $subOption] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::GetStreamStats {portName streamName {subOption ""}}
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

    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::GetStreamStats" \
                                       [list [list string $portName] \
									         [list string $streamName] \
	                                         [list string $subOption] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

	# �齨�����б�
    set tmpArgs ""
    foreach var $args {
        lappend tmpArgs [list string $var]
    }

    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::CreateHost" \
                                      [list [list string $portName] \
									        [list string $hostName] \
	                                        [list array $tmpArgs] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::StartARPStudy {srcHost dstHost}
#Description:   ����ARP����ѧϰĿ��������MAC��ַ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    srcHost  ��ʾ����ARP�����������
#    dstHost  ��ʾ�������Ŀ��IP��ַ������������
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::StartARPStudy {srcHost dstHost} {

    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::StartARPStudy" \
                                       [list [list string $srcHost] \
                                             [list string $dstHost] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

	# �齨�����б�
    set tmpArgs ""
    foreach var $args {
        lappend tmpArgs [list string $var]
    }

    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::CreateDHCPServer" \
                                      [list [list string $portName] \
									        [list string $routerName] \
	                                        [list array $tmpArgs] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
	if {[catch {set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::EnableDHCPServer" \
            [list [list string $routerName] ] ]} err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
	if {[catch {set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::DisableDHCPServer" \
            [list [list string $routerName] ] ]} err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

	# �齨�����б�
    set tmpArgs ""
    foreach var $args {
        lappend tmpArgs [list string $var]
    }

    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::CreateDHCPClient" \
                                      [list [list string $portName] \
									        [list string $routerName] \
	                                        [list array $tmpArgs] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
	if {[catch {set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::EnableDHCPClient" \
            [list [list string $routerName] ] ]} err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
	if {[catch {set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::DisableDHCPClient" \
            [list [list string $routerName] ] ]} err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
	if {[catch {set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::MethodDHCPClient" \
                                     [list [list string $routerName] \
                                           [list string $method] ] ]} err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

	# �齨�����б�
    set tmpArgs ""
    foreach var $args {
        lappend tmpArgs [list string $var]
    }

    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::CreateIGMPHost" \
                                      [list [list string $portName] \
									        [list string $hostName] \
	                                        [list array $tmpArgs] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

	# �齨�����б�
    set tmpArgs ""
    foreach var $args {
        lappend tmpArgs [list string $var]
    }

    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::SetupIGMPGroupPool" \
                                      [list [list string $hostName] \
									        [list string $groupPoolName] \
	                                        [list string $startIP] \
	                                        [list array $tmpArgs] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::SendIGMPLeave {hostName args}
#Description:   ��groupPoolListָ�����鲥�鷢��IGMP leave���鲥�뿪������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    hostName      ��ʾҪ���ͱ��ĵ�������
#    args         ��ʾIGMP Group �����Ʊ�ʶ�б�,��ָ����ʾ�������group
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::SendIGMPLeave {hostName args} {

    # �齨�����б�
    set tmpArgs ""
	if {[llength $args] == 1} {
		set tmpArgs $args

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
        if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::SendIGMPLeave" \
                                          [list [list string $hostName] \
                                                [list string $tmpArgs] ] ] } err] == 1} {

            set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
            set nRet $::ATT_TESTCENTER_FAIL
            return [list $nRet $msg]
        }
	} else {
		foreach var $args {
			lappend tmpArgs [list string $var]
		}

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
        if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::SendIGMPLeave" \
                                          [list [list string $hostName] \
                                                [list array $tmpArgs] ] ] } err] == 1} {

            set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
            set nRet $::ATT_TESTCENTER_FAIL
            return [list $nRet $msg]
        }
	}

    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::SendIGMPReport {hostName args}
#Description:   ��groupPoolListָ�����鲥�鷢��IGMP leave���鲥�뿪������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    hostName      ��ʾҪ���ͱ��ĵ�������
#    args         ��ʾIGMP Group �����Ʊ�ʶ�б�,��ָ����ʾ�������group
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::SendIGMPReport {hostName args} {

    # �齨�����б�
    set tmpArgs ""
	if {[llength $args] == 1} {
		set tmpArgs $args

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
        if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::SendIGMPReport" \
                                          [list [list string $hostName] \
                                                [list string $tmpArgs] ] ] } err] == 1} {

            set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
            set nRet $::ATT_TESTCENTER_FAIL
            return [list $nRet $msg]
        }
	} else {
		foreach var $args {
			lappend tmpArgs [list string $var]
		}

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
        if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::SendIGMPReport" \
                                          [list [list string $hostName] \
                                                [list array $tmpArgs] ] ] } err] == 1} {

            set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
            set nRet $::ATT_TESTCENTER_FAIL
            return [list $nRet $msg]
        }
	}

    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

	# �齨�����б�
    set tmpArgs ""
    foreach var $args {
        lappend tmpArgs [list string $var]
    }

    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::CreateMLDHost" \
                                      [list [list string $portName] \
									        [list string $hostName] \
	                                        [list array $tmpArgs] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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
#    args          ��ʾMLD Group pool�������б�,��ʽΪ{-option value}.���������������£�
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

	# �齨�����б�
    set tmpArgs ""
    foreach var $args {
        lappend tmpArgs [list string $var]
    }

    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::SetupMLDGroupPool" \
                                      [list [list string $hostName] \
									        [list string $groupPoolName] \
	                                        [list string $startIP] \
	                                        [list array $tmpArgs] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::SendMLDLeave {hostName args}
#Description:   ��groupPoolListָ�����鲥�鷢��MLD leave���鲥�뿪������
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    hostName      ��ʾҪ���ͱ��ĵ�������
#    args         ��ʾMLD Group �����Ʊ�ʶ�б�,��ָ����ʾ�������group
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::SendMLDLeave {hostName args} {

    # �齨�����б�
    set tmpArgs ""
	if {[llength $args] == 1} {
		set tmpArgs $args

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
        if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::SendMLDLeave" \
                                          [list [list string $hostName] \
                                                [list string $tmpArgs] ] ] } err] == 1} {

            set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
            set nRet $::ATT_TESTCENTER_FAIL
            return [list $nRet $msg]
        }
	} else {
		foreach var $args {
			lappend tmpArgs [list string $var]
		}

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
        if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::SendMLDLeave" \
                                          [list [list string $hostName] \
                                                [list array $tmpArgs] ] ] } err] == 1} {

            set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
            set nRet $::ATT_TESTCENTER_FAIL
            return [list $nRet $msg]
        }
	}

    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::SendMLDReport {hostName args}
#Description:   ��groupPoolListָ�����鲥�鷢��MLD leave���鲥���룩����
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    hostName      ��ʾҪ���ͱ��ĵ�������
#    args         ��ʾMLD Group �����Ʊ�ʶ�б�,��ָ����ʾ�������group
#
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::SendMLDReport {hostName args} {

    # �齨�����б�
    set tmpArgs ""
	if {[llength $args] == 1} {
		set tmpArgs $args

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
        if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::SendMLDReport" \
                                          [list [list string $hostName] \
                                                [list string $tmpArgs] ] ] } err] == 1} {

            set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
            set nRet $::ATT_TESTCENTER_FAIL
            return [list $nRet $msg]
        }
	} else {
		foreach var $args {
			lappend tmpArgs [list string $var]
		}

		# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
        if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::SendMLDReport" \
                                          [list [list string $hostName] \
                                                [list array $tmpArgs] ] ] } err] == 1} {

            set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
            set nRet $::ATT_TESTCENTER_FAIL
            return [list $nRet $msg]
        }
	}

    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

	# �齨�����б�
    set tmpArgs ""
    foreach var $args {
        lappend tmpArgs [list string $var]
    }
    # ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::CreateIGMPRouter" \
                                       [list [list string $portName] [list string $routerName] \
			                                 [list string $routerIp] [list array $tmpArgs] ] ] \
		       } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

	# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::StartIGMPRouterQuery" \
                                       [list [list string $routerName] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
}


#*******************************************************************************
#Function:    ::ATTTestCenter::StopIGMPRouterQuery {routerName}
#Description:   ֹͣͨ��IGMP��ѯ
#Calls:   ��
#Data Accessed:  ��
#Data Updated:  ��
#Input:
#    routerName      ��ʾҪֹͣͨ��IGMP��ѯ��IGMP Router��
#Output:         ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::StopIGMPRouterQuery {routerName} {

	# ͨ��xmlrpc::call����server�˵���Ӧ�ӿ�
    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::StopIGMPRouterQuery" \
                                       [list [list string $routerName] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }
    # xmlrpc::call���ؽ����ʽΪ{{} result},����resultΪ���ýӿ�ʵ�ʷ���ֵ
	return [lindex $ret 1]
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

    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::SaveConfigAsXML" \
                               [list [list string $path] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }

	return [lindex $ret 1]
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

	if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::SetStreamSchedulingMode" \
                               [list [list string $portName] \
	                                 [list string $schedulingMode] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }

	return [lindex $ret 1]
}


#*******************************************************************************
#Function:   ::ATTTestCenter::CleanupTest {{useless ""}}
#Description:  �������ԣ��ͷ���Դ
#Calls:  ��
#Data Accessed:   ��
#Data Updated:  ��
#Input:
#      useless    û���õĲ�����������Ϊ��xmlrpc���ø�ʽ����Ҫ�����봫��
#Output:   ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::CleanupTest {{useless ""}} {

    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::CleanupTest" \
		                               [list [list string $useless] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }

	return [lindex $ret 1]
}


#*******************************************************************************
#Function:   ::ATTTestCenter::CheckServerIsStart {{useless ""}}
#Description:  ���������Ƿ��Ѿ�����
#Calls:  ��
#Data Accessed:   ��
#Data Updated:  ��
#Input:
#      useless    û���õĲ�����������Ϊ��xmlrpc���ø�ʽ����Ҫ�����봫��
#Output:   ��
#Return:
#    $ATT_TESTCENTER_SUC  $msg        ��ʾ�ɹ�
#    $ATT_TESTCENTER_FAIL $msg        ��ʾ���ú���ʧ��
#    ����ֵ                           ��ʾʧ��
#
#Others:   ��
#*******************************************************************************
proc ::ATTTestCenter::CheckServerIsStart {{useless ""}} {

    if {[catch { set ret [xmlrpc::call $::ATTTestCenter::url "::ATTTestCenter::CheckServerIsStart" \
		                               [list [list string $useless] ] ] } err] == 1} {

        set msg "����xmlrpc::call�����쳣��������ϢΪ: $err ."
        set nRet $::ATT_TESTCENTER_FAIL
        return [list $nRet $msg]
    }

	return [lindex $ret 1]
}



# debug
if {0} {

    set ret [::ATTTestCenter::ConnectChassis 192.168.1.100]
    puts $ret

    puts "end"
}
