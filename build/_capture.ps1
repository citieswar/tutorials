Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bmp = New-Object System.Drawing.Bitmap $screen.Width, $screen.Height
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($screen.Left, $screen.Top, 0, 0, $bmp.Size)
$out = 'e:\War\wiki\build\desktop_screenshot.png'
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
$fi = Get-Item $out
Write-Host ("PATH=" + $fi.FullName)
Write-Host ("WIDTH=" + $screen.Width)
Write-Host ("HEIGHT=" + $screen.Height)
Write-Host ("SIZE=" + $fi.Length)
Write-Host ("SIZE_KB=" + [math]::Round($fi.Length/1024,2))
