
package provide     LOG 2.0

namespace eval LOG {

    ;# ����level
    set LEVEL_USER                  "UserInfo"
    set LEVEL_APP                   "AppInfo"
    set LEVEL_RUN                   "RunInfo"
    set LEVEL_DEBUG                 "DebugWarn" 
    ;# dir name,Ҳ��combo filter name
    set DIR_NAME_USER               "User"
    set DIR_NAME_APP                "App"
    set DIR_NAME_RUN                "Run"
    set DIR_NAME_DEBUG              "Debug"


    ;# config
    set level                       $LEVEL_APP     ;# default
    set path                        "c:/Temp"          ;# ����Ŀ¼�����·�� 
    set printScreen                 false            ;# �Ƿ�ʹ��puts
    set testCaseResultFileName      "��������ִ�н��ͳ�Ʊ�" ;# auto


    ;# open once
    set fileIdUser                  ""
    set fileIdApp                   ""
    set fileIdRun                   ""
    set fileIdDebug                 ""  
    set fileIdLog                   ""              ;# default & all log
}


;# �������Լ� Ŀ¼(�û���һ��ִ��)
proc LOG::CreateTestSetPaths {args} {

    set curTime [clock second]
    set curTime [clock format $curTime -format {%Y%m%d%H%M%S}]

    ;# ��� test name
    set rootPath    ""
    set rootPath    [format "%s_%s" $curTime "testcenter"]    
    
    ;# һ�β��Ե�Ŀ¼���
    LOG::SetLogPath [file join "C:/Temp" $rootPath]    

    ;# 2��Ŀ¼ (ע��:���ܺ��ո�·��)
    set logPath [LOG::GetLogPath]
    file mkdir $logPath
    file mkdir $logPath/Debug
    file mkdir $logPath/Run
    file mkdir $logPath/App
    file mkdir $logPath/User
    
    ;# log.txt
    set LOG::fileIdLog [open  $logPath/log.txt a+]    
}


;# logģ�� ���
proc LOG::Start {args} {

    ;# ֧���������� (һ��Ϊ��)
    foreach {flag value} $args {

        switch -- $flag {

            -level
            {
                LOG::SetLogLevel $value
            }
            -print
            {
                LOG::SetPrintScreen $value
            }
            -path
            {
                LOG::SetLogPath $value
            }
            default
            {
            }
        }
    }

    ;# nwf 2011-12-23 ����Ŀ¼��
    LOG::CreateTestSetPaths     
}


;# old ����ʹ�� (use:__FUNC__)
proc LOG::init {service} {

    return $service
}


proc LOG::GetLogLevel {} {

    return $LOG::level   
}



proc LOG::SetLogLevel {level} {

    ;# Ĭ�ϼ���
    set LOG::level $LOG::LEVEL_DEBUG
        
    if {-1  !=  [lsearch [list DebugWarn DebugInfo DebugErr RunInfo RunErr AppInfo AppErr UserInfo UserErr] $level] } {

        set LOG::level $level
    } else {

        ;# GUI log���� ӳ�䵽 log ����
        set LOG::level [LOG::GetLogLevelEx $level]       
    }    
}



;# log Ŀ¼����� ·��
proc LOG::GetLogPath {} {

    return $LOG::path
}

proc LOG::SetLogPath {path} {
    
    set LOG::path $path 
}

proc LOG::GetPrintScreen {} {

    return $LOG::printScreen
}

;# option =true or false 
;# Ĭ��=true
proc LOG::SetPrintScreen {option} {

    set LOG::printScreen $option
}

proc LOG::GetTestCaseResultFileName {} {

    return $LOG::testCaseResultFileName 
}


;# д��־�ӿڼ�
;# ע��:����ӿ�˳�� �иĶ�(Func �� curFileName ֮��)
proc LOG::TCResult    {curFileName func text} {

    LOG::Log TCResult     $curFileName $func  $text
}

proc LOG::UserErr     {curFileName func text} {

    LOG::Log UserErr      $curFileName $func  $text   
}

proc LOG::UserInfo    {curFileName func text} {

    LOG::Log UserInfo     $curFileName $func  $text   
}

proc LOG::AppErr      {curFileName func text} {

    LOG::Log AppErr       $curFileName $func  $text   
}

proc LOG::AppInfo     {curFileName func text} {

    LOG::Log AppInfo      $curFileName $func  $text
}

proc LOG::RunErr      {curFileName func text} {

    LOG::Log RunErr       $curFileName $func  $text  
}

proc LOG::RunInfo     {curFileName func text} {

    LOG::Log RunInfo      $curFileName $func  $text   
}

proc LOG::DebugErr    {curFileName func text} {

    LOG::Log DebugErr     $curFileName $func  $text   
}

proc LOG::DebugInfo   {curFileName func text} {

    LOG::Log DebugInfo    $curFileName $func  $text   
}

proc LOG::DebugWarn   {curFileName func text} {

    LOG::Log DebugWarn    $curFileName $func  $text   
}




;# +head
;# log ��ʽ
;# Level=Debug or User
;# curFileName=����LOG::UserInfo��tcl�ļ�����
;# Func=����LOG::UserInfo��proc��������
;# textIn=log������
proc LOG::AddHead {level curFileName func text} {     

    set curTime [clock second]
    set curTime [clock format $curTime -format {%Y-%m-%d %H:%M:%S}]

    set scriptName [file tail [info script]]    

    ;# +log ͷ��
    set text "\[$curTime\]\[$scriptName\]\[$level\]\[$curFileName\]\[$func\]: \n\t$text\n"    

    return $text
}

;# log�ڲ���װһ�ε�log API
proc LOG::Log {curLevel curFileName func text} {
      
    set text [LOG::AddHead $curLevel $curFileName $func $text]    
    
    # ֱ�Ӵ�ӡ
    puts $text

    # ���������浽�ļ���
    #LOG::Log2File       $curLevel $text
    
}


;# ����log level ��� log file id
proc LOG::GetFileId {level} {

    set fileId $LOG::fileIdDebug     ;#default
    
    if {$level ==$LOG::LEVEL_USER} {

        set fileId $LOG::fileIdUser
    } elseif {$level ==$LOG::LEVEL_APP} {

        set fileId $LOG::fileIdApp
    } elseif {$level ==$LOG::LEVEL_RUN} {

        set fileId $LOG::fileIdRun
    }     

    return $fileId
}


;# Լ��: ����testcase name
;# ��ÿ�����������տ�ʼʱ����
proc LOG::SetFilesId {} {

    set logPath         [LOG::GetLogPath]   
    set testCaseName    [TestCase::GetTestCaseName]
        
    ;#
    foreach filterLevel [list $LOG::DIR_NAME_USER $LOG::DIR_NAME_APP $LOG::DIR_NAME_RUN $LOG::DIR_NAME_DEBUG] {

        set fileName "${logPath}/$filterLevel/${testCaseName}.txt"

        if {$filterLevel == $LOG::DIR_NAME_USER} {

            catch {close $LOG::fileIdUser}    ;#�ر���һ�ε�file(��һ��Ϊ��)
            set LOG::fileIdUser [open $fileName a+]
        } elseif {$filterLevel == $LOG::DIR_NAME_APP} {

            catch {close $LOG::fileIdApp}    ;#�ر���һ�ε�file
            set LOG::fileIdApp [open $fileName a+]
        } elseif {$filterLevel == $LOG::DIR_NAME_RUN} {

            catch {close $LOG::fileIdRun}    ;#�ر���һ�ε�file
            set LOG::fileIdRun [open $fileName a+]
        } elseif {$filterLevel == $LOG::DIR_NAME_DEBUG} {

            catch {close $LOG::fileIdDebug}    ;#�ر���һ�ε�file
            set LOG::fileIdDebug [open $fileName a+]
        }        
    }
}


;# Text=log������
proc LOG::Log2File {curLevel text} {

    set fileId      ""

    if { [catch {

        ;# log.txt
        puts $LOG::fileIdLog $text
        flush $LOG::fileIdLog
        

    } err ] } {
        
    }        
} 
