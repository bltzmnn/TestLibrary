



proc AddInfo {msg} {
    puts $msg
}

proc TclCompiler {fileList {indexFile ""}} {
    if {"" ==  $fileList} {
    #����ļ��б��ǿյģ���ֱ�ӷ���1
        return 1
    }
    if {"" !=  $indexFile} {
        set indexFilePath [file dirname $indexFile]
        AddInfo "��ʼ����Ŀ¼$indexFilePath �е�Tcl�ļ�"
    
    }
    foreach url $fileList {
        AddInfo "���ڱ����ļ� $url "
        if { [catch {set Result [exec tclcompiler $url]} errormsg] == 1 } {
            AddInfo "ִ��tclcompiler����ʧ�ܣ�������Ϣ���£� $errormsg "
            return -1
        }
    
        if {1 != [string match -nocase "*notice    Done*" $Result]} {
            AddInfo "ִ��tclcompiler����ʧ�ܣ�������Ϣ���£� $Result "
            return -1
        }
#        AddInfo "$url ����ɹ�"
    }
    
    if {"" !=  $indexFile} {
        set FileId      [open $indexFile r+]
        set indexFileInfo [read $FileId]
        close $FileId
        AddInfo "���ڸ���pkgIndex�ļ�$indexFile"
        foreach url $fileList {
            set fileName [file tail $url]
            while {1} {
                set Num [string first $fileName $indexFileInfo]
                if {"-1" == $Num} {
                    break
                }
                set length [expr [string length $fileName] - 4]
                set indexFileInfo [string replace $indexFileInfo $Num [expr $Num + [expr $length + 3]] [file rootname $fileName].tbc]
            }
        }
        file delete $indexFile
        set FileId      [open $indexFile w+]
        puts -nonewline $FileId $indexFileInfo
        close $FileId
#        AddInfo "$indexFile �ļ����³ɹ�"
    }
    foreach url $fileList {    
        file delete $url
    }
    if {"" !=  $indexFile} {
        set indexFilePath [file dirname $indexFile]
        AddInfo "Ŀ¼$indexFilePath �е�Tcl�ļ�����ɹ�"
    }
    return 1
}


proc GetPathFile {path excludePath fileList} {
    upvar 1 $fileList filelist
    set files ""

    set files [glob -nocomplain [file join $path *]]
    
    foreach file $files {
        if {"" != $file} {
            if {1 == [file isfile $file]} {
                if {1 == [string match -nocase "*.tcl" $file]} {
                    if {1 != [string match -nocase "*pkgIndex.tcl" $file]} {
                        foreach exclude $excludePath {
                            if {1 == [string match -nocase "*$exclude*" "$file"]} {
                                set file ""
                            }
                        }
                        if {"" != $file} {
                            lappend filelist $file
                        }
                    } else {
                        continue
                    }
                }
            } else {
                set result [GetPathFile $file $excludePath filelist]
                if {"1" != $result} {
                    return $result
                }
            }
        }
    }
    return 1
}


proc GetpkgIndexFile {path excludePath pkgIndexFileList} {
    upvar 1 $pkgIndexFileList pkgindexfilelist
    set files ""

    set files [glob -nocomplain [file join $path *]]
    
    foreach file $files {
        if {"" != $file} {
            if {1 == [file isfile $file]} {
                if {1 == [string match -nocase "*.tcl" $file]} {
                    if {1 == [string match -nocase "*pkgIndex.tcl" $file]} {
                        foreach exclude $excludePath {
                            if {1 == [string match -nocase "*$exclude*" "$file"]} {
                                set file ""
                            }
                        }
                        if {"" != $file} {
                            foreach pkgindexfile $pkgindexfilelist {
                                set pkgindexfilePath [file dirname $pkgindexfile]
                                set filePath [file dirname $file]
                                if {1 == [string match -nocase "$pkgindexfilePath*" "$filePath"] || 1 == [string match -nocase "$filePath*" "$pkgindexfilePath"]} {
                                    AddInfo "����pkgIndex.tcl�ļ�·������Ƕ��Ŀ¼����ȷ����Ϣ�Ƿ���ȷ�������ļ�Ϊ��\n$file \n$pkgindexfile"
                                    return -1
                                }
                            }
                            lappend pkgindexfilelist $file
                        }
                    } else {
                        continue
                    }
                }
            } else {
                set result [GetpkgIndexFile $file $excludePath pkgindexfilelist]
                if {"1" != $result} {
                    return $result
                }                
            }
        }
    }
    return 1
}

proc Encrypt {path excludePath} {

    AddInfo "��ʼ����Ŀ¼$path �е�Tcl�ļ�Ϊ�������ļ���"
    
    set pkgIndexFileList ""
    set result [GetpkgIndexFile $path $excludePath pkgIndexFileList]
    if {"1" != $result} {
        return $result
    }

    foreach pkgIndexFile $pkgIndexFileList {
        set files ""
        set pkgIndexFilePath [file dirname $pkgIndexFile]
        set result [GetPathFile $pkgIndexFilePath $excludePath files]
        if {"1" != $result} {
            return $result
        }        
        set result [TclCompiler $files $pkgIndexFile]
        if {"1" != $result} {
            return $result
        }  
    }
    
    #�����Ŀ¼�ļ�
    set files ""
    set files [glob -nocomplain [file join $path *.tcl]]
    
    foreach file $files {
        if {"" != $file} {
            if {1 == [file isfile $file]} {
                if {1 != [string match -nocase "*pkgIndex.tcl" $file]} {
                    set result [TclCompiler $file]
                    if {"1" != $result} {
                        return $result
                    }
                }
            }
        }
    }
    
    AddInfo "����Ŀ¼$path �е�Tcl�ļ�Ϊ�������ļ���ϡ�"
    
    return 1
}
