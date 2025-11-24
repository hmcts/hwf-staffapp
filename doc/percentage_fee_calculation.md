# Percentage Fee Calculation

## Overview

The application supports percentage-based fees where the fee amount is calculated as a percentage of a base amount entered by the user.

## How It Works

### Frontend Flow (freg.js)

1. **Fee Search**: User searches for a fee using the fee search field
2. **Display Results**: System displays both flat-amount and percentage-based fees
   - Flat fees show as: `£35.00`
   - Percentage fees show as: `5%`
3. **Fee Selection**:
   - If user clicks a flat fee → amount is filled directly
   - If user clicks a percentage fee → percentage input field appears
4. **Amount Input**: User enters the base amount (e.g., £10,000)
5. **Calculate**: User clicks "Calculate fee" button
6. **API Call**: AJAX request sent to `/api/calculate_percentage_fee`
7. **Result**: Calculated fee is populated in the fee field

### Backend Calculation (FeeCalculatorController)

**Endpoint**: `POST /api/calculate_percentage_fee`

**Request Format**:
```json
{
  "fee": {
    "code": "FEE0507",
    "fee_version": {
      "percentage_amount": {
        "percentage": 5.0
      },
      "description": "Counter Claim - 5% of claim value",
      "version": 4
    }
  },
  "base_amount": 10000.00
}
```

**Calculation Formula**:
```ruby
calculated_fee = (base_amount * percentage / 100).round(2)
```

**Example**:
- Base Amount: £10,000
- Percentage: 5%
- Calculation: (10000 * 5) / 100 = £500.00

**Response Format**:
```json
{
  "calculated_fee": 500.00,
  "fee_code": "FEE0507",
  "description": "Counter Claim - 5% of claim value",
  "version": 4,
  "calculation_details": {
    "base_amount": 10000.0,
    "percentage": 5.0,
    "formula": "(10000.0 * 5.0%) / 100 = 500.0"
  },
  "success": true
}
```

## View Components

### Fee Input Field (`#application_fee`)
The main fee field that displays the final calculated amount.

### Percentage Amount Input (`#percentage-amount-input`)
- Hidden by default
- Shows when percentage fee is selected
- Includes:
  - Label: "Enter the amount to calculate the percentage fee"
  - Input field with £ prefix
  - "Calculate fee" button

**Location**: `app/views/applications/process/details/index.html.slim:25-31`

## JavaScript Implementation

### Key Methods

**`findMatches(term)`** - Searches for fees including percentage fees
```javascript
const hasFlatAmount = relevantVersion.flat_amount && typeof relevantVersion.flat_amount.amount === 'number';
const hasPercentage = relevantVersion.percentage_amount && typeof relevantVersion.percentage_amount.percentage === 'number';
```

**`displayFees(fees, dateReceived)`** - Displays search results
```javascript
const isPercentageFee = relevantVersion.percentage_amount !== undefined;

if (isPercentageFee) {
  feeValueText = `${relevantVersion.percentage_amount.percentage}%`;
} else {
  feeValueText = `£${relevantVersion.flat_amount.amount}`;
}
```

**`calculatePercentageFee()`** - Calls API to calculate fee
```javascript
$.ajax({
  url: '/api/calculate_percentage_fee',
  method: 'POST',
  contentType: 'application/json',
  data: JSON.stringify({
    fee: feeData,
    base_amount: parseFloat(baseAmount)
  })
});
```

**Location**: `app/javascript/freg.js`

## Validation

### Frontend Validation
- Fee must be selected before calculation
- Base amount must be entered
- Base amount must be > 0

### Backend Validation
- Base amount must be > 0
- Percentage must be > 0
- Returns 400 Bad Request for invalid inputs

## Error Handling

### Frontend Errors
```javascript
if (!feeData) {
  alert('Please select a percentage fee first');
  return;
}

if (!baseAmount || parseFloat(baseAmount) <= 0) {
  alert('Please enter a valid amount');
  return;
}
```

### Backend Errors
```ruby
if base_amount <= 0
  render json: {
    error: 'Invalid base amount',
    details: 'Base amount must be greater than zero'
  }, status: :bad_request
end
```

### API Error Response
```json
{
  "error": "Invalid base amount",
  "details": "Base amount must be greater than zero"
}
```

## Example Usage

### Scenario 1: Standard Percentage Fee

**Fee**: FEE0507 - Counter Claim (5%)
**User Input**: £10,000
**Calculation**: (10000 × 5) ÷ 100 = £500.00
**Result**: Fee field populated with £500.00

### Scenario 2: Small Percentage

**Fee**: FEE0123 - Application Fee (2.5%)
**User Input**: £1,500
**Calculation**: (1500 × 2.5) ÷ 100 = £37.50
**Result**: Fee field populated with £37.50

### Scenario 3: Large Amount

**Fee**: FEE0507 - Counter Claim (5%)
**User Input**: £150,000
**Calculation**: (150000 × 5) ÷ 100 = £7,500.00
**Result**: Fee field populated with £7,500.00

## Fee Data Structure

### Percentage Fee Example (from fee_codes.js)
```javascript
{
  "code": "FEE0507",
  "fee_type": "ranged",
  "service_type": {"name": "civil money claims"},
  "fee_versions": [{
    "version": 4,
    "valid_from": "2014-04-22",
    "percentage_amount": {"percentage": 5.00},
    "description": "Counter Claim - 10000.01 up to 200000 GBP - 5% of claim value"
  }],
  "amount_type": "VOLUME"
}
```

### Key Difference: Percentage vs Flat Amount

**Percentage Fee**:
```javascript
"percentage_amount": {"percentage": 5.00}
```

**Flat Amount Fee**:
```javascript
"flat_amount": {"amount": 35.00}
```

## Testing

### Manual Testing

1. Navigate to Application Details page
2. Search for fee code (e.g., "FEE0507")
3. Click on a percentage-based fee result
4. Verify percentage input field appears
5. Enter a base amount (e.g., 10000)
6. Click "Calculate fee"
7. Verify calculated fee appears in fee field
8. Verify percentage input field is hidden

### Console Testing

```ruby
# In Rails console
params = {
  fee: {
    code: 'FEE0507',
    fee_version: {
      percentage_amount: { percentage: 5.0 },
      description: 'Counter Claim - 5%',
      version: 4
    }
  },
  base_amount: 10000.00
}

# Simulate the calculation
base_amount = params[:base_amount].to_f
percentage = params[:fee][:fee_version][:percentage_amount][:percentage].to_f
calculated_fee = (base_amount * percentage / 100).round(2)

puts "Base: £#{base_amount}, Percentage: #{percentage}%, Fee: £#{calculated_fee}"
# => Base: £10000.0, Percentage: 5.0%, Fee: £500.0
```

## Logging

The controller logs all calculations:

```
[FeeCalculator] Calculated fee: base_amount=10000.0, percentage=5.0%, calculated_fee=500.0
```

Check logs at: `tail -f log/development.log`

## Routes

**API Endpoint**:
```ruby
# config/routes.rb
post 'api/calculate_percentage_fee' => 'api/fee_calculator#calculate_percentage_fee'
```

## Files Modified

- `app/views/applications/process/details/index.html.slim` - Added percentage input field
- `app/javascript/freg.js` - Added percentage fee detection and calculation logic
- `app/controllers/api/fee_calculator_controller.rb` - Added calculation endpoint
- `config/routes.rb` - Added API route

## Security Considerations

- CSRF token required for API calls
- Input validation on both frontend and backend
- Strong parameters used to sanitize input
- No external API calls (calculation done locally)
- Results rounded to 2 decimal places to prevent precision issues
