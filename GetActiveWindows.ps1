## Def
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
function get-activewin()
{
  $hwnd = [Win32.Utils]::GetForegroundWindow()
  $null = [Win32.Utils]::GetWindowThreadProcessId($hwnd, [ref] $myPid)
  $activewin = Get-Process| Where-Object ID -eq $myPid | Select-Object *
  # return
  $activewin
}

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

function get-processname($processName, $mainWindowTitle)
{
  $name = $processName.ToLower()
  if($C_process_name_dic.ContainsKey($name)){
    $rtn = $C_process_name_dic[$name]
  }else{
    if($name -eq 'applicationframehost'){
      $ary = $mainWindowTitle -split "- "
      $rtn = $ary[-1].ToLower()
    }else{
      if($name.StartsWith('todoist')){
        $rtn = 'todoist'
      } else {
        $rtn = $name
      }
    }
  }
  # return
  $rtn
}

function get-category($judged_name)
{
  if($C_category_dic.ContainsKey($judged_name)){
    $rtn = $C_category_dic[$judged_name]
  }else{
    $rtn = "other"
  }
  # return
  $rtn
}

function output-line($logPath, $activewin)
{
  $arylst = New-Object System.Collections.ArrayList
  $null = $arylst.Add((Get-Date).ToString($C_dateformat2))
  $null = $arylst.Add($activewin.StartTime.ToString($C_dateformat))
  $null = $arylst.Add($activewin.Id)
  
  $judged_name = get-processname $activewin.ProcessName $activewin.MainWindowTitle
  $null = $arylst.Add($judged_name)
  $judged_category = get-category $judged_name
  $null = $arylst.Add($judged_category)
  $null = $arylst.Add($activewin.MainWindowTitle)
  $ary = $arylst.ToArray()
  $line = [string]::Join("`t",$ary)
  
  Add-Content -Path $logPath -Value $line -Encoding $C_Encode
  
  if($C_debug_mode){
    $logger.info.Invoke("line=$line")
  }
}

## main
function Log-Activewindows($logPath="$env:temp\Activewindows.txt") 
{
  # output file path
  if (Test-Path $logPath){
    $null
  }else{
    $null = New-Item -Path $logPath -ItemType File
    [System.IO.File]::AppendAllText($logPath, "timine`tprocessid`tcategory`tapps`tprocessname`ttitle`r`n", $C_Encode)
  }
  
  try
  {
    $logger.info.Invoke('Keylogger started. Press CTRL+C to see results...')
    $logger.info.Invoke("Output keystroke log to ... $logPath")
    
    while ($true) {
      Start-Sleep -Milliseconds $C_windows_getting_interval
      $activewin = get-activewin
      output-line $logPath $activewin
    }
  }
  finally
  { 
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
