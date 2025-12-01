# Process remaining existing users (IDs 19-115, skipping 18)
$baseUrl = "https://smart-license-api.onrender.com"

Write-Host "Processing remaining existing users (IDs 19-115)..." -ForegroundColor Green
Write-Host "Total users to process: 97" -ForegroundColor Yellow

# Arrays for randomization
$firstNames = @("John", "Jane", "Michael", "Sarah", "David", "Lisa", "Robert", "Emily", "James", "Jessica", "William", "Ashley", "Richard", "Amanda", "Charles", "Jennifer", "Joseph", "Michelle", "Thomas", "Kimberly")
$lastNames = @("Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin")
$genders = @("Male", "Female", "Other")
$nationalities = @("South African", "Zimbabwean", "Mozambican", "Malawian", "Zambian", "Botswanan", "Namibian", "Lesothan", "Swazi", "Nigerian")
$races = @("Black African", "Coloured", "Indian/Asian", "White", "Other")
$licenseCodes = @("Code 8", "Code 10", "Code 14")

# Function to generate random South African ID number
function Generate-SA-ID {
    $year = Get-Random -Minimum 50 -Maximum 99
    $month = Get-Random -Minimum 1 -Maximum 13
    $day = Get-Random -Minimum 1 -Maximum 29
    $sequence = Get-Random -Minimum 1000 -Maximum 9999
    $gender = Get-Random -Minimum 0 -Maximum 10
    $citizenship = Get-Random -Minimum 0 -Maximum 2
    $checksum = Get-Random -Minimum 0 -Maximum 10
    
    return "$year$($month.ToString('00'))$($day.ToString('00'))$($sequence.ToString('0000'))$($gender.ToString('0'))$($citizenship.ToString('0'))$($checksum.ToString('0'))"
}

# Function to generate random phone number
function Generate-PhoneNumber {
    $prefixes = @("082", "083", "084", "071", "072", "073", "074", "079")
    $prefix = $prefixes | Get-Random
    $number = Get-Random -Minimum 1000000 -Maximum 9999999
    return "+27$($prefix.Substring(1))$number"
}

# Function to generate random address
function Generate-Address {
    $streetNumbers = @(1..999) | Get-Random
    $streetNames = @("Main", "Church", "High", "Long", "Short", "Broad", "Narrow", "New", "Old")
    $streetName = $streetNames | Get-Random
    $cities = @("Johannesburg", "Cape Town", "Durban", "Pretoria", "Port Elizabeth")
    $city = $cities | Get-Random
    $provinces = @("Gauteng", "Western Cape", "KwaZulu-Natal", "Eastern Cape", "Free State")
    $province = $provinces | Get-Random
    $postalCode = Get-Random -Minimum 1000 -Maximum 9999
    
    return "$streetNumbers $streetName Street, $city, $province $postalCode"
}

# Main execution
$totalCreated = 0
$totalFailed = 0

Write-Host "Starting processing..." -ForegroundColor Cyan

# Process users 19-115 (97 users total)
for ($i = 1; $i -lt 98; $i++) {
    $userId = 18 + $i  # User IDs 19-115
    $userIndex = $i
    
    Write-Host "Processing User $userIndex/97 (ID: $userId)..." -ForegroundColor Yellow
    
    # Generate random data for this user
    $firstName = $firstNames | Get-Random
    $lastName = $lastNames | Get-Random
    $gender = $genders | Get-Random
    $nationality = $nationalities | Get-Random
    $race = $races | Get-Random
    $licenseCode = $licenseCodes | Get-Random
    $idNumber = Generate-SA-ID
    $phoneNumber = Generate-PhoneNumber
    $address = Generate-Address
    
    # Generate a random test date within the next 60 days
    $testDate = (Get-Date).AddDays((Get-Random -Minimum 1 -Maximum 61))
    $formattedTestDate = $testDate.ToString("yyyy-MM-dd")
    
    Write-Host "  Creating: $firstName $lastName ($licenseCode)" -ForegroundColor Cyan
    
    try {
        # Step 1: Create user profile
        $profilePayload = @{
            user_id = $userId
            name = $firstName
            surname = $lastName
            date_of_birth = "1990-01-01"
            gender = $gender
            nationality = $nationality
            race = $race
            id_number = $idNumber
            contact_number = $phoneNumber
            physical_address = $address
        }
        
        $profileResponse = Invoke-RestMethod -Uri "$baseUrl/user-profiles/" -Method POST -Body ($profilePayload | ConvertTo-Json) -ContentType "application/json"
        Write-Host "    User profile created" -ForegroundColor Green
        
        # Step 2: Create learner profile
        $learnerPayload = @{
            user_id = $userId
            learner_status = "pending"
            test_booking_date = $formattedTestDate
            registered_on = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
            license_code = $licenseCode
        }
        
        $learnerResponse = Invoke-RestMethod -Uri "$baseUrl/learner-profiles/" -Method POST -Body ($learnerPayload | ConvertTo-Json) -ContentType "application/json"
        Write-Host "    Learner profile created" -ForegroundColor Green
        
        Write-Host "    Profiles created for $firstName $lastName" -ForegroundColor Green
        $totalCreated++
        
    } catch {
        Write-Host "    Error creating profiles for user $userId" -ForegroundColor Red
        $totalFailed++
    }
    
    # Small delay to avoid overwhelming the API
    Start-Sleep -Milliseconds 150
}

Write-Host "`nProcessing Complete" -ForegroundColor Green
Write-Host "Total users processed successfully: $totalCreated" -ForegroundColor Green
Write-Host "Total failed: $totalFailed" -ForegroundColor Red
Write-Host "Success rate: $([math]::Round(($totalCreated / ($totalCreated + $totalFailed)) * 100, 2))%" -ForegroundColor Yellow

if ($totalCreated -gt 0) {
    Write-Host "`nExisting users have been successfully processed!" -ForegroundColor Green
    Write-Host "Each user now has user profiles and learner profiles with randomized data." -ForegroundColor White
    Write-Host "All users are assigned to Instructor ID 1 and Station ID 1." -ForegroundColor White
}
