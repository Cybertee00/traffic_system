# Create test bookings for 93 users across 20 days
$baseUrl = "https://smart-license-api.onrender.com"

Write-Host "Creating test bookings for 93 users across 20 days..." -ForegroundColor Green

# Arrays for randomization
$licenseCodes = @("Code 8", "Code 10", "Code 14")

# List of successfully processed user IDs
$successfulUserIds = @(
    23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
    51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78,
    79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105,
    106, 107, 108, 109, 110, 111, 112, 113, 114, 115
)

$totalUsers = $successfulUserIds.Count
$daysToDistribute = 20
$usersPerDay = [math]::Ceiling($totalUsers / $daysToDistribute)

Write-Host "Total users: $totalUsers" -ForegroundColor Cyan
Write-Host "Days to distribute: $daysToDistribute" -ForegroundColor Cyan
Write-Host "Users per day: $usersPerDay" -ForegroundColor Cyan

# Main execution
$totalCreated = 0
$totalFailed = 0
$startDate = Get-Date

Write-Host "Starting booking creation..." -ForegroundColor Cyan

# Distribute users across 20 days
for ($day = 0; $day -lt $daysToDistribute; $day++) {
    $currentDate = $startDate.AddDays($day + 1)
    $dateString = $currentDate.ToString("dd/MM/yyyy")
    $formattedDate = $currentDate.ToString("yyyy-MM-dd")
    
    # Calculate which users to assign to this day
    $startIndex = $day * $usersPerDay
    $endIndex = [math]::Min(($startIndex + $usersPerDay - 1), ($totalUsers - 1))
    
    $usersForThisDay = $successfulUserIds[$startIndex..$endIndex]
    $usersCount = $usersForThisDay.Count
    
    Write-Host "Day $($day + 1): $dateString - $usersCount users" -ForegroundColor Magenta
    
    foreach ($userId in $usersForThisDay) {
        $licenseCode = $licenseCodes | Get-Random
        
        Write-Host "  Creating booking for User ID: $userId ($licenseCode)" -ForegroundColor Cyan
        
        try {
            $bookingPayload = @{
                learner_id = $userId
                instructor_id = 1
                station_id = 1
                test_date = $formattedDate
                result = "pending"
                booking_date = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                license_code = $licenseCode
                registered_on = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
            }
            
            $bookingResponse = Invoke-RestMethod -Uri "$baseUrl/learner-test-bookings/" -Method POST -Body ($bookingPayload | ConvertTo-Json) -ContentType "application/json"
            Write-Host "    Booking created" -ForegroundColor Green
            $totalCreated++
            
        } catch {
            Write-Host "    Error creating booking for user $userId" -ForegroundColor Red
            $totalFailed++
        }
        
        Start-Sleep -Milliseconds 100
    }
}

Write-Host "Booking creation complete" -ForegroundColor Green
Write-Host "Total bookings created: $totalCreated" -ForegroundColor Green
Write-Host "Total failed: $totalFailed" -ForegroundColor Red
Write-Host "Success rate: $([math]::Round(($totalCreated / ($totalCreated + $totalFailed)) * 100, 2))%" -ForegroundColor Yellow
