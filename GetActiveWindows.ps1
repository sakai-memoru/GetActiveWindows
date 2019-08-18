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
  $activewin = Get-Process| Where-Object ID -eq $myPid 
  # return
  $activewin
}

function convert-processdata($process)
{
  $window_dic = @{}
  $window_dic.Add("Id",$process.Id)
  $window_dic.Add("ProcessName",$process.ProcessName)
  $window_dic.Add("Title",$process.MainWindowTitle)
  $window_dic.Add("StartTime",$process.StartTime.ToString($C_dateformat)) ## FIXME Start Timeは意味がないよう
  $window_dic.Add("created",(Get-Date).ToString($C_dateformat2))
  $window_json = ($window_dic | ConvertTo-Json)
  # return
  $window_json
}

function get-appname($processName, $mainWindowTitle)
{
  $name = $processName.ToLower()
  # $logger.info.Invoke("name=$name")
  if($C_process_name_dic.ContainsKey($name)){
    $rtn = $C_process_name_dic[$name]
  }else{
    if($name -eq 'applicationframehost'){
      $ary = $mainWindowTitle -split "- "
      $last_ary = $ary[-1].ToLower()
      foreach($str in $C_app_start_name_ary){
        if($last_ary.StartsWith($str)){
          $rtn = $str
        } else {
          $rtn = $last_ary
        }
      }
    }else{
      $rtn = $name
    }
  }
  # return
  $rtn
}

function get-category($app_name)
{
  if($C_category_dic.ContainsKey($app_name)){
    $rtn = $C_category_dic[$app_name]
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
  
  $app_name = get-appname $activewin.ProcessName $activewin.MainWindowTitle
  # $logger.info.Invoke("line=$app_name")
  $null = $arylst.Add($app_name)
  $app_category = get-category $app_name
  $null = $arylst.Add($app_category)
  $null = $arylst.Add($activewin.MainWindowTitle)
  $ary = $arylst.ToArray()
  $line = $ary -join "`t"
  
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
    $line = "time`tprocessid`tappname`tcategory`ttitle"
    Add-content -Path $logPath  -Value "$line`r`n" -Encoding $C_Encode
  }
  
  try
  {
    $logger.info.Invoke('Active windows logger started. Press CTRL+C to see results...')
    $logger.info.Invoke("Output Active windows log to ... $logPath")
    
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
