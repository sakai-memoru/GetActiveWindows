﻿## Def
# API declaration
$APIsignaturesUtils = @'
[DllImport("user32.dll")]
public static extern IntPtr GetForegroundWindow();
[DllImport("user32.dll")]
public static extern IntPtr GetWindowThreadProcessId(IntPtr hWnd, out int ProcessId);
'@
Add-Type $APIsignaturesUtils -Name Utils -Namespace Win32
$myPid = [IntPtr]::Zero;

## Sub Functions
function convert-processdata($process)
{
  $window_dic = @{}
  $window_dic.Add("Id",$process.Id)
  $window_dic.Add("ProcessName",$process.ProcessName)
  $window_dic.Add("Title",$process.MainWindowTitle)
  $window_dic.Add("StartTime",$process.StartTime.ToString($C_dateformat))
  $window_dic.Add("created",(Get-Date).ToString($C_dateformat2))
  $window_json = ($window_dic | ConvertTo-Json)
  # return
  $window_json
}

function get-activewin()
{
  $hwnd = [Win32.Utils]::GetForegroundWindow()
  $null = [Win32.Utils]::GetWindowThreadProcessId($hwnd, [ref] $myPid)
  $activewin = Get-Process| Where-Object ID -eq $myPid | Select-Object *
  # return
  $activewin
}

function output-line($logPath, ){
  $line = (Get-Date).ToString($C_dateformat) + "`t"
  $line = $line + $activewin.Id + "`t"
  $line = $line + $activewin.ProcessName + "`t"
  [System.IO.File]::AppendAllText($logPath, $line + "`r`n", $C_Encode)
  if($C_debug_mode){
    $logger.info.Invoke($line)
  }

  # $lst_str
  [System.IO.File]::AppendAllText($logPath, "`t" + $lst_str, $C_Encode)
  [System.IO.File]::AppendAllText($logPath, "`r`n", $C_Encode)

}

## main
function Log-Activewindows($logPath="$env:temp\Activewindows.txt") 
{
  # output file path
  if (Test-Path $logPath){
    $null
  }else{
    $null = New-Item -Path $logPath -ItemType File
    [System.IO.File]::AppendAllText($logPath, "time`tprocessid`tcategory`tapps`tprocessname`ttitle`r`n", $C_Encode)
  }
  
  # buf
  $lst = New-Object System.Collections.ArrayList

  
  try
  {
    Write-Host 'Keylogger started. Press CTRL+C to see results...' -ForegroundColor Red
    Write-Host 'Output log to .. ' $logPath
    
    [System.IO.File]::AppendAllText($logPath, "active windows`ttime`tcount`r`n", $C_Encode)
    
    while ($true) {
      $starttime = Get-Date
      $flag = $true
      
      while ($flag) {
        Start-Sleep -Milliseconds $C_windows_getting_interval
        $activewin = get-activewin
        
        $process_json = convert-processdata($activewin)
        $process_json
        $cnt = $lst.Add($process_json)
        
        $endtime = Get-Date
        $secondstosleep = [int]($C_interval - ($endtime - $starttime).TotalSeconds)
        if($secondstosleep -le 0){
          $flag = $false
        } 
      }
      
      $lst_ary = $lst.ToArray()
      $lst_str = [string]::Join(",",$lst_ary)
    }
  }
  finally
  { 
    $lst_ary = $lst.ToArray()
    $lst_str = [string]::Join(",",$lst_ary)
    [System.IO.File]::AppendAllText($logPath, (Get-Date).ToString($C_dateformat), $C_Encode) 
    [System.IO.File]::AppendAllText($logPath, "`t" + $lst_str, $C_Encode)
    [System.IO.File]::AppendAllText($logPath, "`r`n", $C_Encode)
    notepad $logPath
  }
}

## ---------------------------------------------------- // entry point
## include configs
$project_name = split-path $PWD.path -leaf
$config = "./$project_name.config.ps1"
. $config

## include logger
. ./Get-Logger.ps1

$logger = Get-Logger
$logger.info.Invoke("get config from $config")

Log-Activewindows($C_output_path2)
