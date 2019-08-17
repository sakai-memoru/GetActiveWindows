## debug model
$C_debug_mode = $true

## log output interval (sec)
$C_interval = 60

## wait time (msec)
$C_waittime = 40
$C_windows_getting_interval = 6000

## date format
$C_dateformat = "yyyy/MM/dd HH:mm"
$C_dateformat2 = "yyyy/MM/dd HH:mm:ss"

## output folder
$C_output_folder = "$env:temp"

## encode
$C_Encode = [System.Text.Encoding]::Unicode

## output file name
$C_output_filename2 = "Activewindows_{{date_str}}.txt"

## output path
$date_str = (Get-Date).ToString("yyMMdd")
$C_output_path2 = Join-path $C_output_folder $C_output_filename2
$C_output_path2 = $C_output_path2.Replace("{{date_str}}", $date_str)

## category dictionary
$C_category_dic = @{}
$C_category_dic.Add("edge", "browser")
$C_category_dic.Add("chrome", "browser")
$C_category_dic.Add("firefox", "browser")
$C_category_dic.Add("explorer", "filer")
$C_category_dic.Add("powershell", "terminal")
$C_category_dic.Add("outlook", "mailer")
$C_category_dic.Add("calendar", "scheduler")
$C_category_dic.Add("slack", "chat")
$C_category_dic.Add("twitter", "sns")
$C_category_dic.Add("facebook", "sns")
$C_category_dic.Add("excel", "office")
$C_category_dic.Add("word", "office")
$C_category_dic.Add("powerpoint", "office")
$C_category_dic.Add("sakura", "editor")
$C_category_dic.Add("notepad", "editor")
$C_category_dic.Add("workflowy", "editor")
$C_category_dic.Add("typora", "editor")
$C_category_dic.Add("journey", "logging")
$C_category_dic.Add("todoist", "logging")
$C_category_dic.Add("pomodoneapp", "logging")
$C_category_dic.Add("photo", "image")
$C_category_dic.Add("sourcetree", "develop")


## category map
$C_process_name_dic = @{}
$C_process_name_dic.Add("powerpnt", "powerpoint")
$C_process_name_dic.Add("winword", "word")
$C_process_name_dic.Add("applicationframehost", "edge")
